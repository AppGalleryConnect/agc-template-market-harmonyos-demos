import { common } from '@kit.AbilityKit';

export class ColorGlobalContext {
  private static context: common.UIAbilityContext;
  private static uiContext: UIContext;

  public static initUIAbilityContext(context: common.UIAbilityContext): void {
    ColorGlobalContext.context = context;
  }

  public static getUIAbilityContext(): common.UIAbilityContext {
    return ColorGlobalContext.context;
  }

  public static initUIContext(context: UIContext): void {
    ColorGlobalContext.uiContext = context;
  }

  public static getUIContext(): UIContext {
    return ColorGlobalContext.uiContext;
  }
}