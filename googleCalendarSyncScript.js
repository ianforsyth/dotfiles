// Script that syncs events from my personal calendar to my work calendar. 
// This way, those days/times are blocked for meetings. I run this as a 
// GoogleScript from my work workspace that's triggered every 15 minutes.
// Excluding birthday events and anything marked [private]

function calendarSync() {
  const PERSONAL_CAL_ID = 'ian@ianforsyth.com';
  const WORK_CAL_ID = 'primary';

  const now = new Date();
  const ninetyDaysLater = new Date() 
  ninetyDaysLater.setDate(now.getDate() + 90)

  const personalCalendar = CalendarApp.getCalendarById(PERSONAL_CAL_ID);
  const workCalendar = CalendarApp.getCalendarById(WORK_CAL_ID);

  // Clean up previously synced events
  const existingSyncedEvents = workCalendar.getEvents(now, ninetyDaysLater).filter(e => e.getTitle().includes("[Personal]"))
  existingSyncedEvents.forEach(e => e.deleteEvent());

  // Copy events from personal calendar
  const personalEvents = personalCalendar.getEvents(now, ninetyDaysLater);
  personalEvents.forEach(e => {
    const titleText = e.getTitle().toLowerCase();
    if (titleText.includes("birthday") || titleText.includes("private")) {
      return;
    }

    const day = e.getStartTime().getDay();
    if (day === 0 || day === 6) {
      return; // Skip Saturday and Sunday
    }

    const title = `[Personal] ${titleText}`;

    if (e.isAllDayEvent()) {
      workCalendar.createAllDayEvent(title, e.getAllDayStartDate(), e.getAllDayEndDate());
    } else {
      workCalendar.createEvent(title, e.getStartTime(), e.getEndTime());
    }
  });
}
