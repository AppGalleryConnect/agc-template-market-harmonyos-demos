import router from '@ohos.router';
import { BaseRouterOption, NavRouterOption, RouterType } from './RouterConfig';
import { Logger } from "../logger/AppLogger";
import { OptionActionClient } from './option/OptionActionClient';
import { WindowManager } from "../utils/WindowManager";
import { window } from '@kit.ArkUI';
import { NavParams } from './NavParams';

export enum NavRouterActionType {
  PUSH = 0, // 进入
  REPLACE = 1, // 重置
  POP = 2 // 返回
}

export enum PageRegisterLoadStatus {
  REGISTER_BY_FUNCTION_OK,
  REGISTER_BY_URL_OK,
  REGISTER_FAIL
}

export interface navStackActionOptions {
  name: string,
  params?: object,
  animated?: boolean,
  popCallback?: (popInfo: any) => void
}

const TAG = 'AppRouter';

export function routerInterceptor(target: any, propertyKey: string,
  descriptor: PropertyDescriptor): PropertyDescriptor {
  const originalMethod = descriptor.value;

  descriptor.value = async function (...args: any[]): Promise<boolean> {
    let options: BaseRouterOption = args[0];
    let optionActionClient = appRouter.optionActionClient;
    if (!optionActionClient) {
      return await originalMethod.apply(this, args);
    }
    if (options.routerType === RouterType.POP) {
      let res = await originalMethod.apply(this, args);
      optionActionClient.execute(options)
      return res;
    }
    if (options.routerType === RouterType.PUSH || options.routerType === RouterType.REPLACE) {
      return (await optionActionClient.execute(options)) && (await originalMethod.apply(this, args));
    }
    return false;
  };
  return descriptor;
}

class AppRouter {
  optionActionClient?: OptionActionClient;
  windowStage: window.WindowStage = AppStorage.get('windowStage')

  private navStackAction?: (actionType: NavRouterActionType, options: navStackActionOptions) => boolean;
  systemBarProperties?: window.SystemBarProperties;

  /**
   * 注册navStackAction
   * @param navStackAction navStackAction.
   */
  public setNavStackAction(navStackAction: (actionType: NavRouterActionType,
    options: navStackActionOptions) => boolean): void {
    this.navStackAction = navStackAction;
  }

  public setNavPathStack(navPathStack: any): void {
    NavParams.setNavPathStack(navPathStack);
  }

  /**
   * 打开新页面
   * 注意：params中传递变量为引用传递，如果被@state等装饰器修饰，则存在反向修改跳转起始页的情况
   * @param options Options.
   */
  public async push(options: NavRouterOption, isAnimated: boolean = true): Promise<boolean> {
    if (options && options.builderName) {
      options.routerType = RouterType.PUSH;
      return this.navPageByPushOrReplace(options, false, isAnimated);
    }
    return false;
  }

  /**
   * 用新页面替换当前页面
   * @param options Options.
   */
  public async replace(options: NavRouterOption, isAnimated: boolean = true): Promise<boolean> {
    if (options && options.builderName) {
      options.routerType = RouterType.REPLACE;
      return this.navPageByPushOrReplace(options, true, isAnimated);
    }
    return false;
  }

  /**
   * 关闭当前页面
   * @param options Options.
   */
  public async back(isNav: boolean = true, options?: NavRouterOption): Promise<void> {
    if (options?.styleOption?.restoreSystemBarStyle && this.systemBarProperties) {
      WindowManager.setWindowSystemBarProperties(this.systemBarProperties);
    }
    if (isNav) {
      if (options) {
        options.routerType = RouterType.POP;
      }
      this.navPagePop(options || {
        routerType: RouterType.POP
      });
      return;
    }
    if (!options) {
      this.windowStage.getMainWindowSync().getUIContext().getRouter().back();
      return;
    }
  }

  @routerInterceptor
  private async navPagePop(options?: NavRouterOption, isAnimated: boolean = true): Promise<void> {
    if (this.navStackAction) {
      this.navStackAction(NavRouterActionType.POP, {
        name: options?.builderName,
        params: options?.params,
        animated: isAnimated,
      });
    }
  }

  @routerInterceptor
  private async navPageByPushOrReplace(options: NavRouterOption,
    byReplace: boolean, isAnimated: boolean = true): Promise<boolean> {
    try {
      if (this.navStackAction) {
        if (this.navStackAction(byReplace ? NavRouterActionType.REPLACE : NavRouterActionType.PUSH,
          {
            name: options.builderName,
            params: options.params,
            animated: isAnimated,
            popCallback: options.popCallback
          })) {
          return true;
        }
      }
    } catch (e) {
      Logger.error(TAG, 'navPage err: ' + e.message);
    }
    return false;
  }
}

const appRouter = new AppRouter();

export { appRouter }
