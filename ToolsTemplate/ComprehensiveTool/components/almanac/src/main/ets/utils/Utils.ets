export function convertToEmperorEra(date: string): number {
  let year = new Date(date).getFullYear()
  return year + 2697;
}

export function fullDateTransfer(date: string): string {
  let year = date.split('-')[0]
  let month = date.split('-')[1]
  let day =date.split('-')[2]
  return `${year}年${month}月${day}日`;
}

export function getWeekday(dateStr: Date) {
  const days = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
  return days[dateStr.getDay()];
}

export function getDaysDiff(start: Date, end: Date): number {
  const startMidnight = new Date(start.getFullYear(), start.getMonth(), start.getDate());
  const endMidnight = new Date(end.getFullYear(), end.getMonth(), end.getDate());
  const diffMs = endMidnight.getTime() - startMidnight.getTime();
  return Math.floor(diffMs / (1000 * 3600 * 24));
}
