class TimetableParser {
 constructor(timetableData) {
    this.timetableData = timetableData;
 }

 getDays() {
    return this.timetableData.days;
 }

 getSchedulesForDay(dayIndex) {
    return this.timetableData.days[dayIndex].schedules;
 }

 getScheduleDetails(scheduleId) {
    for (const day of this.timetableData.days) {
      for (const schedule of day.schedules) {
        if (schedule.scheduledHourId === scheduleId) {
          return schedule;
        }
      }
    }
    return null;
 }

 getSubjectsForDay(dayIndex) {
    const schedules = this.getSchedulesForDay(dayIndex);
    return schedules.map(schedule => schedule.subject);
 }

 getTeachersForDay(dayIndex) {
    const schedules = this.getSchedulesForDay(dayIndex);
    return schedules.flatMap(schedule => schedule.teachers);
 }

 getRoomsForDay(dayIndex) {
    const schedules = this.getSchedulesForDay(dayIndex);
    return schedules.flatMap(schedule => schedule.rooms);
 }

 getGroupsForDay(dayIndex) {
    const schedules = this.getSchedulesForDay(dayIndex);
    return schedules.flatMap(schedule => schedule.groups);
 }

 getOrderlyServiceForDay(dayIndex) {
    const schedules = this.getSchedulesForDay(dayIndex);
    return schedules.flatMap(schedule => schedule.orderlyService);
 }

 // Add more methods as needed to access other parts of the timetable data
}

export default TimetableParser;

