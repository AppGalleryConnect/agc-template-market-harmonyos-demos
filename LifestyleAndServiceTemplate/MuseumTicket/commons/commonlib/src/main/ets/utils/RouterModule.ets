import { DialogMap, RouterMap } from '../constants/CommonEnums';
import { Logger } from './Logger';

const TAG: string = '[RouterModule]';

export class RouterModule {
  private static _stack: NavPathStack = new NavPathStack();

  public static getStack() {
    return RouterModule._stack;
  }

  // 跳转到指定路由栈的指定路由页面
  public static push(info: NavRouterInfo, animated?: boolean) {
    try {
      RouterModule._stack.pushPathByName(info.url, info.param, animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack push failed::' + JSON.stringify(err));
    }
  }

  // 将指定路由栈的栈顶页面退出，将info指定的NavDestination页面信息入栈
  public static replace(info: NavRouterInfo) {
    try {
      RouterModule._stack.replacePathByName(info.url, info.param);
    } catch (err) {
      Logger.error(TAG, 'navigation stack replace failed::' + JSON.stringify(err));
    }
  }

  // 弹出栈顶元素
  public static pop(animated?: boolean) {
    try {
      RouterModule._stack.pop(animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack pop failed::' + JSON.stringify(err));
    }
  }

  // 回退路由栈到由栈底开始第一个名为name的NavDestination页面
  public static popToName(name: string, animated?: boolean) {
    try {
      RouterModule._stack.popToName(name, animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack pop to name failed::' + JSON.stringify(err));
    }
  }

  // 清除栈中的所有页面
  public static clear(animated?: boolean) {
    try {
      RouterModule._stack.clear(animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack clear failed::' + JSON.stringify(err));
    }
  }

  // 获取指定栈中指定页面的参数,不支持栈内存在多个同名页面的情况
  public static getNavParam<T>(info: NavRouterInfo): T | undefined {
    try {
      const paramsArr = RouterModule._stack.getParamByName(info.url) as T[] | undefined[];
      if (paramsArr.length && paramsArr[0]) {
        return paramsArr[0];
      }
    } catch (err) {
      Logger.error(TAG, 'navigation stack get params failed::' + JSON.stringify(err));
    }
    return undefined;
  }

  // 获取栈大小
  public static size() {
    return RouterModule._stack.size();
  }
}

export interface NavRouterInfo {
  url: RouterMap | DialogMap;

  mode?: NavDestinationMode;

  param?: ESObject;

  page?: Object;
}


