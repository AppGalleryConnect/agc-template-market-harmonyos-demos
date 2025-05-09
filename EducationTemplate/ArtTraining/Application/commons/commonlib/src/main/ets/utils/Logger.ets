import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static _domain: number = 0xff00;
  private static _prefix: string = 'ArtTraining';
  private static _format: string = '%{public}s, %{public}s';

  public static debug(...args: string[]): void {
    hilog.debug(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static info(...args: string[]): void {
    hilog.info(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static warn(...args: string[]): void {
    hilog.warn(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(Logger._domain, Logger._prefix, Logger._format, args);
  }
}
