import { UIContext } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { common } from '@kit.AbilityKit';

const TAG: string = '[RouterUtil]';

/**
 * 多 Ability 路由管理工具。
 * 为每个 Ability 维护独立的 NavPathStack，避免多窗口（如分屏）场景下路由互相干扰。
 *
 * 使用方式：
 *  1. 各 Ability 的根组件 aboutToAppear 中调用 registerStack 注册路由栈
 *  2. Ability 获得窗口焦点时调用 setActive 更新激活态
 *  3. 任意位置调用 routerUtil.push / routerUtil.pop 进行路由
 */
@ObservedV2
class RouterUtil {
  /** 当前是否处于应用内分屏状态，跨 Ability 响应式共享 */
  @Trace isSplitActive: boolean = false;
  /** ability 名称 → NavPathStack */
  private stackMap: Map<string, NavPathStack> = new Map();
  /** 当前激活的 ability 名称 */
  private activeAbilityName: string = '';

  /**
   * 注册指定 Ability 的路由栈。
   * 应在各 Ability 根组件的 aboutToAppear 中调用，注册后自动设为激活态。
   * @param abilityName Ability 名称，如 'EntryAbility'、'SecondAbility'
   * @param stack 该 Ability 对应的 NavPathStack 实例
   * @param uiContext 可选，传入后支持通过 UIContext 反查 ability 名称
   */
  public registerStack(abilityName: string, stack: NavPathStack, uiContext?: UIContext): void {
    this.stackMap.set(abilityName, stack);
    this.activeAbilityName = abilityName;
    UtilLog.info(TAG, `registerStack: ${abilityName}, active -> ${this.activeAbilityName}`);
  }

  /**
   * 设置当前激活的 Ability。
   * 应在 Ability 窗口获得焦点时调用（如 onWindowStageActive），与 WindowUtil.setActiveContext 配合使用。
   * @param abilityName 要激活的 Ability 名称
   */
  public setActive(abilityName: string): void {
    if (this.stackMap.has(abilityName)) {
      this.activeAbilityName = abilityName;
      UtilLog.info(TAG, `setActive: ${abilityName}`);
    } else {
      UtilLog.warn(TAG, `setActive: ability '${abilityName}' not registered`);
    }
  }

  /**
   * 通过 UIContext 反查对应的 Ability 名称。
   * @param uiContext UIContext 实例
   * @returns ability 名称，未注册时返回 undefined
   */
  public getAbilityName(uiContext: UIContext): string | undefined {
    const context = uiContext.getHostContext() as common.UIAbilityContext;
    return context.abilityInfo.name
  }

  /**
   * 获取指定（或当前激活）Ability 的 NavPathStack。
   * @param abilityName 可选，不传则使用激活态对应的栈
   * @returns NavPathStack 实例，找不到时返回 undefined
   */
  public getStack(abilityName?: string): NavPathStack | undefined {
    const name: string = abilityName !== undefined ? abilityName : this.activeAbilityName;
    const stack: NavPathStack | undefined = this.stackMap.get(name);
    if (stack === undefined) {
      UtilLog.warn(TAG, `getStack: ability '${name}' not found in stackMap`);
    }
    return stack;
  }

  /**
   * 入栈新页面。
   * @param pathInfo 页面路由信息（name + param）
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则路由到当前激活窗口
   */
  public push(pathInfo: NavPathInfo, animated: boolean = true, abilityName?: string): void {
    this.getStack(abilityName)?.pushPath(pathInfo, animated);
  }

  /**
   * 出栈当前页面。
   * @param result 可选，传递给上一个页面的返回值
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public pop(result?: Object, animated: boolean = true, abilityName?: string): void {
    this.getStack(abilityName)?.pop(result, animated);
  }

  /**
   * 替换栈顶页面（出栈当前页，入栈新页，无回退记录）。
   * @param pathInfo 新页面路由信息
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public replace(pathInfo: NavPathInfo, animated: boolean = true, abilityName?: string): void {
    this.getStack(abilityName)?.replacePath(pathInfo, animated);
  }

  /**
   * 退栈至指定页面名（保留该页面，弹出其上所有页面）。
   * @param name 目标页面的路由名称
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public popToName(name: string, animated: boolean = true, abilityName?: string): void {
    this.getStack(abilityName)?.popToName(name, animated);
  }

  /**
   * 清空指定 Ability 的路由栈（退回根页面）。
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public clear(animated: boolean = true, abilityName?: string): void {
    this.getStack(abilityName)?.clear(animated);
  }

  /**
   * 获取当前激活 Ability 的 NavPathStack，始终返回有效实例。
   * 供需要显式传入 NavPathStack 参数的组件使用。
   */
  public getActiveStack(): NavPathStack {
    const stack: NavPathStack | undefined = this.getStack();
    if (stack === undefined) {
      UtilLog.warn(TAG, 'getActiveStack: no active stack registered, returning empty stack');
      return new NavPathStack();
    }
    return stack;
  }

