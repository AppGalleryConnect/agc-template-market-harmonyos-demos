import { UtilLog } from '@hw-agconnect/util-log';

export class Logger {
  private static flag: string = 'credentials_photo';
  private static domain: number = 0xff00;
  private static format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
    UtilLog.info(Logger.domain, Logger.flag, Logger.format, args);
  }

  public static error(...args: string[]): void {
    UtilLog.error(Logger.domain, Logger.flag, Logger.format, args);
  }
}
