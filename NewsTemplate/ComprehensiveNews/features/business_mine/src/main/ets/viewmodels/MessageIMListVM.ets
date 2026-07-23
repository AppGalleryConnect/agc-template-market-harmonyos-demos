import { UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { controllerMap, createNWeb, IResourceConfig, preLoadUrl, WebProperties } from '@hw-agconnect/fast-web';
import { BaseViewModel, MediaUtils, RouterMap, RouterUtils } from 'lib_common';
import { MessageServiceApi } from 'lib_news_api';
import { BriefIMModel } from '../common/ObservedModel';
import { WebIdMap } from '../constants/Constants';

@ObservedV2
export class MsgIMViewModel extends BaseViewModel {
  @Trace chatList: BriefIMModel[] = [];

  // 查询聊天列表
  queryList() {
    MessageServiceApi.queryAllIMList().then((resp) => {
      this.chatList = resp.map(v => new BriefIMModel(v));
    })
  }

  // 刷新单个聊天内容
  refreshChatItem(v: BriefIMModel) {
    MessageServiceApi.queryAllIMList().then((list) => {
      const imResp = list.find(item => item.chatAuthor.authorId === v.chatAuthor.authorId);
      if (imResp) {
        const imModel = new BriefIMModel(imResp);
        v.chatAuthor = imModel.chatAuthor;
        v.allUnreadCount = imModel.allUnreadCount;
        v.receiveTime = imModel.receiveTime;
        v.latestNews = imModel.latestNews;
        v.chatList = imModel.chatList;
      }
    })
  }

  // 一键已读
  setAllRead() {
    MessageServiceApi.setIMAllRead().then(() => {
      this.chatList.forEach(v => v.allUnreadCount = 0);
    })
  }

  // 创建离线Web
  createWeb(uiContent: UIContext) {
    if (controllerMap.get(WebIdMap.ChatWebId)) {
      return;
    }
    // 设置web属性
    const webProperties = new WebProperties();
    webProperties.geolocationAccess = false;
    webProperties.fileAccess = false;
    webProperties.darkMode = WebDarkMode.Auto;
    webProperties.forceDarkAccess = true;
    webProperties.onShowFileSelector = (event) => {
      if (event) {
        MediaUtils.selectMedia({ type: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE, maxLimit: 1 })
          .then((photoUris) => {
            event.result.handleFileList(photoUris);
          })
      }
      return true;
    };
    // 免拦截注入的离线资源如图片、样式表和脚本资源
    const resourceConfigs: IResourceConfig[] = [
      {
        localPath: 'news_tra_2.jpg',
        urlList: [
          'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_2.jpg',
        ],
        type: webview.OfflineResourceType.IMAGE,
      },
      {
        localPath: 'news_tra_3.jpg',
        urlList: [
          'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_3.jpg',
        ],
        type: webview.OfflineResourceType.IMAGE,
      },
    ];
    createNWeb(WebIdMap.ChatWebId, uiContent, webProperties, [], resourceConfigs);
  }

  // 复用web实例，需要在合适时机重置为空白页，避免闪现上一个页面的问题
  loadBlank() {
    preLoadUrl(WebIdMap.ChatWebId, 'about:blank');
  }

  // 跳转聊天详情页
  jumpChatPage(v: BriefIMModel) {
    RouterUtils.pushPathByName(RouterMap.MINE_MSG_IM_CHAT, v.chatAuthor, () => {
      // 只刷新对应的聊天，避免整个列表重绘
      this.refreshChatItem(v);
    });
  }

  @Computed
  get allowClean() {
    return this.chatList.some(v => v.allUnreadCount !== 0);
  }
}