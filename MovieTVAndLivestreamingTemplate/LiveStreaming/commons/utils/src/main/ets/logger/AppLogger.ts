import { hilog } from "@kit.PerformanceAnalysisKit";

export enum LogLevelType {
  DEBUG = 0,
  INFO,
  WARN,
  ERROR
}

const TAG = "AppLogger"

class Logger {
  i(tag: string, format: string, ...args: any[]): void {
  }

  e(tag: string, format: string, ...args: any[]): void {
  }

  w(tag: string, format: string, ...args: any[]): void {
  }

  d(tag: string, format: string, ...args: any[]): void {
  }

  flush(): void {
  }
}

class HiLogger extends Logger {
  domain: number = 0x1234

  i(tag: string, format: string, ...args: any[]): void {
    hilog.info(this.domain, tag, format, args)
  }

  e(tag: string, format: string, ...args: any[]): void {
    hilog.error(this.domain, tag, format, args)
  }

  w(tag: string, format: string, ...args: any[]): void {
    hilog.warn(this.domain, tag, format, args)
  }

  d(tag: string, format: string, ...args: any[]): void {
    hilog.debug(this.domain, tag, format, args)
  }

  flush(): void {
  }
}

class AppLogger {
  // 日志应用层级APP_TAG长度不能超7
  private static readonly APP_TAG: string = 'AllianceApp';
  private static readonly LOG_FORMAT_SIZE: number = 1020;
  private static readonly LOG: Logger = new HiLogger();
  // 日志截断的开关；false为关闭（默认）；true为打开
  private static truncationOnOff = false;

  private constructor() {
  }

  /*
   * @brief:日志截断的开关设置
   * @param onOff：开发
   */
  public static setTruncationOnOff(onOff: boolean): void {
    AppLogger.truncationOnOff = onOff;
  }

  public static info(tag: string, format: string, ...args: any[]): void {
    // 防止format 传入undefined，直接规避掉
    if (!format) {
      return;
    }
    // 获取拼接的tag
    const newTag = AppLogger.tagJoint(tag);
    if (AppLogger.truncationOnOff) {
      let res = AppLogger.formatReplace(format, ...args);
      let num = AppLogger.formatSplit(res);
      for (let i = 0; i < num; i++) {
        const newFormat = res?.slice(i * AppLogger.LOG_FORMAT_SIZE, (i + 1) * AppLogger.LOG_FORMAT_SIZE);
        AppLogger.LOG.i(newTag, newFormat);
      }
    } else {
      AppLogger.LOG.i(newTag, format, ...args);
    }
  }

  public static warn(tag: string, format: string, ...args: any[]): void {
    // 防止format 传入undefined，直接规避掉
    if (!format) {
      return;
    }
    const newTag = AppLogger.tagJoint(tag);
    if (AppLogger.truncationOnOff) {
      let res = AppLogger.formatReplace(format, ...args);
      let num = AppLogger.formatSplit(res);
      for (let i = 0; i < num; i++) {
        const newFormat = res?.slice(i * AppLogger.LOG_FORMAT_SIZE, (i + 1) * AppLogger.LOG_FORMAT_SIZE);
        AppLogger.LOG.w(newTag, newFormat);
      }
    } else {
      AppLogger.LOG.w(newTag, format, ...args);
    }
  }

  public static error(tag: string, format: string, ...args: any[]): void {
    // 防止format 传入undefined，直接规避掉
    if (!format) {
      return;
    }
    const newTag = AppLogger.tagJoint(tag);
    if (AppLogger.truncationOnOff) {
      let res = AppLogger.formatReplace(format, ...args);
      let num = AppLogger.formatSplit(res);
      for (let i = 0; i < num; i++) {
        const newFormat = res?.slice(i * AppLogger.LOG_FORMAT_SIZE, (i + 1) * AppLogger.LOG_FORMAT_SIZE);
        AppLogger.LOG.e(newTag, newFormat);
      }
    } else {
      AppLogger.LOG.e(newTag, format, ...args);
    }
  }

  public static debug(tag: string, format: string, ...args: any[]): void {
    // 防止format 传入undefined，直接规避掉
    if (!format) {
      return;
    }
    const newTag = AppLogger.tagJoint(tag);
    if (AppLogger.truncationOnOff) {
      let res = AppLogger.formatReplace(format, ...args);
      let num = AppLogger.formatSplit(res);
      for (let i = 0; i < num; i++) {
        const newFormat = res?.slice(i * AppLogger.LOG_FORMAT_SIZE, (i + 1) * AppLogger.LOG_FORMAT_SIZE);
        AppLogger.LOG.d(newTag, newFormat);
      }
    } else {
      AppLogger.LOG.d(newTag, format, ...args);
    }
  }

  /**
   * 日志缓存默认是50ms后写入到文件中，为了避免应用退出时可能丢失最后50ms的日志，
   */
  public static flush(): void {
    try {
      AppLogger.LOG.flush();
    } catch (error) {
      AppLogger.error(TAG, "Logger flush error!");
    }
  }

  /*
   * @brief:tag词条拼接
   * @param tag：日志传入的tag
   * @return 拼接tag
   */
  private static tagJoint(tag: string): string {
    return AppLogger.APP_TAG + "_" + tag;
  }

  /*
   * @brief:过长的format分段
   * @param format：日志传入的字符串
   * @return 分段的个数
   */
  private static formatSplit(format: string): number {
    // 向上取整，0.1结果为1
    const splitNum = Math.ceil(format.length / AppLogger.LOG_FORMAT_SIZE);
    return splitNum || 0;
  }

  /*
   * @brief:format和args的格式化字符串拼接
   * @param format：日志传入的字符串
   * @param args：格式化字符串对应的参数列表%s %d %i %o %O
   * @return 拼接完的字符串
   */
  private static formatReplace(format: string, ...args: any[]): string {
    let res = format;
    // 首先需要做字符串拼接
    for (let i = 0; i < args.length; i++) {
      // 找到%，然后替换%以及后面的一个字符
      res = res.replace(/%[sdioO]/, '' + args[i]);
    }
    return res;
  }
}

export { AppLogger as Logger }