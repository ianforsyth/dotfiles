/**
 * Multi-calendar sync via per-account OAuth.
 *
 * Architecture (flat, no Mirror sub-calendars):
 *   - Cross-account mirror events are written directly to the TARGET ACCOUNT'S
 *     PRIMARY calendar. Coworkers see them via normal calendar sharing.
 *   - Each work account's events are ALSO copied to a dedicated sub-calendar
 *     on the Personal account ("Personal/ResiDesk" and "Personal/Moove") with
 *     full details, so the user gets a unified scheduling view in Notion
 *     Calendar by toggling ResiDesk + Moove accounts off entirely.
 *   - Loop prevention: events tagged with the mirrorSync extended property
 *     are skipped when read as sources.
 *
 * Sync topology:
 *   Personal primary -> ResiDesk primary  : [Personal] - <title> or [Personal] - Busy (filtered)
 *   Personal primary -> Moove primary     : [Personal] - <title> or [Personal] - Busy (filtered)
 *   ResiDesk primary -> Moove primary     : [ResiDesk] - Busy
 *   Moove primary    -> ResiDesk primary  : [Personal] - Busy   (disguised via displayLabel)
 *   ResiDesk primary -> Personal/ResiDesk : [ResiDesk] - <title>  (full details, unfiltered)
 *   Moove primary    -> Personal/Moove    : [Moove] - <title>     (full details, unfiltered)
 */

// ============================================================================
// CONFIG  -- edit this section
// ============================================================================

const CONFIG = {
  oauth: {
    clientId:     'CLIENT_ID',
    clientSecret: 'CLIENT_SECRET',
  },

  // login_hint for the OAuth screen + a place to keep emails handy.
  accounts: {
    personal: { email: 'ian@ianforsyth.com'      },
    residesk: { email: 'ian@theresidesk.com'     },
    moove:    { email: 'ian@moovetogether.com'   },
  },

  // Two sub-calendars Ian creates in his Personal Google Calendar to receive
  // full-detail copies of work events. These power the unified Notion Calendar
  // view (Personal account on, ResiDesk + Moove accounts off).
  personalSubcals: {
    residesk: 'c_07d79e70474325a69111d3750c3c7ba626f631284052aad8e91e9071e410801a@group.calendar.google.com',
    moove:    'c_a8bb4fd872fabf9d21694e2eea6a9f57d138da4ad7b60d2aa96740166936d7c4@group.calendar.google.com',
  },

  daysBack: 7,
  daysForward: 60,

  // Filter applied only to Personal-as-source pairs. Match = hide details,
  // mirror shows as "[Personal] - Busy" instead of the real title.
  hideDetailsIfTitleContains: [
    'birthday',
    'moove',
  ],
  hideDetailsIfParticipantEmail: [
    'ryan@r7enterprise.com',
    'ryan.dimillo@gmail.com',
    'rdimillo@thestoragecenter.com',
  ],

  // Set true to log intended actions without writing anything.
  dryRun: false,
};

// Sync topology. targetCalendarId defaults to 'primary' when not specified.
const SYNC_PAIRS = [
  // Personal -> work primaries (conditional details, coworkers see)
  { sourceAccount: 'personal', targetAccount: 'residesk',
    sourceLabel: 'Personal', detailMode: 'conditional' },
  { sourceAccount: 'personal', targetAccount: 'moove',
    sourceLabel: 'Personal', detailMode: 'conditional' },

  // Work -> opposite work primary (busy-only, coworkers see)
  { sourceAccount: 'residesk', targetAccount: 'moove',
    sourceLabel: 'ResiDesk', detailMode: 'busy' },
  { sourceAccount: 'moove',    targetAccount: 'residesk',
    sourceLabel: 'Moove', displayLabel: 'Personal', detailMode: 'busy' },

  // Work -> Personal sub-calendars (full details, just for Ian's unified view)
  { sourceAccount: 'residesk', targetAccount: 'personal',
    targetCalendarId: CONFIG.personalSubcals.residesk,
    sourceLabel: 'ResiDesk', detailMode: 'all' },
  { sourceAccount: 'moove',    targetAccount: 'personal',
    targetCalendarId: CONFIG.personalSubcals.moove,
    sourceLabel: 'Moove', detailMode: 'all' },
];

