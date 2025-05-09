import hilog from '@ohos.hilog';

const LOG_DOMAIN = 0x000221

const LOG_TAG = 'TReader';

export class TCLogger {
  public static info(format: string, ...args: ESObject[]) {
    hilog.info(LOG_DOMAIN, LOG_TAG, format, args);
  }

  public static debug(format: string, ...args: ESObject[]) {
    hilog.debug(LOG_DOMAIN, LOG_TAG, format, args);
  }

  public static warn(format: string, ...args: ESObject[]) {
    hilog.warn(LOG_DOMAIN, LOG_TAG, format, args);
  }

  public static error(format: string, ...args: ESObject[]) {
    hilog.error(LOG_DOMAIN, LOG_TAG, format, args);
  }
}