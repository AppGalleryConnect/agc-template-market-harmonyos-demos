import { Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { CustomLinkModel, CustomShareParams, FormCardRouter } from 'lib_foundation';

const TAG = '[WantUtils]';

/**
 * 应用want处理工具类
 */
export class WantUtils {
  /**
   * AppLinking链接处理
   * @param want
   */
  public static handleAppLinking(want: Want) {
    let uri = want?.uri;
    if (uri) {
      // 从链接中解析query参数（自定义参数），拿到参数后，开发者可根据自己的业务需求进行后续的处理。
      try {
        const navRouterName = want.parameters?.navRouterName as string;
        Logger.info(TAG, 'navRouterName is: ' + navRouterName);
        // 例如，当navRouterName为GoodDetail时，跳转服务详情页面。
        if (navRouterName === 'GoodDetail') {
          const linkScanRouter: CustomLinkModel = AppStorageV2.connect(CustomLinkModel, () => new CustomLinkModel())!;
          linkScanRouter.id = new Date().getTime();
          linkScanRouter.pageUrl = navRouterName;
        }
      } catch (error) {
        Logger.error(TAG, 'Failed to parse url. error: ' + JSON.stringify(error));
      }
    }
  }

  /**
   * 元服务分享链接处理
   * @param want
   */
  public static handleShare(want: Want) {
    // 接收方：从want中获取自定义参数，用于后续实现页面的路由跳转
    const paramStr = want?.parameters?.custShareParam as string;
    const shareParams: CustomShareParams = JSON.parse(paramStr || '{}');
    const shareRouter: CustomShareParams =
      AppStorageV2.connect(CustomShareParams, 'handleShare', () => new CustomShareParams())!;
    shareRouter.id = new Date().getTime();
    shareRouter.pageName = '';
    shareRouter.goodId = '';
    if (shareParams?.goodId) {
      shareRouter.pageName = shareParams.pageName;
      shareRouter.goodId = shareParams.goodId;
    }
  }

  /**
   * 服务卡片事件处理
   * @param want
   */
  public static handleFormCardCall(want: Want) {
    if (want?.parameters?.source === 'FormCard') {
      const formCardRouter: FormCardRouter =
        AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
      formCardRouter.id = new Date().getTime();
      formCardRouter.pageUrl = want?.parameters?.pageUrl as string ?? '';
      formCardRouter.orderId = want?.parameters?.orderId as string ?? '';
      formCardRouter.goodId = want?.parameters?.goodId as string ?? '';
      formCardRouter.categoryParam.tabIndex = want?.parameters?.tabIndex as number ?? 1;
      formCardRouter.categoryParam.listInitialIndex = want?.parameters?.listInitialIndex as number ?? 0;
    }
  }
}