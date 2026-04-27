import { UtilLog } from '@hw-agconnect/util-log';

export class TranLogger {
  private static domain: number = 0xff00;
  private static tag: string = 'translator';
  private static format: string = '%{public}s, %{public}s';

  public static debug(...args: string[]): void {
    UtilLog.debug(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }

  public static info(...args: string[]): void {
    UtilLog.info(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }

  public static warn(...args: string[]): void {
    UtilLog.warn(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }

  public static error(...args: string[]): void {
    UtilLog.error(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }
}
