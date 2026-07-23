import type common from '@ohos.app.ability.common';
import { UIContext, window } from '@kit.ArkUI';

export class GlobalContext {
  private static context: common.UIAbilityContext;
  private static windowStage: window.WindowStage;

  public static initContext(context: common.UIAbilityContext, windowStage: window.WindowStage): void {
    GlobalContext.context = context;
    GlobalContext.windowStage = windowStage;
  }

  public static getContext(): common.UIAbilityContext {
    return GlobalContext.context;
  }

  public static getWindowStage(): window.WindowStage {
    return GlobalContext.windowStage;
  }

  public static getUIContext(): UIContext {
    return GlobalContext.getWindowStage().getMainWindowSync().getUIContext();
  }
}