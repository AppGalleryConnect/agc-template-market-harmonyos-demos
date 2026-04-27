import { infraredEmitter } from '@kit.InputKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { RemoteConstant } from '../constant/Index';

export class ScheduledUtil {
  // 将经过的毫秒时间转换为友好的时间描述
  static formatElapsedTimeMinutesMinimized(elapsedMs: number): string[] {
    const totalMinutes = Math.floor(elapsedMs / 60000); // 1分钟 = 60000毫秒
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    const parts: string[] = [];
    parts.push(String(hours).padStart(2, '0'));
    parts.push(String(minutes).padStart(2, '0'));

    return parts;
  }

  static addTime(elapsedMs: number): number {
    let res = elapsedMs + RemoteConstant.DEFAULT_INTERVAL;
    if (res >= 48 * RemoteConstant.DEFAULT_INTERVAL) {
      res = RemoteConstant.DEFAULT_INTERVAL;
    }
    return res;
  }

  static decreaseTime(elapsedMs: number): number {
    let res = elapsedMs - RemoteConstant.DEFAULT_INTERVAL;
    if (res <= 0) {
      res = 48 * RemoteConstant.DEFAULT_INTERVAL;
    }
    return res;
  }


  static getTimeAfterMilliseconds(now: Date, milliseconds: number): string {
    // 计算未来的时间
    const futureTime = new Date(now.getTime() + milliseconds);

    // 获取今天的日期部分（年、月、日），用于和未来时间比较
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const futureDate = new Date(futureTime.getFullYear(), futureTime.getMonth(), futureTime.getDate());

    // 判断是否是明天（即日期不同）
    const isTomorrow = futureDate.getTime() > today.getTime();

    // 格式化时间为 24 小时制 HH:mm
    const hours = futureTime.getHours().toString().padStart(2, '0');
    const minutes = futureTime.getMinutes().toString().padStart(2, '0');
    const timeStr = `${hours}:${minutes}`;

    // 拼接返回字符串
    return isTomorrow ? `明天 ${timeStr}` : timeStr;
  }
}

export class SendUtil {
  static sendInfrared(infraredFrequency: number, patternStr: string) {
    const pattern: number[] = patternStr.split(',').map((item) => {
      return Number(item);
    });
    try {
      infraredEmitter.transmitInfrared(infraredFrequency, pattern);
    } catch (error) {
      UtilLog.error(0xff00, 'RemoteControl', `transmitInfrared failed, error: ${JSON.stringify(error, [`code`, `message`])}`);
    }
  }
}

