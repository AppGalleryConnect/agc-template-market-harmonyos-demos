import { Constants } from '../constant/Constants';
import { UserInfo } from '../model/UserInfo';

export class TCRouter {
  private static pathStack: NavPathStack;

  public static init() {
    TCRouter.pathStack = new NavPathStack();
  }

  public static push(name: string, params?: ESObject) {
    TCRouter.pathStack.pushPathByName(name, params);
  }

  public static pushByLogin(name: string, params?: ESObject) {
    const userInfo = AppStorage.get<UserInfo>('userInfo');
    if (userInfo === undefined) {
      // 未登录 需进入登录页面
      TCRouter.pathStack.pushPathByName(Constants.LOGIN_ROUTE, params)
    } else {
      TCRouter.pathStack.pushPathByName(name, params);
    }
  }

  public static pop() {
    TCRouter.pathStack.pop();
  }

  public static replace(name: string, params?: ESObject) {
    TCRouter.pathStack.replacePathByName(name, params);
  }

  public static getStack(): NavPathStack {
    return TCRouter.pathStack;
  }

  public static getParams<T>(name: string): T | undefined {
    const p: T[] = TCRouter.pathStack.getParamByName(name) as T[];
    if (p.length) {
      return p[p.length - 1];
    }

    return undefined;
  }
}