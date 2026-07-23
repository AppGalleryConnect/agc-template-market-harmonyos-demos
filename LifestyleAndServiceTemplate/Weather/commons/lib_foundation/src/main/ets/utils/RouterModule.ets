import { Logger } from './Logger';

export interface NavRouterInfo<T = undefined> {
  // 跳转路由名
  url: string;

  // NavDestination类型
  mode?: NavDestinationMode;

  // 传递参数
  param?: T;

  // 回调事件
  onPop?: Callback<PopInfo>;
}

const TAG = '[RouterModule]';

export class RouterModule {
  public static stack: NavPathStack = new NavPathStack();

  // 页面跳转(指定页面)
  public static push<T = undefined>(info: NavRouterInfo<T>, animated?: boolean) {
    try {
      RouterModule.stack.pushPathByName(info.url, info.param, info.onPop, animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack push failed::' + JSON.stringify(err));
    }
  }

  // 页面替换(指定页面)
  public static replace<T = undefined>(info: NavRouterInfo<T>, animated?: boolean) {
    try {
      RouterModule.stack.replacePathByName(info.url, info.param, animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack replace failed::' + JSON.stringify(err));
    }
  }

  // 页面回退(上个页面)
  public static pop(animated?: boolean) {
    try {
      RouterModule.stack.pop(animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack pop failed::' + JSON.stringify(err));
    }
  }

  // 页面回退(携带参数)
  public static popWithRes<T>(res: T, animated?: boolean) {
    try {
      RouterModule.stack.pop(res as Object, animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack pop failed::' + JSON.stringify(err));
    }
  }

  // 页面回退(至对应页面名)
  public static popToName(name: string, animated?: boolean) {
    try {
      return RouterModule.stack.popToName(name, animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack pop to name failed::' + JSON.stringify(err));
      return -1;
    }
  }

  // 页面栈清空(回Navigation)
  public static clear(animated?: boolean) {
    try {
      RouterModule.stack.clear(animated);
    } catch (err) {
      Logger.error(TAG, 'navigation stack clear failed::' + JSON.stringify(err));
    }
  }

  // 获取页面栈大小
  public static size(): number {
    return RouterModule.stack.size();
  }

  // 获取参数(指定页面)
  public static getNavParam<T>(info: NavRouterInfo): T | undefined {
    try {
      const paramsArr = RouterModule.stack.getParamByName(info.url) as T[] | undefined[];
      return paramsArr.pop();
    } catch (err) {
      Logger.error(TAG, 'navigation stack get params failed::' + JSON.stringify(err));
    }
    return undefined;
  }

  // 获取页面名(前页面)
  public static getPrePage(): string | undefined {
    const pathNames = RouterModule.stack.getAllPathName();
    pathNames.pop();
    return pathNames.pop();
  }

  // 获取页面名(当前页面)
  public static getNowPage(): string | undefined {
    const pathNames = RouterModule.stack.getAllPathName();
    return pathNames.pop();
  }
}