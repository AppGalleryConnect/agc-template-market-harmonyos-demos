import { UtilLog, LogConfig } from '@hw-agconnect/util-log';

/**
 * 日志打印类
 */
export class Logger {
  private static readonly CONFIG: LogConfig = {
    tag: 'CoverNews',
    domain: 0xff00,
    open: true,
    showStack: true,
    showBorder: true,
    showDivider: true,
  };

  public static setLogConfig() {
    UtilLog.setGlobalConfig(Logger.CONFIG);
  }

  public static debug(...args: string[]): void {
    UtilLog.debug(args);
  }

  public static info(...args: string[]): void {
    UtilLog.info(args);
  }

  public static warn(...args: string[]): void {
    UtilLog.warn(args);
  }

  public static error(...args: string[]): void {
    UtilLog.error(args);
  }
}
