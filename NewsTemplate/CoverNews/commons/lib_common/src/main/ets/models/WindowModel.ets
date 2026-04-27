/**
 * 窗口模型
 */
@ObservedV2
export class WindowModel {
  @Trace windowTopPadding: number = 40;
  @Trace windowBottomPadding: number = 28;

  /**
   * 设置顶部避让padding
   * @param value
   */
  public setWindowTopPadding(value: number): void {
    this.windowTopPadding = value;
  }

  /**
   * 设置底部避让padding
   * @param value
   */
  public setWindowBottomPadding(value: number): void {
    this.windowBottomPadding = value;
  }
}