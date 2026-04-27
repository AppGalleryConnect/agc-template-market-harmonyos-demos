import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static domain: number = 0xff00;
  private static prefix: string = 'drawer';
  private static format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
  }

  public static error(...args: string[]): void {
  }
}
