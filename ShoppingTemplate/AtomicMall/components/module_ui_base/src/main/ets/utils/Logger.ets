import { UtilLog } from '@hw-agconnect/util-log';

class Logger {
  constructor() {
    UtilLog.setGlobalConfig({
      tag: '[ComprehensiveMall]',
      domain: 0xff00,
      open: true,
      showStack: true,
      showBorder: true,
      showDivider: true,
    });
  }

  public debug(...args: string[]): void {
    UtilLog.debug(args);
  }

  public info(...args: string[]): void {
    UtilLog.info(args);
  }

  public warn(...args: string[]): void {
    UtilLog.warn(args);
  }

  public error(...args: string[]): void {
    UtilLog.error(args);
  }
}

const logger = new Logger();

export { logger as Logger };