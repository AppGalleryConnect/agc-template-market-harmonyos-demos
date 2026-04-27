@ObservedV2
export class CountDownVM {
  timers: Map<string, number> = new Map();
  static _instance: CountDownVM;

  static get instance() {
    if (CountDownVM._instance) {
      return CountDownVM._instance;
    }
    CountDownVM._instance = new CountDownVM();
    return CountDownVM._instance;
  }


  /**
   * 停止倒计时
   */
  stopCountdown(id: string): void {
    const timerId = this.timers.get(id);
    if (timerId !== undefined) {
      clearInterval(timerId);
      this.timers.delete(id);
    }
  }

  /**
   * 停止所有倒计时
   */
  stopAll(): void {
    for (const timerId of this.timers.values()) {
      clearInterval(timerId);
    }
    this.timers.clear();
  }


  /**
   * 启动倒计时
   */
  startCountdown(id: string, func: () => void): void {
    this.stopCountdown(id);
    const timerId = setInterval(() => {
      func();
    }, 1000);
    this.timers.set(id, timerId);
  }
}