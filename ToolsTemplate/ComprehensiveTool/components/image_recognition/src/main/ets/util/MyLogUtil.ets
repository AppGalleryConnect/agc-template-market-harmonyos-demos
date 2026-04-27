import { UtilLog } from '@hw-agconnect/util-log';

export class MyLog {
  private static format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
    UtilLog.info(MyLog.format, args);
  }

  public static error(...args: string[]): void {
    UtilLog.error(MyLog.format, args);
  }
}
