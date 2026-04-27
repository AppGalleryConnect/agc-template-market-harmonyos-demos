export class Formatter{
  public static formatFullDate(date: Date): string {
    const pad = (n: number) => (n < 10 ? '0' + n : n.toString());

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());

    return `${year}年${month}月${day}日 ${hours}:${minutes}`;
  }

  public static formatTime(timestamp: number) {
    const absoluteTimestamp = Math.abs(timestamp);

    // 计算小时、分钟和秒
    const hours = Math.floor(absoluteTimestamp / 3600);
    const minutes = Math.floor((absoluteTimestamp % 3600) / 60);
    const seconds = Math.floor(absoluteTimestamp % 60);

    // 格式化为两位数
    const formattedHours = hours.toString().padStart(2, '0');
    const formattedMinutes = minutes.toString().padStart(2, '0');
    const formattedSeconds = seconds.toString().padStart(2, '0');

    // 处理负数情况
    if (timestamp < 0) {
      return `--`;
    }

    return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
  }

}