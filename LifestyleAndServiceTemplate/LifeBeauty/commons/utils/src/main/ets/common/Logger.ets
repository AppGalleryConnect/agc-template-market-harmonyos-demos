import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static domain: number = 0xFF00;
  private static prefix: string = '[MeiYeTemplate]';
  private static format: string = '%{public}s';

  static debug(...args: Object[]): void {
    hilog.debug(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static info(...args: Object[]): void {
    hilog.info(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static warn(...args: Object[]): void {
    hilog.warn(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static error(...args: Object[]): void {
    hilog.error(Logger.domain, Logger.prefix, Logger.format, args);
  }
}
