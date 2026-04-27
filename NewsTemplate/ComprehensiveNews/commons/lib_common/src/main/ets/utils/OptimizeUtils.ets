import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[OptimizeUtils]';

export class OptimizeUtils {
  private static throttleTimeoutID: number | null = null;
  private static flag: boolean = false;

  /**
   * 同步函数防抖
   * @param func
   * @param delay
   */
  public static debounce(func: () => void, delay: number = 500) {
    if (OptimizeUtils.throttleTimeoutID !== null) {
      clearTimeout(OptimizeUtils.throttleTimeoutID);
    }
    OptimizeUtils.throttleTimeoutID = setTimeout(() => {
      func();
      OptimizeUtils.throttleTimeoutID = null;
    }, delay);
  }


  /**
   * 同步函数节流
   * @param func
   * @param wait
   */
  public static throttle(func: () => void, wait: number = 1000) {
    if (!OptimizeUtils.flag) {
      OptimizeUtils.flag = true;
      func();
      setTimeout(() => {
        OptimizeUtils.flag = false;
      }, wait);
    }
  }

  /**
   * 异步函数防抖
   * @param func 异步函数
   * @param delay 防抖延迟时间（毫秒），默认500ms
   * @returns Promise
   */
  public static debounceAsync(func: () => Promise<void>, delay: number = 500): Promise<void> {
    return new Promise((resolve, reject) => {
      if (OptimizeUtils.throttleTimeoutID !== null) {
        clearTimeout(OptimizeUtils.throttleTimeoutID);
      }
      OptimizeUtils.throttleTimeoutID = setTimeout(() => {
        func().then(() => {
          resolve();
        }).catch((error: BusinessError) => {
          reject(error);
        }).finally(() => {
          OptimizeUtils.throttleTimeoutID = null;
        });
      }, delay);
    });
  }

  /**
   * 异步函数节流
   * @param func 异步函数
   * @param wait 节流时间间隔（毫秒），默认2000ms
   * @returns Promise
   */
  public static throttleAsync(func: () => Promise<void>, wait: number = 2000): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!OptimizeUtils.flag) {
        OptimizeUtils.flag = true;
        func().then(() => {
          resolve();
        }).catch((error: BusinessError) => {
          reject(error);
        }).finally(() => {
          setTimeout(() => {
            OptimizeUtils.flag = false;
          }, wait);
        });
      } else {
        resolve();
      }
    });
  }
}