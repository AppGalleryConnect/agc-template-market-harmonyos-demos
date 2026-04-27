/**
 * 窗口持久化
 */
@ObservedV2
export class WindowInfo {
  @Trace windowTopPadding: number = 40;
  @Trace windowBottomPadding: number = 28;
  @Trace windowWidth: number = 0; // 单位px
  @Trace windowHeight: number = 0; // 单位px
}