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
      let formatDebug = '';
      let length = 0;
      let index = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        formatDebug = formatDebug + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      formatDebug = formatDebug.substring(0, formatDebug.length - 1);
    }
  }

  static info(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let argsLength = args.length;
      let formatInfo = '';
      let length = 0;
      let index = 0;
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
    }
  }

  static error(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let argsLength = args.length;
      let formatErr = '';
      let length = 0;
      let index = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        formatErr = formatErr + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      formatErr = formatErr.substring(0, formatErr.length - 1);
    }
  }

  static warn(...args: string[]): void {
    if (TCLogger.isModelDebug) {
      if (!args || args.length < 1) {
        return;
      }

      let argsLength = args.length;
      let formatWarn = '';
      let length = 0;
      let index = 0;
      for (index = 0; index <= argsLength - 1; index++) {
        formatWarn = formatWarn + '%{public}s,';
        let currentLength = length + args[index]?.length;
        if (currentLength > MAX_LENGTH) {
          args[index] = args[index].substring(0, MAX_LENGTH - length);
          index++;
          break;
        } else {
          length = currentLength;
        }
      }

      formatWarn = formatWarn.substring(0, formatWarn.length - 1);
    }
  }
}