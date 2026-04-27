import { UtilLog } from '@hw-agconnect/util-log';

export class Logger {
  private static domain: number = 0xff00;
  private static prefix: string = 'Template';
  private static format: string = '%{public}s, %{public}s';

  public static debug(...args: string[]): void {
    UtilLog.debug(Logger.domain, Logger.prefix, Logger.format, args);
  }

  public static info(...args: string[]): void {
    UtilLog.info(Logger.domain, Logger.prefix, Logger.format, args);
  }

  public static warn(...args: string[]): void {
    UtilLog.warn(Logger.domain, Logger.prefix, Logger.format, args);
  }

  public static error(...args: string[]): void {
    UtilLog.error(Logger.domain, Logger.prefix, Logger.format, args);
  }
}
