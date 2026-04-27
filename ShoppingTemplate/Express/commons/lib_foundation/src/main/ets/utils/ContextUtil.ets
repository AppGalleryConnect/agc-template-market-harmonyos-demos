import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';

const TAG = '[ContextUtils]';

class ContextUtil {
  private contextMap: Map<string, UIContext> = new Map();
  private _uiContext: UIContext | undefined;
  private _context: Context | undefined;

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
    this._uiContext = this.contextMap.get(abilityName);
    this._context = this._uiContext?.getHostContext();
  }

  /**
   * 获取全局UIContext
   * @returns
   */
  public get globalUIContext() {
    return this._uiContext as UIContext;
  }

  /**
   * 获取全局Context
   * @returns
   */
  public get globalContext() {
    return this._context as Context;
  }

  /**
   * 获取全局UIAbilityContext
   * @returns
   */
  public get globalUIAbilityContext() {
    return this._context as common.UIAbilityContext;
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

const instance = new ContextUtil();

export { instance as ContextUtil };