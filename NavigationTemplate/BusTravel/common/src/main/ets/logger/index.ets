import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static domain: number = 0xFF00;
  private static prefix: string = 'smartRouteTemplate';
  private static format: string = '%{public}s, %{public}s';

  static debug(...args: string[]): void {
    hilog.debug(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static info(...args: string[]): void {
    hilog.info(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static warn(...args: string[]): void {
    hilog.warn(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static error(...args: string[]): void {
    hilog.error(Logger.domain, Logger.prefix, Logger.format, args);
  }
}