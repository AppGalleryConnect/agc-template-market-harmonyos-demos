import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static domain: number = 0xff00;
  private static prefix: string = 'HotelTemplate';
  private static format: string = '%{public}s, %{public}s';

  public static debug(...args: string[]): void {
    hilog.debug(Logger.domain, Logger.prefix, Logger.format, args);
  }

  public static info(...args: string[]): void {
    hilog.info(Logger.domain, Logger.prefix, Logger.format, args);
  }

  public static warn(...args: string[]): void {
    hilog.warn(Logger.domain, Logger.prefix, Logger.format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(Logger.domain, Logger.prefix, Logger.format, args);
  }
}
