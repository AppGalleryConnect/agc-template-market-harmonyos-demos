import { AppStorageV2 } from '@kit.ArkUI';
import { AppConstants, RouterUtils } from 'lib_common';
import { NewsDetailRouter } from 'lib_common/src/main/ets/models/NewsDetailRouter';
import { ShareInfo } from '../models/ShareInfo';

export class ShareUtils {
  static getShareParams(): ShareInfo {
    // 指定页面支持分享按钮点击事件
    let currentName: string[] = RouterUtils.getStack().getAllPathName()
    let showShareMenu = false
    if (currentName.length && AppConstants.SHARE_PAGES.includes(currentName[currentName.length-1])) {
      showShareMenu = true
    }
    const shareParams: ShareInfo = {
      showShareMenu,
      parameters: {} as NewsDetailRouter,
    };
    // 分享方：从临时缓存中获取自定义参数来设置want
    const instance = AppStorageV2.connect(NewsDetailRouter, () => new NewsDetailRouter())!;
    if (instance.newsId) {
      const pageParams: NewsDetailRouter = {
        id: instance.id,
        newsId: instance.newsId,
        newsTitle: instance.newsTitle,
        newsSource: instance.newsSource,
      }
      shareParams.title = pageParams.newsTitle;
      shareParams.description = pageParams.newsSource;
      shareParams.parameters = pageParams;
    }

    return shareParams;
  }
}