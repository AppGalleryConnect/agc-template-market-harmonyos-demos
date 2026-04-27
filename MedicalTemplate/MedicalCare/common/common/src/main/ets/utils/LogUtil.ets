import { hilog } from '@kit.PerformanceAnalysisKit';

export class LogUtil {
  private static logTag: string = 'LogUtil';
  private static domainId: number = 0x0000;

  public static debug(msg: string, logTag = this.logTag, domainId: number = this.domainId) {
    hilog.debug(domainId, logTag, msg);
  }

  public static info(msg: string, logTag = this.logTag, domainId: number = this.domainId) {
    hilog.info(domainId, logTag, msg);
  }

  public static warn(msg: string, logTag = this.logTag, domainId: number = this.domainId) {
    hilog.warn(domainId, logTag, msg);
  }

  public static error(msg: string, logTag = this.logTag, domainId: number = this.domainId) {
    hilog.error(domainId, logTag, msg);
  }

  public static fatal(msg: string, logTag = this.logTag, domainId: number = this.domainId) {
    hilog.fatal(domainId, logTag, msg);
  }
}