import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ArrayList } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { IWBAPI, MultiImageObject, TextObject, UiError, WBAPI, WbASListener, WeiboMultiMessage } from 'core';
import { saveImgToSandbox } from './FileUtils';
import { ShareConfigModel } from '../model/ShareConfigModel';
import { Logger } from '../common/Logger';
import { ShareViewData } from '../common/ShareParams';

const TAG = 'WeiboShareUtils';

/**
 * 分享到微博
 */
export class WeiboShareUtils {
  private static _instance: WeiboShareUtils;
  private mWBAPI: IWBAPI | null = null;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private configModel: ShareConfigModel = AppStorageV2.connect(ShareConfigModel, () => new ShareConfigModel())!;
  private shareData: ShareViewData = new ShareViewData();
  private listener: WbASListener = {
    onComplete: () => {
      this.configModel.restoreWindowLayout();
      promptAction.showToast({ message: '分享成功', duration: 2000 });
      if (this.shareData.autoClose) {
        this.shareData.closeSheet();
      }
    },
    onError: (error: UiError) => {
      this.configModel.restoreWindowLayout();
      promptAction.showToast({ message: '分享失败: ' + error.errorMessage, duration: 2000 });
    },
    onCancel: () => {
      this.configModel.restoreWindowLayout();
      promptAction.showToast({ message: '分享取消', duration: 2000 });
    },
  };

  /**
   * 获取实例
   * @returns
   */
  static get instance() {
    if (!WeiboShareUtils._instance) {
      WeiboShareUtils._instance = new WeiboShareUtils();
    }
    return WeiboShareUtils._instance;
  }

  constructor() {
    this.mWBAPI = WBAPI.getInstance();
  }

  /**
   * 分享
   * @param title
   * @param url
   * @param img
   */
  async share(data: ShareViewData, img?: PixelMap) {
    this.shareData = data;
    const message: WeiboMultiMessage = new WeiboMultiMessage();
    const textObject: TextObject = new TextObject();
    if (data.title) {
      textObject.text = this.getTextContent(data);
      message.textObject = textObject;
    }
    if (img) {
      const multiImage: MultiImageObject = new MultiImageObject();
      try {
        const uri = await saveImgToSandbox(img);
        const uris = new ArrayList<string>();
        uris.add(uri);
        multiImage.uriStrs = uris.convertToArray();
      } catch (e) {
        const err = e as BusinessError;
        Logger.error(TAG, 'multi image file operation failed, error msg = ' + err.message);
      }
      message.multiImageObject = multiImage;
    }

    if (this.mWBAPI != null) {
      this.mWBAPI.shareMessage(this.context, message, this.listener);
    }
  }

  /**
   * 获取文本内容
   * @param data
   * @returns
   */
  private getTextContent(data: ShareViewData) {
    if (data.landingPageUrl) {
      return `${data.title} | ${data.landingPageUrl}`;
    }
    if (data.subTitle) {
      return `${data.title} | ${data.subTitle}`;
    }
    return data.title;
  }
}