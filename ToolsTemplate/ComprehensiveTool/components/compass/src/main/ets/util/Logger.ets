import { UtilLog } from '@hw-agconnect/util-log';

export class Logger {
  private domain: number;
  private prefix: string;
  private format: string = '%{public}s, %{public}s';

  constructor(prefix: string) {
    this.prefix = prefix;
    this.domain = 0xFF00;
  }

  debug(...args: string[]): void {
    UtilLog.debug(this.domain, this.prefix, this.format, args);
  }

  info(...args: string[]): void {
    UtilLog.info(this.domain, this.prefix, this.format, args);
  }

  warn(...args: string[]): void {
    UtilLog.warn(this.domain, this.prefix, this.format, args);
  }

  error(...args: string[]): void {
    UtilLog.error(this.domain, this.prefix, this.format, args);
  }

  fatal(...args: string[]): void {
    UtilLog.fatal(this.domain, this.prefix, this.format, args);
  }
}

export default new Logger('[compass]');