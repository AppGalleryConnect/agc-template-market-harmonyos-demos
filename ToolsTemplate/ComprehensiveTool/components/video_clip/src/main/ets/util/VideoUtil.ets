export class VideoUtil {
  /**
   * 视频时长转换
   * @param microseconds
   * @returns
   */
  static formatUsToMinSec(microseconds: number): string {
    // 处理负数情况，取绝对值
    const us = Math.abs(microseconds);
    // 微秒转秒（1秒 = 1,000,000微秒），向下取整
    const totalSeconds = Math.floor(us / 1000000);
    // 计算分钟和剩余秒数
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    // 数字补零处理（确保两位数）
    const padZero = (num: number): string => num.toString().padStart(2, '0');
    // 拼接成 "XX分:XX秒" 格式
    return ` ${padZero(minutes)}:${padZero(seconds)}`;
  }

  /**
   * 将byte转换为MB，带单位
   * @param byteSize
   * @returns
   */
  static formatFileSize(bytes: number): string {
    if (bytes <= 0) {
      return '0 B';
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    const size = `${(bytes / Math.pow(1024, i)).toFixed(2)} ${units[i]}`;
    return size;
  }

  /**
   * 文件大小Bytes转MB
   * @param {number|string} bytes
   * @param {number} decimalPlaces
   * @returns {number}
   */
  static fileBytesToMB(bytes: number, decimalPlaces = 2) {
    const validBytes = isNaN(Number(bytes)) ? 0 : Math.max(0, Number(bytes));

    const mbValue = validBytes / 1048576;

    const pow = Math.pow(10, decimalPlaces);
    return Math.round(Number(mbValue.toPrecision(12)) * pow) / pow;
  }

  /**
   * 将毫秒数转换为时分秒格式的字符串（HH:MM:SS）
   * @param milliseconds 输入的毫秒数
   * @returns 格式化后的时分秒字符串
   */
  static formatMillisecondsToHMS(milliseconds: number): string {
    const totalSeconds = Math.max(0, Math.floor(Math.abs(milliseconds) / 1000));

    const hours = Math.floor(totalSeconds / 3600);
    const remainingSecondsAfterHours = totalSeconds % 3600;
    const minutes = Math.floor(remainingSecondsAfterHours / 60);
    const seconds = remainingSecondsAfterHours % 60;

    const padZero = (num: number): string => num.toString().padStart(2, '0');

    const formattedMinutes = padZero(minutes);
    const formattedSeconds = padZero(seconds);

    if (hours > 0) {
      const formattedHours = padZero(hours);
      return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
    } else {
      return `${formattedMinutes}:${formattedSeconds}`;
    }
  }
}