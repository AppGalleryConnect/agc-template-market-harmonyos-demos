/**
 * @fileType: common
 * @zhName: 全局上下文管理类
 */
import { common } from '@kit.AbilityKit';

export class GlobalContext {
  private static context: common.UIAbilityContext;
  private static _uiContext: UIContext;

  public static initUIAbilityContext(context: common.UIAbilityContext): void {
    GlobalContext.context = context;
  }

  public static getUIAbilityContext(): common.UIAbilityContext {
    return GlobalContext.context;
  }

  public static initUIContext(context: UIContext): void {
    GlobalContext._uiContext = context;
  }

  public static getUIContext(): UIContext {
    return GlobalContext._uiContext;
  }
}