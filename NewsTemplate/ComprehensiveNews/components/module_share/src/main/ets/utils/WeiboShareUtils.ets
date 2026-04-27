import { AppStorageV2 } from '@kit.ArkUI';
import { ArrayList } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { IWBAPI, MultiImageObject, TextObject, UiError, WBAPI, WbASListener, WeiboMultiMessage } from 'core';
import { ShareConfigModel } from '../model/ShareConfigModel';
import { ShareViewData } from '../common/ShareParams';

const TAG = '[WeiboShareUtils]';

/**
 * 分享到微博
 */
export class WeiboShareUtils {
  private static _instance: WeiboShareUtils;
  private mWBAPI: IWBAPI | null = null;
  private uiContext: UIContext | undefined = undefined;
  private configModel: ShareConfigModel = AppStorageV2.connect(ShareConfigModel, () => new ShareConfigModel())!;
  private shareData: ShareViewData = new ShareViewData();
  private listener: WbASListener = {
    onComplete: () => {
      this.configModel.restoreWindowLayout(this.uiContext);
      promptAction.showToast({ message: '分享成功', duration: 2000 });
      if (this.shareData.autoClose) {
        this.shareData.closeSheet();
      }
    },
    onError: (error: UiError) => {
      this.configModel.restoreWindowLayout(this.uiContext);
      promptAction.showToast({ message: '分享失败: ' + error.errorMessage, duration: 2000 });
    },
    onCancel: () => {
      this.configModel.restoreWindowLayout(this.uiContext);
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
   * @param uiContext
   * @param data
   */
  async share(uiContext: UIContext, data: ShareViewData) {
    this.uiContext = uiContext;
    this.shareData = data;
    const message: WeiboMultiMessage = new WeiboMultiMessage();
    const textObject: TextObject = new TextObject();
    if (data.title) {
      textObject.text = this.getTextContent(data);
      message.textObject = textObject;
    }
    if (data.imageUri) {
      const multiImage: MultiImageObject = new MultiImageObject();
      try {
        const uri = data.imageUri;
        const uris = new ArrayList<string>();
        uris.add(uri);
        multiImage.uriStrs = uris.convertToArray();
      } catch (e) {
        const err = e as BusinessError;
        UtilLog.error(TAG, 'multi image file operation failed, error msg = ' + err.message);
      }
      message.multiImageObject = multiImage;
    }

    if (this.mWBAPI != null) {
      this.mWBAPI.shareMessage(uiContext.getHostContext() as common.UIAbilityContext, message, this.listener);
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