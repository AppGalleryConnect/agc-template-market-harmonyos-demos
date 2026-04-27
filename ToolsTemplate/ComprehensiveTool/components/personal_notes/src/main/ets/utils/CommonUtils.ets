export class CommonUtils {
  static sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  // [Start scroll_animation]
  static scrollAnimation(scroller: Scroller, duration: number, scrollHeight: number): void {
    scroller.scrollTo({
      xOffset: 0,
      yOffset: (scroller.currentOffset().yOffset + scrollHeight),
      animation: {
        duration: duration,
        curve: Curve.Smooth,
        canOverScroll: false
      }
    });
  }
  // [End scroll_animation]
}