const MIRROR_MARKER_KEY = 'mirrorSync';

// ============================================================================
// MAIN
// ============================================================================

function syncAll() {
  for (const pair of SYNC_PAIRS) {
    try {
      syncPair_(pair);
    } catch (err) {
      console.error(`FAILED ${pair.sourceAccount} -> ${pair.targetAccount}: ${err.message}\n${err.stack}`);
    }
  }
}

function syncPair_(pair) {
  const sourceCalendarId = pair.sourceCalendarId || 'primary';
  const targetCalendarId = pair.targetCalendarId || 'primary';

  const now = new Date();
  const start = new Date(now.getTime() - CONFIG.daysBack    * 86400000);
  const end   = new Date(now.getTime() + CONFIG.daysForward * 86400000);

  const sourceEvents = listEvents_(pair.sourceAccount, sourceCalendarId, start, end);
  const mirrors      = listMirrors_(pair.targetAccount, targetCalendarId, pair.sourceLabel, start, end);

  const seen = new Set();
  let created = 0, updated = 0, unchanged = 0, deleted = 0, skipped = 0;

  for (const src of sourceEvents) {
    if (src.status === 'cancelled') continue;
    if (!src.start || (!src.start.dateTime && !src.start.date)) continue;

    // Loop prevention: never re-mirror a mirror.
    if (src.extendedProperties && src.extendedProperties.private &&
        src.extendedProperties.private[MIRROR_MARKER_KEY]) {
      skipped++;
      continue;
    }

    seen.add(src.id);

    const showDetails = resolveShowDetails_(pair.detailMode, src);
    const payload = buildMirrorPayload_(src, pair.sourceLabel, pair.displayLabel, showDetails);

    const existing = mirrors[src.id];
    if (existing) {
      if (mirrorNeedsUpdate_(existing, payload)) {
        if (!CONFIG.dryRun) {
          calendarApi_(pair.targetAccount, 'PATCH',
            `/calendars/${encodeURIComponent(targetCalendarId)}/events/${existing.id}`,
            null, payload);
        }
        console.log(`UPDATE  [${pair.sourceLabel}->${pair.targetAccount}]  ${payload.summary}`);
        updated++;
      } else {
        unchanged++;
      }
    } else {
      if (!CONFIG.dryRun) {
        calendarApi_(pair.targetAccount, 'POST',
          `/calendars/${encodeURIComponent(targetCalendarId)}/events`,
          null, payload);
      }
      console.log(`CREATE  [${pair.sourceLabel}->${pair.targetAccount}]  ${payload.summary}`);
      created++;
    }
  }

  for (const [sourceUid, mirror] of Object.entries(mirrors)) {
    if (!seen.has(sourceUid)) {
      if (!CONFIG.dryRun) {
        calendarApi_(pair.targetAccount, 'DELETE',
          `/calendars/${encodeURIComponent(targetCalendarId)}/events/${mirror.id}`);
      }
      console.log(`DELETE  [${pair.sourceLabel}->${pair.targetAccount}]  ${mirror.summary}`);
      deleted++;
    }
  }

  console.log(
    `SUMMARY [${pair.sourceLabel}->${pair.targetAccount}] ` +
    `created=${created} updated=${updated} unchanged=${unchanged} deleted=${deleted} skipped=${skipped}` +
    (CONFIG.dryRun ? '  (DRY RUN)' : '')
  );
}

// ============================================================================
// EVENT TRANSFORM
// ============================================================================

function resolveShowDetails_(detailMode, src) {
  if (detailMode === 'all')         return true;
  if (detailMode === 'busy')        return false;
  if (detailMode === 'conditional') return shouldShowDetails_(src);
  throw new Error(`Unknown detailMode: ${detailMode}`);
}

function shouldShowDetails_(event) {
  const title = (event.summary || '').toLowerCase();
  for (const kw of CONFIG.hideDetailsIfTitleContains) {
    if (title.includes(kw.toLowerCase())) return false;
  }
  const blocked = CONFIG.hideDetailsIfParticipantEmail.map(e => e.toLowerCase());
  for (const a of (event.attendees || [])) {
    if (a.email && blocked.includes(a.email.toLowerCase())) return false;
  }
  return true;
}

