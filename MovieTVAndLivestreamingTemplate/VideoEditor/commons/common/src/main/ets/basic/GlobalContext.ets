import { common } from '@kit.AbilityKit';

export class GlobalContext {
  private static context: common.UIAbilityContext;
  private static uiContext: UIContext;

  public static initUIAbilityContext(context: common.UIAbilityContext): void {
    GlobalContext.context = context;
  }

  public static getUIAbilityContext(): common.UIAbilityContext {
    return GlobalContext.context;
  }

  public static initUIContext(context: UIContext): void {
    GlobalContext.uiContext = context;
  }

  public static getUIContext(): UIContext {
    return GlobalContext.uiContext;
  }
}