  /**
   * 将指定 Ability 的路由栈逐页复制到目标栈中。
   * 用于分屏场景：SecondAbility 启动时复制 EntryAbility 的完整路由历史，
   * 使两个窗口拥有相同的页面上下文，用户可在 SecondAbility 中自由导航切换商品。
   * @param fromAbilityName 源 Ability 名称
   * @param toStack 目标 NavPathStack
   */
  public cloneStackTo(fromAbilityName: string, toStack: NavPathStack): void {
    const fromStack: NavPathStack | undefined = this.getStack(fromAbilityName);
    if (fromStack === undefined || fromStack.size() === 0) {
      UtilLog.warn(TAG, `cloneStackTo: source stack '${fromAbilityName}' is empty or not found`);
      return;
    }
    const names: string[] = fromStack.getAllPathName();
    for (let i = 0; i < names.length; i++) {
      toStack.pushPath({ name: names[i], param: fromStack.getParamByIndex(i) as Object }, false);
    }
    UtilLog.info(TAG, `cloneStackTo: cloned ${names.length} pages from '${fromAbilityName}'`);
  }

  /**
   * 将指定 Ability 的路由栈迁移到目标 Ability 的路由栈。
   * 用于 EntryAbility 合并分屏时，将 SecondAbility 的浏览历史接管回主窗口。
   * @param fromAbilityName 源 Ability 名称
   * @param toAbilityName 目标 Ability 名称
   */
  public migrateStack(fromAbilityName: string, toAbilityName: string): void {
    const fromStack: NavPathStack | undefined = this.getStack(fromAbilityName);
    const toStack: NavPathStack | undefined = this.getStack(toAbilityName);
    if (fromStack === undefined || toStack === undefined) {
      UtilLog.warn(TAG, `migrateStack: stack not found, from='${fromAbilityName}' to='${toAbilityName}'`);
      return;
    }
    const names: string[] = fromStack.getAllPathName();
    toStack.clear(false);
    for (let i = 0; i < names.length; i++) {
      toStack.pushPath({ name: names[i], param: fromStack.getParamByIndex(i) as Object }, false);
    }
    UtilLog.info(TAG, `migrateStack: migrated ${names.length} pages from '${fromAbilityName}' to '${toAbilityName}'`);
  }

  /** 返回当前激活路由栈的深度（NavPathStack 同名代理） */
  public size(abilityName?: string): number {
    return this.getStack(abilityName)?.size() ?? 0;
  }

  // ── NavPathStack 同名代理方法 ──────────────────────────────────────────────
  // 以下方法与 NavPathStack 保持相同签名，使消费方无需修改调用代码。

  /** 入栈新页面（NavPathStack 同名代理） */
  public pushPath(info: NavPathInfo, animated?: boolean): void {
    this.getStack()?.pushPath(info, animated);
  }

  /** 按名称入栈（NavPathStack 同名代理） */
  public pushPathByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.pushPathByName(name, param, animated);
  }

  /** 替换栈顶页面（NavPathStack 同名代理） */
  public replacePath(info: NavPathInfo, animated?: boolean): void {
    this.getStack()?.replacePath(info, animated);
  }

  /** 按名称替换栈顶（NavPathStack 同名代理） */
  public replacePathByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.replacePathByName(name, param, animated);
  }

  /** 按名称入栈（pushPathByName 别名，供统一风格调用） */
  public pushByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.pushPathByName(name, param, animated);
  }

  /** 按名称替换栈顶（replacePathByName 别名，供统一风格调用） */
  public replaceByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.replacePathByName(name, param, animated);
  }
}

/** 全局路由工具单例 */
export const routerUtil: RouterUtil = new RouterUtil();
