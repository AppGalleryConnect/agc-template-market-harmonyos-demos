import { Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { NewsDetailRouter } from 'lib_common/src/main/ets/models/NewsDetailRouter';

export class WantUtils {
  /**
   * 处理分享
   * @param want
   */
  public static handleShare(want: Want) {
    // 接收方：从want中获取自定义参数，用于后续实现页面的路由跳转
    const paramStr = want?.parameters?.custShareParam as string;
    const routerParams: NewsDetailRouter = JSON.parse(paramStr || '{}');
    if (routerParams?.newsId) {
      const newsDetailRouter: NewsDetailRouter = AppStorageV2.connect(NewsDetailRouter, () => new NewsDetailRouter())!;
      newsDetailRouter.id = new Date().getTime();
      newsDetailRouter.newsId = routerParams.newsId;
    }
  }

  /**
   * 处理服务卡片点击
   * @param want
   */
  public static handleFormCardCall(want: Want) {
    if (want?.parameters?.newsId) {
      const newsDetailRouter: NewsDetailRouter = AppStorageV2.connect(NewsDetailRouter, () => new NewsDetailRouter())!;
      newsDetailRouter.id = new Date().getTime();
      newsDetailRouter.newsId = want.parameters.newsId as string;
    }
  }
}