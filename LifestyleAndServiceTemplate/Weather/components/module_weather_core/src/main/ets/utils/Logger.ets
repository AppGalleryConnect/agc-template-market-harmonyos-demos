import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static _domain: number = 0xff00;
  private static _prefix: string = 'WeatherCore';
  private static _format: string = '%{public}s, %{public}s';

  public static debug(tag: string, message: string): void {
    hilog.debug(Logger._domain, Logger._prefix, Logger._format, tag, message);
  }

  public static info(tag: string, message: string): void {
    hilog.info(Logger._domain, Logger._prefix, Logger._format, tag, message);
  }

  public static warn(tag: string, message: string): void {
    hilog.warn(Logger._domain, Logger._prefix, Logger._format, tag, message);
  }

  public static error(tag: string, message: string): void {
    hilog.error(Logger._domain, Logger._prefix, Logger._format, tag, message);
  }
}
