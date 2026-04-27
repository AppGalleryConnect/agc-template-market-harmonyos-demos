import { Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger, RouterMap, RouterModule } from 'lib_foundation';
import { PageRouterModel } from '../types';

export class WantUtils {
  public static pageRouter: PageRouterModel = AppStorageV2.connect(PageRouterModel, () => new PageRouterModel())!;

  public static handleWant(want: Want) {
    // 参数解析
    let params = want?.parameters;
    // 桌面快捷方式
    if (params?.shortCutKey) {
      switch (params.shortCutKey) {
        case 'ExpressPage':
          WantUtils.pageRouter.shortcutId = Date.now().toString();
          WantUtils.pageRouter.shortcutPageUrl = RouterMap.EXPRESS_PAGE;
          break;
      }
      return;
    }
    // 推送消息
    if (params?.push_wantAgentInfo) {
      notificationManager.getActiveNotificationCount().then((data: number) => {
        const badgeNum = data > 0 ? data - 1 : 0;
        notificationManager.setBadgeNumber(badgeNum).then(() => {
          Logger.info(`Succeeded in setting badge number.`);
        }).catch((err: BusinessError) => {
          Logger.error(`Failed to set badge number. Code is ${err.code}, message is ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to get active notification count. error: ${JSON.stringify(err)}`);
      });
    }
    // 服务卡片
    if (params?.source === 'FormCard') {
      WantUtils.pageRouter.formCardId = Date.now().toString();
      const pageUrl = params?.pageUrl && typeof params.pageUrl === 'string' ? params.pageUrl : '';
      const extraParam = params?.extraParam && typeof params.extraParam === 'string' ? params.extraParam : '';
      WantUtils.pageRouter.formCardPageUrl = pageUrl
      WantUtils.pageRouter.pageParam = extraParam
      return;
    }
  }

  // 跳转到桌面快捷方式的页面
  public static jumpToShortcutsPage(isLogin: boolean) {
    // 如果快捷页面的URL未设置，则直接返回
    if (!WantUtils.pageRouter.shortcutPageUrl) {
      return;
    }
    // 获取当前页面栈中的所有页面路径名称
    let pathNames: string[] = RouterModule.stack.getAllPathName();
    // 获取当前快捷页面的路径名称
    const curShortCutName = WantUtils.pageRouter.shortcutPageUrl;
    // 检查当前页面栈中是否已存在该快捷页面路径
    const pathName = pathNames.find((path) => path === curShortCutName);
    // 如果用户未登录，需要先跳转到登录页面，登录成功后再跳转到快捷页面
    if (!isLogin) {
      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
        // 登录成功后，跳转到目标快捷页面
        RouterModule.push({ url: curShortCutName })
      })
      return;
    }
    // 如果页面栈中已存在该快捷页面，则直接返回到该页面
    if (pathName) {
      RouterModule.popToName(curShortCutName);
    } else {
      // 如果页面栈中不存在该快捷页面，则跳转到该页面
      RouterModule.push({ url: curShortCutName})
    }
    // 清空快捷页面ID
    WantUtils.pageRouter.shortcutId = '';
  }

  // 跳转到服务卡片的页面
  public static jumpToFormCardPage() {
    if (!WantUtils.pageRouter.formCardPageUrl) {
      return;
    }
    // 清除路由栈中除Main页面之外的路由
    let pathNames: string[] = RouterModule.stack.getAllPathName();
    for (let i = pathNames.length - 1; i > 0; i--) {
      RouterModule.stack.removeByName(pathNames[i]);
    }
    const curPathName = WantUtils.pageRouter.formCardPageUrl;
    switch(curPathName) {
      case RouterMap.ORDER_INFO_PAGE:
        RouterModule.push({
          url: curPathName,
          param: WantUtils.pageRouter.pageParam,
        });
        break;
      default:
        RouterModule.push({ url: curPathName });
        break;
    }
    WantUtils.pageRouter.formCardId = '';
  }
}