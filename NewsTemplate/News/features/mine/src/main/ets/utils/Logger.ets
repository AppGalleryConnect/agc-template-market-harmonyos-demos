import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Common log for all features.
 */
export class Logger {
  private domain: number;
  private prefix: string;
  private format: string = `%{public}s, %{public}s`;

  constructor(prefix: string) {
    this.prefix = prefix;
    this.domain = 0xFF00;
  }

  debug(...args: string[]) {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  info(...args: string[]) {
    hilog.info(this.domain, this.prefix, this.format, args);
  }

  warn(...args: string[]) {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  error(...args: string[]) {
    hilog.error(this.domain, this.prefix, this.format, args);
  }

  fatal(...args: string[]) {
    hilog.fatal(this.domain, this.prefix, this.format, args);
  }

  isLoggable(level: number) {
    hilog.isLoggable(this.domain, this.prefix, level);
  }
}

export default new Logger('[SetAppFontSize]');