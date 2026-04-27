export class ThrottleUtils {
  private static timers: Map<string, number> = new Map();

  /**
   * 节流执行
   * @param key 唯一标识
   * @param callback 回调函数
   * @param delay 延迟时间（毫秒）
   */
  static throttle(key: string, callback: () => void, delay: number = 300): void {
    // 清除之前的定时器
    const existingTimer = ThrottleUtils.timers.get(key);
    if (existingTimer !== undefined) {
      clearTimeout(existingTimer);
    }

    // 设置新的定时器
    const timer = setTimeout(() => {
      callback();
      ThrottleUtils.timers.delete(key);
    }, delay);

    ThrottleUtils.timers.set(key, timer);
  }

  /**
   * 立即执行并清除定时器
   * @param key 唯一标识
   */
  static clear(key: string): void {
    const timer = ThrottleUtils.timers.get(key);
    if (timer !== undefined) {
      clearTimeout(timer);
      ThrottleUtils.timers.delete(key);
    }
  }

  /**
   * 清除所有定时器
   */
  static clearAll(): void {
    ThrottleUtils.timers.forEach((timer) => {
      clearTimeout(timer);
    });
    ThrottleUtils.timers.clear();
  }
}