
export interface NavRouterInfo {
  url: string; // 需要跳转的路由名
  mode?: NavDestinationMode; // NavDestination类型
  param?: Object; // 跳转传参
  page?: Object;
}

export class AppRouter {
  public static navStack: NavPathStack = new NavPathStack();
  public static urlMap: Record<string, string> = {};

  // 跳转到指定路由栈的指定路由页面
  public static push(info: NavRouterInfo, animated?: boolean) {
    try {
      AppRouter.navStack.pushPathByName(info.url, info.param, animated);
    } catch (err) {
      // Logger.info('navigation stack push failed::' + JSON.stringify(err));
    }
  }

  // 将指定路由栈的栈顶页面退出，将info指定的NavDestination页面信息入栈
  public static replace(info: NavRouterInfo) {
    try {
      AppRouter.navStack.replacePathByName(info.url, info.param);
    } catch (err) {
      // Logger.info('navigation stack replace failed::' + JSON.stringify(err));
    }
  }

  // 弹出栈顶元素
  public static pop(popInfo?: Object, animated?: boolean) {
    try {
      AppRouter.navStack.pop(popInfo, animated);
    } catch (err) {
      // Logger.info('navigation stack pop failed::' + JSON.stringify(err));
    }
  }

  // 回退路由栈到由栈底开始第一个名为name的NavDestination页面
  public static popToName(name: string, animated?: boolean) {
    try {
      AppRouter.navStack.popToName(name, animated);
    } catch (err) {
      // Logger.info('navigation stack pop to name failed::' + JSON.stringify(err));
    }
  }

  // 清除栈中的所有页面
  public static clear(animated?: boolean) {
    try {
      AppRouter.navStack.clear(animated);
    } catch (err) {
      // Logger.info('navigation stack clear failed::' + JSON.stringify(err));
    }
  }

  // 获取指定栈中指定页面的参数
  public static getNavParam<T>(info: NavRouterInfo): T | undefined {
    try {
      const paramsArr = AppRouter.navStack.getParamByName(info.url) as T[] | undefined[];
      if (paramsArr.length) {
        const lastParam = paramsArr[paramsArr.length - 1];
        if (typeof lastParam !== 'undefined') {
          return lastParam;
        }
      }
    } catch (err) {
      // Logger.info('navigation stack get params failed::' + JSON.stringify(err));
    }
    return undefined;
  }

  // 获取栈大小
  public static size() {
    return AppRouter.navStack.size();
  }
}