function buildMirrorPayload_(src, sourceLabel, displayLabel, showDetails) {
  const prefix = displayLabel || sourceLabel;
  const summary = showDetails
    ? `[${prefix}] - ${src.summary || '(no title)'}`
    : `[${prefix}] - Busy`;

  return {
    summary: summary,
    description: showDetails ? (src.description || '') : '',
    location:    showDetails ? (src.location    || '') : '',
    start: src.start.date
      ? { date: src.start.date }
      : { dateTime: src.start.dateTime, timeZone: src.start.timeZone },
    end: src.end.date
      ? { date: src.end.date }
      : { dateTime: src.end.dateTime, timeZone: src.end.timeZone },
    transparency: 'opaque',
    // Always 'default' now -- the title itself encodes whether real details
    // are visible. 'private' would hide the "[Personal] - Busy" label too.
    visibility: 'default',
    reminders: { useDefault: false, overrides: [] },
    // Attendees omitted so guests aren't re-invited.
    extendedProperties: {
      private: {
        [MIRROR_MARKER_KEY]: sourceLabel,
        sourceEventId: src.id,
      },
    },
  };
}

function mirrorNeedsUpdate_(existing, desired) {
  if (existing.summary !== desired.summary) return true;
  if ((existing.description || '') !== desired.description) return true;
  if ((existing.location || '') !== desired.location) return true;
  const ex = existing.start.dateTime || existing.start.date;
  const dx = desired.start.dateTime  || desired.start.date;
  if (ex !== dx) return true;
  const ey = existing.end.dateTime || existing.end.date;
  const dy = desired.end.dateTime  || desired.end.date;
  if (ey !== dy) return true;
  return false;
}

// ============================================================================
// CALENDAR API CLIENT (UrlFetchApp + per-account OAuth)
// ============================================================================

function listEvents_(accountKey, calendarId, timeMin, timeMax) {
  return paginatedEventList_(accountKey, calendarId, {
    timeMin: timeMin.toISOString(),
    timeMax: timeMax.toISOString(),
    singleEvents: true,
    orderBy: 'startTime',
    showDeleted: false,
  });
}

function listMirrors_(accountKey, calendarId, sourceLabel, timeMin, timeMax) {
  const items = paginatedEventList_(accountKey, calendarId, {
    timeMin: timeMin.toISOString(),
    timeMax: timeMax.toISOString(),
    singleEvents: true,
    showDeleted: false,
    privateExtendedProperty: `${MIRROR_MARKER_KEY}=${sourceLabel}`,
  });
  const byId = {};
  for (const item of items) {
    const sourceUid = item.extendedProperties &&
                      item.extendedProperties.private &&
                      item.extendedProperties.private.sourceEventId;
    if (sourceUid) byId[sourceUid] = item;
  }
  return byId;
}

function paginatedEventList_(accountKey, calendarId, baseParams) {
  const all = [];
  let pageToken;
  do {
    const params = Object.assign({}, baseParams, { maxResults: 2500, pageToken: pageToken });
    const resp = calendarApi_(accountKey, 'GET',
      `/calendars/${encodeURIComponent(calendarId)}/events`, params);
    if (resp.items) all.push(...resp.items);
    pageToken = resp.nextPageToken;
  } while (pageToken);
  return all;
}

function calendarApi_(accountKey, method, path, queryParams, body) {
  const svc = getOAuthService_(accountKey);
  if (!svc.hasAccess()) {
    throw new Error(`Account "${accountKey}" not authorized. Run showAuthUrls() to start.`);
  }

  let url = `https://www.googleapis.com/calendar/v3${path}`;
  if (queryParams) {
    const qs = Object.entries(queryParams)
      .filter(([k, v]) => v !== undefined && v !== null && v !== '')
      .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
      .join('&');
    if (qs) url += '?' + qs;
  }

  const options = {
    method: method,
    headers: { Authorization: 'Bearer ' + svc.getAccessToken() },
    muteHttpExceptions: true,
    contentType: 'application/json',
  };
  if (body) options.payload = JSON.stringify(body);

  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  const text = response.getContentText();

  if (code === 204 || !text) return null;
  if (code >= 400) {
    throw new Error(`Calendar API ${method} ${path} -> ${code}: ${text}`);
  }
  return JSON.parse(text);
}

