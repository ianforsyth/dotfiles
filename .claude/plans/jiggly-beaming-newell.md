# Remove PropExo Applicant Event Hotfix

## Background
Commit `4c873743c` ("Call entrata directly") added a temporary workaround on 2025-01-14 to bypass PropExo's broken `/events/applicants` endpoint by calling Entrata directly. The user has confirmed PropExo has fixed the bug, so we can remove this hotfix.

## Changes Required

### 1. Delete the hotfix file
- **File:** `PropExo/Api/Events/callEntrataDirectlyForApplicant.js`
- **Action:** Delete entire file (192 lines)

### 2. Update `PropExo/Api/Events/index.js`

**Remove import (line 4):**
```javascript
import { callEntrataDirectlyForApplicant } from './callEntrataDirectlyForApplicant.js'
```

**Remove hotfix comment block and temporary code (lines 333-414), restore original code:**

The section currently has:
- A large comment block explaining the hotfix (lines 333-351)
- Commented-out original PropExo API call (lines 353-383)
- The temporary Entrata bypass code (lines 385-414)

Replace all of this with the original uncommented code:
```javascript
logger?.info('Creating applicant event in PropExo', {
  propexo_applicant_id,
  event_type_id,
  event_result_id,
  integration_id,
  notesLength: notes?.length,
  final_application_id: requestBody.application_id || null,
  has_application_id: !!requestBody.application_id
})

const response = await callPropexoApi({
  endpoint: '/events/applicants',
  method: 'POST',
  data: requestBody,
  metadata: { function: 'createApplicantEvent', operation: 'trackMessage' },
  logger,
  portfolioId,
  personId,
  propexoLeadId: propexo_applicant_id,
  propexoIntegrationId: integration_id
})

logger?.info('Successfully created applicant event in PropExo', {
  propexo_applicant_id,
  event_type_id,
  event_result_id,
  job_id: response.job_id
})
```

## Summary
- 1 file deleted
- 1 file modified (remove ~80 lines, restore ~25 lines of original code)
