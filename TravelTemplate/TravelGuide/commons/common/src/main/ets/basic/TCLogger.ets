import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志打印类
 */
const MAX_LENGTH = 3500;

export class TCLogger {
  private static domain: number = 0x0000;
  private static prefix: string = 'UniversalTemplate';
  static isModelDebug: boolean = true;

  static debug(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let argsLength = args.length;
      let format = '';
      let length = 0;
      let index = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        format = format + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      format = format.substring(0, format.length - 1);
      hilog.debug(TCLogger.domain, TCLogger.prefix, format, args.slice(0, index));
    }
  }

  static info(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let argsLength = args.length;
      let format = '';
      let length = 0;
      let index = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        format = format + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      format = format.substring(0, format.length - 1);
      hilog.info(TCLogger.domain, TCLogger.prefix, format, args.slice(0, index));
    }
  }

  static error(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let argsLength = args.length;
      let format = '';
      let length = 0;
      let index = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        format = format + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      format = format.substring(0, format.length - 1);
      hilog.error(TCLogger.domain, TCLogger.prefix, format, args.slice(0, index));
    }
  }

  static warn(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let argsLength = args.length;
      let format = '';
      let length = 0;
      let index = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        format = format + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      format = format.substring(0, format.length - 1);
      hilog.warn(TCLogger.domain, TCLogger.prefix, format, args.slice(0, index));
    }
  }
}