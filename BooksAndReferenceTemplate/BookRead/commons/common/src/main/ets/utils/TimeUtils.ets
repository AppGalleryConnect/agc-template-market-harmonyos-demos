import { intl } from '@kit.LocalizationKit';

export class DHMS {
  days: number = 0;
  hours: number = 0;
  minutes: number = 0;
  seconds: number = 0;

  constructor(begin: number, end: number) {
    const diffInMs = Math.abs(end - begin);
    const diffInSeconds = Math.floor(diffInMs / 1000);

    this.days = Math.floor(diffInSeconds / (24 * 60 * 60));
    const remainingSecondsAfterDays = diffInSeconds % (24 * 60 * 60);

    this.hours = Math.floor(remainingSecondsAfterDays / (60 * 60));
    const remainingSecondsAfterHours = remainingSecondsAfterDays % (60 * 60);

    this.minutes = Math.floor(remainingSecondsAfterHours / 60);
    this.seconds = remainingSecondsAfterHours % 60;
  }
}

export class TimeUtils {
  public static timestamp2YMDH(timestamp: number) {
    let date = new Date(timestamp);
    let formatForYMDH = new intl.DateTimeFormat('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
    return formatForYMDH.format(date);
  }

  public static timestamp2YMD(timestamp: number) {
    let date = new Date(timestamp);
    let formatForYMDH = new intl.DateTimeFormat('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' });
    return formatForYMDH.format(date);
  }
}