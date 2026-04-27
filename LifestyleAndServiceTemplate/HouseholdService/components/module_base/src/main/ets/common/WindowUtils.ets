import { common } from '@kit.AbilityKit';

export class WindowUtil {
  private static _context: Context | undefined;

  public static get context(): common.UIAbilityContext {
    return WindowUtil._context as common.UIAbilityContext;
  }

  private static _uiContext: UIContext;

  public static get uiContext(): UIContext {
    return WindowUtil._uiContext;
  }

  public static async initWindowUtil(uiContext: UIContext) {
    if (WindowUtil._uiContext) {
      return;
    }
    WindowUtil._uiContext = uiContext;
    WindowUtil._context = WindowUtil._uiContext.getHostContext();
  }
}