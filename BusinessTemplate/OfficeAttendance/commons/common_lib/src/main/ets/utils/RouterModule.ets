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
      if (info.onPop) {
        RouterModule._stack.pushPathByName(info.url, info.param, info.onPop, animated);
      } else {
        RouterModule._stack.pushPathByName(info.url, info.param, animated);
      }
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

  // 弹出栈顶元素
  public static popWithParam(result: Object, animated?: boolean) {
    try {
      RouterModule._stack.pop(result, animated);
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

  // 打开全局弹窗
  public static openDialog(name: DialogMap, param?: DialogInfo): void {
    const indexArr = RouterModule._stack.getIndexByName(name);
    if (indexArr.length) {
      Logger.info(TAG, 'dialog already exists::' + name);
      return;
    }
    try {
      RouterModule._stack.pushPath({
        name: name,
        param: param,
        onPop: (data: PopInfo) => {
          if (param?.onPop) {
            param.onPop!(data);
          }
        },
      });
    } catch (err) {
      Logger.error(TAG, `navigation stack open dialog [${name}] failed::` + JSON.stringify(err));
    }

  }

  // 关闭全局弹窗
  public static closeDialog(result?: DialogInfo) {
    try {
      RouterModule._stack.pop(result);
    } catch (err) {
      Logger.error(TAG, 'close dialog failed::' + JSON.stringify(err));
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
  public static getNavParam<T = ESObject>(info: NavRouterInfo): T | undefined {
    try {
      const paramsArr = RouterModule._stack.getParamByName(info.url) as T[] | undefined[];
      if (paramsArr.length) {
        return paramsArr[paramsArr.length - 1];
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
  page?: ESObject;
  onPop?: Callback<PopInfo>;
}

export interface DialogInfo {
  name?: DialogMap;
  param?: ESObject;
  onPop?: Callback<PopInfo>;
}
