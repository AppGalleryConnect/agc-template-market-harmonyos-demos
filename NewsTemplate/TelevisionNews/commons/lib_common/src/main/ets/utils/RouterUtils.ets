import { UtilLog } from '@hw-agconnect/util-log';
import { RouterMap } from '../constants/RouterMap';

const TAG = '[RouterUtils]';

export enum StackEnum {
  Main = 'main',
}

/**
 * 路由管理类
 */
export class RouterUtils {
  /**
   * 路由栈Map
   */
  private static stackMap: Map<string, NavPathStack> = new Map([
    [StackEnum.Main, new NavPathStack()],
  ]);

  /**
   * 创建新栈
   * @param stackName
   * @returns
   */
  public static createStack(stackName: string, isNew: boolean = false) {
    if (!RouterUtils.stackMap.has(stackName) || isNew) {
      RouterUtils.stackMap.set(stackName, new NavPathStack());
    }
    return RouterUtils.getStack(stackName);
  }

  /**
   * 删除栈
   * @param stackName
   */
  public static deleteStack(stackName: string) {
    if (RouterUtils.stackMap.has(stackName)) {
      RouterUtils.stackMap.delete(stackName);
    }
  }

  /**
   * 获取栈
   * @returns
   */
  public static getStack(name?: string): NavPathStack {
    if (name) {
      return RouterUtils.stackMap.get(name) || new NavPathStack();
    }
    return RouterUtils.stackMap.get(StackEnum.Main) || new NavPathStack();
  }

  /**
   * 跳转页面
   * @param name
   * @param param
   * @param onPop
   * @param animated
   */
  public static pushPathByName(name: RouterMap, param: Object | null = null, onPop?: Callback<PopInfo>,
    animated: boolean = true, stackName: string = StackEnum.Main) {
    UtilLog.info(TAG, `RouterUtil route: ${name}, param: ${JSON.stringify(param)}`);
    if (onPop) {
      RouterUtils.getStack(stackName).pushPathByName(name, param, onPop, animated);
    } else {
      RouterUtils.getStack(stackName).pushPathByName(name, param, animated);
    }
  }

  /**
   * 更换页面
   * @param name
   * @param param
   * @param animated
   */
  public static replacePathByName(name: RouterMap, param: Object | null = null, animated: boolean = true,
    stackName: string = StackEnum.Main) {
    RouterUtils.getStack(stackName).replacePathByName(name, param, animated);
  }

  /**
   * 返回上一级
   * @param result
   * @param animated
   */
  public static pop(result?: Object, animated?: boolean, stackName: string = StackEnum.Main) {
    if (result) {
      RouterUtils.getStack(stackName).pop(result, animated);
    } else {
      RouterUtils.getStack(stackName).pop(animated);
    }
  }

  /**
   * 返回指定页面
   * @param name
   * @param result
   * @param animated
   */
  public static popToName(name: RouterMap, result?: Object, animated?: boolean, stackName: string = StackEnum.Main) {
    if (result) {
      RouterUtils.getStack(stackName).popToName(name, result, animated);
    } else {
      RouterUtils.getStack(stackName).popToName(name, animated);
    }
  }

  /**
   * 获取路由参数
   * @param name
   * @returns
   */
  public static getParamByName<T>(name: RouterMap, stackName: string = StackEnum.Main): T | null {
    const params = RouterUtils.getStack(stackName).getParamByName(name) as T[];
    if (params.length && params[params.length - 1]) {
      return params[params.length - 1];
    }
    return null;
  }

  /**
   * 获取栈中当前页面名称
   * @param stackName
   * @returns
   */
  public static getLastPathName(stackName: string = StackEnum.Main) {
    const allPathNames = RouterUtils.getStack(stackName).getAllPathName();
    return allPathNames.length > 0 ? allPathNames[allPathNames.length - 1] : '';
  }

  /**
   * 清空栈
   */
  public static clearStack(animated?: boolean, stackName: string = StackEnum.Main) {
    RouterUtils.getStack(stackName).clear(animated);
  }
}
