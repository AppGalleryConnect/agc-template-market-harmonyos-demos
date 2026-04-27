export function formatTimestamp(timestamp: number): string {
  const currentTime = Date.now();
  const diff = currentTime - timestamp;

  // 判断是否在十分钟内
  if (diff < 10 * 60 * 1000) {
    return '刚刚';
  }

  // 获取传入时间的 Date 对象
  const inputDate = new Date(timestamp);
  const today = new Date(currentTime);
  const yesterday = new Date(currentTime - 24 * 60 * 60 * 1000);

  // 判断是否是当天
  if (
    inputDate.getFullYear() === today.getFullYear() &&
    inputDate.getMonth() === today.getMonth() &&
    inputDate.getDate() === today.getDate()
  ) {
    // 格式化为 HH:mm
    const hours = inputDate.getHours().toString().padStart(2, '0');
    const minutes = inputDate.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 判断是否是昨天
  if (
    inputDate.getFullYear() === yesterday.getFullYear() &&
    inputDate.getMonth() === yesterday.getMonth() &&
    inputDate.getDate() === yesterday.getDate()
  ) {
    return '昨天';
  }

  // 更早的时间，格式化为 'd/M/y'
  const day = inputDate.getDate().toString().padStart(2, '0');
  const month = (inputDate.getMonth() + 1).toString().padStart(2, '0');
  const year = inputDate.getFullYear().toString().slice(-2);
  return `${day}/${month}/${year}`;
}
