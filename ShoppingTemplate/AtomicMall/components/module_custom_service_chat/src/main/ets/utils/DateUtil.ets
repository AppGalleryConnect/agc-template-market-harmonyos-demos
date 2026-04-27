export class DateUtil {
  // 格式化时间为聊天显示格式
  formatTimeForChat(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - timestamp;

    // 今天内显示时间
    if (this.isToday(date)) {
      return this.formatTime(date);
    }

    // 昨天显示"昨天"
    if (this.isYesterday(date)) {
      return '昨天 ' + this.formatTime(date);
    }

    // 一周内显示星期几
    if (diff < 7 * 24 * 60 * 60 * 1000) {
      return this.formatDayOfWeek(date);
    }

    // 更早的日期显示完整日期
    return this.formatDate(date);
  }

  // 判断是否为今天
  private isToday(date: Date): boolean {
    const today = new Date();
    return (
      date.getDate() === today.getDate() &&
      date.getMonth() === today.getMonth() &&
      date.getFullYear() === today.getFullYear()
    );
  }

  // 判断是否为昨天
  private isYesterday(date: Date): boolean {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    return (
      date.getDate() === yesterday.getDate() &&
      date.getMonth() === yesterday.getMonth() &&
      date.getFullYear() === yesterday.getFullYear()
    );
  }

  // 格式化时间 (HH:MM)
  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 格式化星期几
  private formatDayOfWeek(date: Date): string {
    const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return days[date.getDay()];
  }

  // 格式化日期 (YYYY-MM-DD)
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}

export default new DateUtil();
