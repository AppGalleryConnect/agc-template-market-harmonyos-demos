import { UtilLog } from '@hw-agconnect/util-log';

/**
 * 日志打印类
 */
export class Logger {
  private static _domain: number = 0xff00;
  private static _prefix: string = 'NetworkSpeedTool';
  private static _format: string = '%{public}s, %{public}s';

  public static debug(...args: string[]): void {
    UtilLog.debug(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static info(...args: string[]): void {
    UtilLog.info(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static warn(...args: string[]): void {
    UtilLog.warn(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static error(...args: string[]): void {
    UtilLog.error(Logger._domain, Logger._prefix, Logger._format, args);
  }
}
