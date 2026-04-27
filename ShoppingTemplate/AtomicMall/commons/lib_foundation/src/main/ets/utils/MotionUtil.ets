// motion (@kit.MultimodalAwarenessKit) is not supported in atomic service.
// Keeping stub class to preserve existing call-site compatibility.

@ObservedV2
export class MotionUtil {
  @Trace
  public static holdingHand: number = 0; // always default (not held)

  public static registerHoldingHandEvent() {
    // no-op in atomic service
  }

  public static unregisterHoldingHandEvent() {
    // no-op in atomic service
  }
}
