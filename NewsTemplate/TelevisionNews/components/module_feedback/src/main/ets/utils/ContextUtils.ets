import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[FeedbackContextUtils]';

export class ContextUtils {
  private static uiContext: UIContext | undefined = undefined;
  private static context: Context | undefined = undefined;

  public static setUIContext(uiContext: UIContext) {
    ContextUtils.uiContext = uiContext;
    ContextUtils.context = ContextUtils.uiContext?.getHostContext();
  }

  public static get globalUIContext() {
    return this.uiContext as UIContext;
  }

  public static get globalContext() {
    return ContextUtils.context as Context;
  }

  public static get globalUIAbilityContext() {
    return ContextUtils.context as common.UIAbilityContext;
  }

  public static showToast(options: promptAction.ShowToastOptions) {
    try {
      ContextUtils.globalUIContext?.getPromptAction().showToast(options);
    } catch (error) {
      UtilLog.error(TAG, 'showToast fail, error: ' + JSON.stringify(error));
    }
  }
}