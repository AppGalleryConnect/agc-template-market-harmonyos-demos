export function formatFullDate(date: Date): string {
  const pad = (n: number) => n < 10 ? '0' + n : n.toString();

  const year = date.getFullYear();
  const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
  const day = pad(date.getDate());

  return `${year}-${month}-${day}`;
}