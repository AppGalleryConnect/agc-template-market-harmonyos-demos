
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
    }
  }
}