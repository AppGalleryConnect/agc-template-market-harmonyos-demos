import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  BaseViewModel,
  BreakpointNameEnum,
  FileUtils,
  Logger,
  PushActionParams,
  PushUtils,
  RouterParams,
  RouterToNews,
} from 'lib_common';
import { BaseNewsServiceApi, HomeServiceApi } from 'lib_news_api';

const TAG = '[HomeViewModel]';

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  public eNewsMap: Map<string, PixelMap> = new Map();

  @Computed
  get isSmDevice() {
    return this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM
  }

  // 预加载图片
  async preloadENewsImages() {
    // 调用接口查询图片数据
    const sourceId = '1';
    const publishDate = new Date().getTime();
    const list = await HomeServiceApi.queryDigitalNewsList(sourceId, publishDate);
    list.forEach((v) => {
      // 下载解码成PixelMap，并将其缓存
      FileUtils.downloadImage(v.newsImg)
        .then((buffer) => {
          const pixelMap = image.createImageSource(buffer).createPixelMapSync();
          this.eNewsMap.set(v.newsImg, pixelMap);
        })
    })
  }

  // mock 开启随机推送
  async sendPushMessage() {
    let pushArticle = await BaseNewsServiceApi.queryAllNewsList()
    PushUtils.randomPushMessage(pushArticle)
  }

  sendPushNotice(context: common.UIAbilityContext) {
    if (!this.settingInfo.pushSwitch) {
      notificationManager.requestEnableNotification(context).then(() => {
        this.settingInfo.pushSwitch = true;
        this.sendPushMessage();
        Logger.info(TAG, 'requestEnableNotification success');
      }).catch((error: BusinessError) => {
        this.settingInfo.pushSwitch = false;
        Logger.error(TAG, 'requestEnableNotification fail, error: ' + JSON.stringify(error));
      });
    } else {
      this.sendPushMessage();
    }
    /*
     * 判断是否是从push 卡片进入
     * */
    if (AppStorage.get('pushCardEntry')) {
      let newsData = AppStorage.get('pushCardEntry') as PushActionParams
      let routerParams: RouterParams<null> = {
        'type': newsData.type,
        'newsId': newsData.articleId,
        'authorId': newsData.authorId,
      }
      RouterToNews.pushToNewsDetails(routerParams)
      AppStorage.setOrCreate('isPushCardEntry', '')
    }
  }

  @Computed
  get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 48;
  }
}