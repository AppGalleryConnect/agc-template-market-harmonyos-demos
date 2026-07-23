import type common from '@ohos.app.ability.common';
import { window } from '@kit.ArkUI';

export class GlobalContext {
  private static context: common.UIAbilityContext;
  private static windowStage: window.WindowStage;

  public static initContextWindowStage(context: common.UIAbilityContext, windowStage: window.WindowStage): void {
    GlobalContext.context = context;
    this.windowStage = windowStage
  }

  public static getContext(): common.UIAbilityContext {
    return GlobalContext.context;
  }

  public static getWindowStage(): window.WindowStage {
    return GlobalContext.windowStage;
  }
}