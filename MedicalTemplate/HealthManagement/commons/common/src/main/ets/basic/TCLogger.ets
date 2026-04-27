import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志打印类
 */
const MAX_LENGTH = 3500;

export class TCLogger {
  private static prefix: string = 'UniversalTemplate';
  private static domain: number = 0x0000;
  static isModelDebug: boolean = true;

  static debug(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let indexA = 0;
      let format = '';
      let argsLengthA = args.length;
      let length = 0;
      for (indexA = 0; indexA <= argsLengthA - 1; indexA++) {
        format = format + '%{public}s,';
        let currentLength = length + args[indexA]?.length;
        if (currentLength > MAX_LENGTH) {
          args[indexA] = args[indexA].substring(0, MAX_LENGTH - length);
          indexA++;
          break;
        } else {
          length = currentLength;
        }
      }

      hilog.debug(TCLogger.domain, TCLogger.prefix, format, args.slice(0, indexA));
      format = format.substring(0, format.length - 1);
    }
  }

  static info(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let index = 0;
      let argsLength = args.length;
      let formatInfo = '';
      let length = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        formatInfo = formatInfo + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      formatInfo = formatInfo.substring(0, formatInfo.length - 1);
      hilog.info(TCLogger.domain, TCLogger.prefix, formatInfo, args.slice(0, index));
    }
  }

  static error(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }


      let length = 0;
      let argsLength = args.length;
      let index = 0;
      let formatError = '';
      for (index = 0; index <= argsLength - 1; index++) {
        formatError = formatError + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      formatError = formatError.substring(0, formatError.length - 1);
      hilog.error(TCLogger.domain, TCLogger.prefix, formatError, args.slice(0, index));
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