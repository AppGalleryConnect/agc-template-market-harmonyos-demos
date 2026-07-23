import { AbilityConstant, Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import {
  BreakpointNameEnum,
  ContinueModel,
  Logger,
  PushActionParams,
  PushUtils,
  RouterToNews,
} from 'lib_common';
import { SOURCE_FORM_CARD } from './Constants';
import { AppLinkingRouter, FormCardRouter, ShortcutRouter } from './Types';

const TAG = '[WantUtils]';

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
    const articleInfo = want.parameters?.articleInfo;
    AppStorage.setOrCreate('pushCardEntry', articleInfo);
  }

  /**
   * 热启动点击推送信息
   * @param want
   */
  public static handlePushWant(want: Want) {
    /*
    * 获取push卡片点击进入携带参数
    * */
    const articleInfo = want.parameters?.articleInfo as PushActionParams;
    if (articleInfo) {
      let articleId = articleInfo?.articleId;
      RouterToNews.routerToNewsById(articleId);
    }
  }

  /**
   * AppLinking链接处理
   * @param want
   */
  public static handleAppLinkingWant(want: Want) {
    /**
     * todo: 从链接中解析query参数，拿到参数后，可根据自己的业务需求进行后续的处理。
     * 例如传入的url为：https://linking.xiaobingtang.cn/newsDetail?id=article_1&type=0
     */
    const uri = want?.uri;
    if (uri) {
      try {
        const urlObject = url.URL.parseURL(uri);
        const newsId = urlObject.params.get('id');
        const newsType = urlObject.params.get('type');
        if (urlObject.pathname.includes('newsDetail') && newsId) {
          const appLinkRouter: AppLinkingRouter =
            AppStorageV2.connect(AppLinkingRouter, () => new AppLinkingRouter())!;
          appLinkRouter.id = new Date().getTime();
          appLinkRouter.newsId = newsId;
          appLinkRouter.newsType = Number(newsType) ?? 0;
        }
        Logger.info(TAG, `Success to handle applinking want. pathname: ${urlObject.pathname}, newsId: ${newsId}`)
      } catch (e) {
        Logger.error(TAG, `Failed to handle applinking want. uri: ${uri}, Code: ${e.code}, message: ${e.message}`);
      }
    }
  }

  /**
   * 快捷方式处理
   * @param want
   */
  public static handleShortcutWant(want: Want) {
    const shortCutKey = want?.parameters?.shortCutKey as string ?? '';
    if (shortCutKey) {
      const shortcutRouter: ShortcutRouter = AppStorageV2.connect(ShortcutRouter, () => new ShortcutRouter())!;
      shortcutRouter.pageName = shortCutKey;
    }
  }

  /**
   * 服务卡片事件处理
   * @param want
   */
  public static handleFormCardCall(want: Want) {
    if (want?.parameters?.source === SOURCE_FORM_CARD) {
      const formCardRouter: FormCardRouter =
        AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
      formCardRouter.id = new Date().getTime();
      formCardRouter.pageUrl = want?.parameters?.pageUrl as string ?? '';
      formCardRouter.newsId = want?.parameters?.newsId as string ?? '';
      formCardRouter.newsType = want?.parameters?.newsType as number ?? 0;
    }
  }

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
        continueRouter.newsId = want.parameters?.newsId as string ?? '';
        continueRouter.newsType = want.parameters?.newsType as number ?? 0;
        continueRouter.playerProgress = want.parameters?.playerProgress as number ?? 0;
        continueRouter.scrollOffset = want.parameters?.scrollOffset as number ?? 0;
        continueRouter.breakpoint = want.parameters?.breakpoint as string ?? BreakpointNameEnum.SM;
        continueRouter.isTargetDevice = true;
        Logger.info(TAG, `launch continue, want parameters: ${JSON.stringify(continueRouter)}`);
      }
    }
  }
}