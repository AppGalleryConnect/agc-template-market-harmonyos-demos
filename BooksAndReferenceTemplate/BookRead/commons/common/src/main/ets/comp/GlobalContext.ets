import { common } from '@kit.AbilityKit';

export class GlobalContext {
  private static context: common.UIAbilityContext;

  public static initContext(context: common.UIAbilityContext): void {
    GlobalContext.context = context;
  }

  public static getContext(): common.UIAbilityContext {
    return GlobalContext.context;
  }
}