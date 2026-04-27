import { UtilLog, LogConfig } from '@hw-agconnect/util-log';

/**
 * 日志打印类
 */
export class Logger {
  private static readonly CONFIG: LogConfig = {
    tag: 'module_swipeplayer',
    domain: 0xff00,
    open: true,
    showStack: true,
    showBorder: true,
    showDivider: true,
  };

  public static debug(...args: string[]): void {
    UtilLog.debugWithConfig(Logger.CONFIG, args);
  }

  public static info(...args: string[]): void {
    UtilLog.infoWithConfig(Logger.CONFIG, args);
  }

  public static warn(...args: string[]): void {
    UtilLog.warnWithConfig(Logger.CONFIG, args);
  }

  public static error(...args: string[]): void {
    UtilLog.errorWithConfig(Logger.CONFIG, args);
  }
}
