import { common } from '@kit.AbilityKit';

export class GlobalRegister {
  private static mContext: common.UIAbilityContext | null = null;

  public static init(mContext: common.UIAbilityContext) {
    GlobalRegister.mContext = mContext;
  }

  public static getContext() {
    return GlobalRegister.mContext;
  }
}