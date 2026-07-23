import { AbilityConstant, Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { RouterToNews,PushActionParams, PushUtils, AppLinkingRouter } from '@agctemplate/widgets'
import { ContinueModel } from '@agctemplate/widgets';
import { jumpDetailPage, MyMessageStorage } from '@agctemplate/detail';

// import { SOURCE_FORM_CARD } from './Constants';
import { FormCardRouter } from './Types';
import { Logger } from '@agctemplate/utils';
import { url } from '@kit.ArkTS';

const TAG = '[WantUtils]';

const SOURCE_FORM_CARD: string = 'FormCard';
/**
 * 应用want处理工具类
 */
export class WantUtils {
   /**
    * 冷启动点击推送信息
    * @param want
    */
   public static async handlePushCall(want: Want) {
     let pushToken: string = await PushUtils.getTokenSyn();
     AppStorage.setOrCreate('pushToken', pushToken);
     const dramaInfo = want.parameters?.dramaInfo;
     AppStorage.setOrCreate('pushCardEntry', dramaInfo);
   }

  /**
   * 热启动点击推送信息
   * @param want
   */
   public static handlePushWant(want: Want) {
     /*
     * 获取push卡片点击进入携带参数
     * */
     const articleInfo = want.parameters?.articleInfo as string;
     if (articleInfo) {
       let articleId = articleInfo;
       RouterToNews.routerToNewsById(articleId);
     }
   }

  public static handleAppLinkingWant(want: Want) {
    /**
     * 处理want中获取传入的链接信息
     * 例如传入的url为：https://linking.xiaobingtang.cn/DramaDetail?id=drama_1&index=7
     */
    const uri = want?.uri;
    if (uri) {
      try {
        const urlObject = url.URL.parseURL(uri);
        const dramaId = urlObject.params.get('id');
        const dramaIndex = urlObject.params.get('index');
        if (urlObject.pathname.includes('DramaDetail') && dramaId) {
          const appLinkRouter: AppLinkingRouter =
            AppStorageV2.connect(AppLinkingRouter, () => new AppLinkingRouter())!;
          appLinkRouter.id = new Date().getTime();
          appLinkRouter.dramaId = dramaId;
          appLinkRouter.dramaIndex = Number(dramaIndex) ?? 0;
        }
        Logger.info(TAG, `Success to handle applinking want. pathname: ${urlObject.pathname}, dramaId: ${dramaId}`)
      } catch (e) {
        Logger.error(TAG, `Failed to handle applinking want. uri: ${uri}, Code: ${e.code}, message: ${e.message}`);
      }
    }
  }

  /**
   * 服务卡片事件处理
   * @param want
   */
   // public static handleFormCardCall(want: Want) {
   //   if (want?.parameters?.source === SOURCE_FORM_CARD) {
   //     const formCardRouter: FormCardRouter =
   //       AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
   //     formCardRouter.id = new Date().getTime();
   //     formCardRouter.pageUrl = want?.parameters?.pageUrl as string ?? '';
   //     formCardRouter.newsId = want?.parameters?.newsId as string ?? '';
   //     formCardRouter.newsType = want?.parameters?.newsType as number ?? 0;
   //   }
   // }

  /**
   * 接续事件处理
   * @param want
   * @param launchParam
   */
  public static handleRestoreCall(want: Want, launchParam: AbilityConstant.LaunchParam) {
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      Logger.info(TAG, 'launchParam.launchReason: CONTINUATION');
      // 将上述的保存的数据取出恢复
      if (want.parameters !== undefined) {
        const continueRouter: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
        continueRouter.id = new Date().getTime();
        continueRouter.dramaId = want.parameters?.dramaId as string ?? '';
        continueRouter.currentIndex = want.parameters?.currentIndex as number ?? 0;
        continueRouter.playTime = want.parameters?.playTime as number ?? 0;
        continueRouter.isTargetDevice = true;
        Logger.info(TAG, `launch continue, want parameters: ${JSON.stringify(continueRouter)}`);
      }
    }
  }
}