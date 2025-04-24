export  class Calendar {
  date: string = ''
  week: string = ''
}

// 获取今天之后一个星期的日历
export function getNextWeekCalendar() {
  const today = new Date();
  const calendar: Calendar[] = [];

  // 循环 7 次以获取接下来一周的日期
  for (let i = 1; i <= 7; i++) {
    const nextDate = new Date(today);
    nextDate.setDate(today.getDate() + i);

    const year = nextDate.getFullYear();
    const month = String(nextDate.getMonth() + 1).padStart(2, '0');
    const day = String(nextDate.getDate()).padStart(2, '0');
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const week = weekDays[nextDate.getDay()];

    const formattedDate = `${year}-${month}-${day}`;
    calendar.push({
      date: formattedDate,
      week: week
    });
  }

  return calendar;
}