// ============================================================================
// OAUTH
// ============================================================================

function getOAuthService_(accountKey) {
  return OAuth2.createService('calendar-sync-' + accountKey)
    .setAuthorizationBaseUrl('https://accounts.google.com/o/oauth2/auth')
    .setTokenUrl('https://oauth2.googleapis.com/token')
    .setClientId(CONFIG.oauth.clientId)
    .setClientSecret(CONFIG.oauth.clientSecret)
    .setCallbackFunction('authCallback')
    .setPropertyStore(PropertiesService.getScriptProperties())
    .setScope('https://www.googleapis.com/auth/calendar')
    .setParam('access_type', 'offline')
    .setParam('prompt', 'consent')
    .setParam('login_hint', CONFIG.accounts[accountKey].email);
}

function authCallback(request) {
  const accountKey = request.parameter.account;
  if (!accountKey || !CONFIG.accounts[accountKey]) {
    return HtmlService.createHtmlOutput('Bad callback: missing/unknown account parameter.');
  }
  const svc = getOAuthService_(accountKey);
  const ok = svc.handleCallback(request);
  return HtmlService.createHtmlOutput(
    ok
      ? `<h3>Authorized: ${accountKey}</h3><p>You can close this tab.</p>`
      : `<h3>Denied: ${accountKey}</h3>`
  );
}

function showAuthUrls() {
  for (const accountKey of Object.keys(CONFIG.accounts)) {
    const svc = getOAuthService_(accountKey);
    if (svc.hasAccess()) {
      console.log(`${accountKey}: ALREADY AUTHORIZED`);
    } else {
      const url = svc.getAuthorizationUrl({ account: accountKey });
      console.log(`${accountKey}: ${url}`);
    }
  }
}

function logAuthStatus() {
  for (const accountKey of Object.keys(CONFIG.accounts)) {
    const svc = getOAuthService_(accountKey);
    console.log(`${accountKey}: ${svc.hasAccess() ? 'authorized' : 'NOT authorized'}`);
  }
}

function revokeAuth(accountKey) {
  getOAuthService_(accountKey).reset();
  console.log(`Revoked: ${accountKey}`);
}

// ============================================================================
// TRIGGERS
// ============================================================================

function installTrigger() {
  for (const t of ScriptApp.getProjectTriggers()) {
    if (t.getHandlerFunction() === 'syncAll') ScriptApp.deleteTrigger(t);
  }
  ScriptApp.newTrigger('syncAll').timeBased().everyMinutes(10).create();
  console.log('Trigger installed: syncAll every 10 minutes');
}

function uninstallTrigger() {
  for (const t of ScriptApp.getProjectTriggers()) {
    if (t.getHandlerFunction() === 'syncAll') ScriptApp.deleteTrigger(t);
  }
  console.log('Triggers removed');
}

// ============================================================================
// MAINTENANCE
// ============================================================================

/**
 * Delete ALL events tagged by this script from every target calendar in
 * SYNC_PAIRS. Useful for resets or after rule changes. Touches only events
 * carrying the mirrorSync extended property -- real events are never touched.
 */
function purgeAllMirrors() {
  const start = new Date(Date.now() - 365 * 86400000);
  const end   = new Date(Date.now() + 365 * 86400000);

  // Collect distinct (account, calendarId, sourceLabel) triples from SYNC_PAIRS
  const targets = new Map();
  for (const pair of SYNC_PAIRS) {
    const calId = pair.targetCalendarId || 'primary';
    const key = `${pair.targetAccount}|${calId}|${pair.sourceLabel}`;
    targets.set(key, { account: pair.targetAccount, calendarId: calId, label: pair.sourceLabel });
  }

  for (const { account, calendarId, label } of targets.values()) {
    const mirrors = listMirrors_(account, calendarId, label, start, end);
    for (const m of Object.values(mirrors)) {
      if (!CONFIG.dryRun) {
        calendarApi_(account, 'DELETE',
          `/calendars/${encodeURIComponent(calendarId)}/events/${m.id}`);
      }
      console.log(`PURGE [${label}->${account}/${calendarId}]  ${m.summary}`);
    }
  }
}
