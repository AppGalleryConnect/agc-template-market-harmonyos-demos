import { Logger } from '../common/Logger';

export enum RouterMap {
  // 入口
  MAIN = 'Main', // 元服务入口页面

  // 首页
  GOOD_DETAIL = 'GoodDetail', // 商品详情页
  BOOK_GOOD = 'BookGood', // 立即预约下单页
  SINGLE_CARD_DETAIL = 'SingleCardDetail', // 次卡详情页
  GROUP_DETAIL = 'GroupDetail', // 团购详情页
  SUBMIT_ORDER = 'SubmitOrder', // 下单页
  SUCCESS_PAY = 'SuccessPay', // 下单成功页

  // 我的
  MY_APPOINTMENT_LIST = 'AppointmentList', // 预约列表管理
  MY_SINGLE_VISIT_LIST = 'SingleCardList', // 次卡列表管理
  MY_GROUP_LIST = 'GroupList', // 团购列表管理
  MY_BOOK_GROUP_DETAIL = 'BookGroupDetail', // 订单详情
}

export interface NavRouterInfo {
  url: string, // 需要跳转的路由名
  mode?: NavDestinationMode, // NavDestination类型
  param?: Object, // 跳转传参
}

export class RouterModule {
  public static stack: NavPathStack = new NavPathStack()
  public static urlMap: Record<string, string> = {}

  public static getStack(): NavPathStack {
    return RouterModule.stack;
  }

  // 跳转到指定路由栈的指定路由页面
  public static push(info: NavRouterInfo) {
    try {
      RouterModule.stack.pushPathByName(info.url, info.param);
    } catch (err) {
      Logger.info('navigation stack push failed::' + JSON.stringify(err));
    }
  }

  // 将指定路由栈的栈顶页面退出，将info指定的NavDestination页面信息入栈
  public static replace(info: NavRouterInfo) {
    try {
      RouterModule.stack.replacePathByName(info.url, info.param);
    } catch (err) {
      Logger.info('navigation stack replace failed::' + JSON.stringify(err));
    }
  }

  // 弹出栈顶元素
  public static pop(animated?: boolean) {
    try {
      RouterModule.stack.pop(animated);
    } catch (err) {
      Logger.info('navigation stack pop failed::' + JSON.stringify(err));
    }
  }

  // 回退路由栈到由栈底开始第一个名为name的NavDestination页面
  public static popToName(name: string, animated?: boolean) {
    try {
      RouterModule.stack.popToName(name, animated);
    } catch (err) {
      Logger.info('navigation stack pop to name failed::' + JSON.stringify(err));
    }
  }

  // 清除栈中的所有页面
  public static clear(animated?: boolean) {
    try {
      RouterModule.stack.clear(animated)
    } catch (err) {
      Logger.info('navigation stack clear failed::' + JSON.stringify(err))
    }
  }

  // 获取指定栈中指定页面的参数
  public static getNavParam<T>(info: NavRouterInfo): T[] {
    let params: T[] = [];
    try {
      params = RouterModule.stack.getParamByName(info.url) as T[];
    } catch (err) {
      Logger.info('navigation stack get params failed::' + JSON.stringify(err));
    }
    return params;
  }

  // 获取栈大小
  public static size() {
    return RouterModule.stack.size();
  }
}