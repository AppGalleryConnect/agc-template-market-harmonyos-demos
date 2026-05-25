import { window } from '@kit.ArkUI';

export class PreviewUtils {
  static windowStage: window.WindowStage | undefined = undefined

  /**
   * 初始化WindowStage
   * 用于修改顶部状态栏颜色
   */
  public static initStage(windowStage: window.WindowStage) {
    PreviewUtils.windowStage = windowStage
  }
}