import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';

const TAG = '[ContextUtils]';

export class ContextUtils {
  private contextMap: Map<string, UIContext> = new Map();
  private uiContext: UIContext | undefined = undefined;
  private context: Context | undefined = undefined;

  /**
   * 设置context
   * @param uiContext
   */
  public setUIContext(abilityName: string, uiContext: UIContext) {
    this.contextMap.set(abilityName, uiContext);
    this.setActiveContext(abilityName);
  }

  /**
   * 设置激活状态的context
   * @param abilityName
   */
  public setActiveContext(abilityName: string) {
    this.uiContext = this.contextMap.get(abilityName);
    this.context = this.uiContext?.getHostContext();
  }

  /**
   * 获取全局UIContext
   * @returns
   */
  public get globalUIContext() {
    return this.uiContext as UIContext;
  }

  /**
   * 获取全局Context
   * @returns
   */
  public get globalContext() {
    return this.context as Context;
  }

  /**
   * 获取全局UIAbilityContext
   * @returns
   */
  public get globalUIAbilityContext() {
    return this.context as common.UIAbilityContext;
  }

  /**
   * 打开toast
   * @param options
   */
  public showToast(options: promptAction.ShowToastOptions) {
    try {
      this.globalUIContext?.getPromptAction().showToast(options);
    } catch (error) {
      Logger.error(TAG, 'showToast fail, error: ' + JSON.stringify(error));
    }
  }
}

const instance = new ContextUtils();

export { instance as GlobalContextUtils };