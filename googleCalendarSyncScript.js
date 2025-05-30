// Script that syncs events from my personal calendar to my work calendar.
// This way, those days/times are blocked for meetings. I run this as a
// GoogleScript from my work workspace that's triggered every 15 minutes.
// Excluding
// - Birthday events
// - Anything marked [private]
// - Invitations or events with specified emails on the guest list

function calendarSync() {
  const PERSONAL_CAL_ID = "ian@ianforsyth.com";
  const WORK_CAL_ID = "primary";

  const now = new Date();
  const ninetyDaysLater = new Date();
  ninetyDaysLater.setDate(now.getDate() + 90);

  const personalCalendar = CalendarApp.getCalendarById(PERSONAL_CAL_ID);
  const workCalendar = CalendarApp.getCalendarById(WORK_CAL_ID);

  // Privatize events if these people are attending (prevent double booking business meetings)
  const PRIVATE_ATTENDEES = ["ryan@r7enterprise.com", "ryan.dimillo@gmail.com"];

  // Clean up previously synced events
  const existingSyncedEvents = workCalendar
    .getEvents(now, ninetyDaysLater)
    .filter((e) => e.getTitle().includes("[Personal]"));
  existingSyncedEvents.forEach((e) => e.deleteEvent());

  // Copy events from personal calendar
  const personalEvents = personalCalendar.getEvents(now, ninetyDaysLater);
  personalEvents.forEach((e) => {
    let titleText = e.getTitle();

    // Don't copy birthdays or events marked "private"
    if (
      titleText.toLowerCase().includes("birthday") ||
      titleText.toLowerCase().includes("private")
    ) {
      return;
    }

    // Skip Saturday and Sunday
    const day = e.getStartTime().getDay();
    if (day === 0 || day === 6) {
      return;
    }

    // Privatize event if private guests are included (prevent double booking business meetings)
    const hasPrivateAttendee = e.getGuestList().some((guest) => {
      const guestEmail = guest.getEmail();

      // Check against all private attendees
      return PRIVATE_ATTENDEES.some(
        (privateAttendee) =>
          guestEmail.toLowerCase() === privateAttendee.toLowerCase()
      );
    });

    if (hasPrivateAttendee) {
      titleText = "Busy";
    }

    const title = `[Personal] ${titleText}`;

    if (e.isAllDayEvent()) {
      workCalendar.createAllDayEvent(
        title,
        e.getAllDayStartDate(),
        e.getAllDayEndDate()
      );
    } else {
      workCalendar.createEvent(title, e.getStartTime(), e.getEndTime());
    }
  });
}
