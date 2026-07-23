import { UtilLog } from '@hw-agconnect/util-log';
import { promptAction } from '@kit.ArkUI';

const TAG = '[ToastUtils]'

export class ToastUtils {
  private static uiContext: UIContext | undefined = undefined;

  /**
   * 设置context
   * @param uiContext
   */
  public static setContext(uiContext: UIContext) {
    ToastUtils.uiContext = uiContext;
  }

  /**
   * 打开toast
   * @param options
   */
  public static showToast(options: promptAction.ShowToastOptions) {
    try {
      ToastUtils.uiContext?.getPromptAction().showToast(options);
    } catch (error) {
      UtilLog.error(TAG, 'showToast fail, error: ' + JSON.stringify(error));
    }
  }
}