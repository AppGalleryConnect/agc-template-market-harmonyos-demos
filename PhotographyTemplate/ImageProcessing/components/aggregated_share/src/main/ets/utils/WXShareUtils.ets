import * as wxopensdk from '@tencent/wechat_open_sdk';
import { common } from '@kit.AbilityKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { ShareAppType } from '../common/ShareEnum';
import { ShareViewData } from '../common/ShareParams';
import { OnWXResp } from '../model/WXApiWrap';
import { ShareService } from '../ShareService';
import { compressImage, downloadImage } from './FileUtils';

const TAG = '[WXShareUtils]';

/**
 * 微信分享
 */
export class WXShareUtils {
  private static _instance: WXShareUtils;
  private shareService = ShareService.instance;
  private shareData: ShareViewData = new ShareViewData();

  /**
   * 获取实例
   * @returns
   */
  static get instance() {
    if (!WXShareUtils._instance) {
      WXShareUtils._instance = new WXShareUtils();
    }
    return WXShareUtils._instance;
  }

  /**
   * 判断微信是否安装
   * @param uiContext
   * @param callback
   */
  private isWXAPPCallback(uiContext: UIContext, callback: Function) {
    if (!this.shareService.wxApi.isWXAppInstalled()) {
      uiContext.showAlertDialog({ message: '请先安装微信' });
    } else {
      callback();
    }
  }

  /**
   * 分享图片
   * @param uiContext
   * @param data
   * @Param type
   */
  shareImage(uiContext: UIContext, data: ShareViewData, type: ShareAppType) {
    this.isWXAPPCallback(uiContext, async () => {
      const imageObject = new wxopensdk.WXImageObject();
      if (data.imageUri) {
        imageObject.uri = data.imageUri;
      }

      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.mediaObject = imageObject;

      const req = new wxopensdk.SendMessageToWXReq();
      // 默认分享到朋友
      req.scene = wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage;

      if (type === ShareAppType.WECHAT_TIMELINE) {
        req.scene = wxopensdk.SendMessageToWXReq.WXSceneTimeline;
      }

      this.shareService.wxApi.sendReq(uiContext.getHostContext() as common.UIAbilityContext, req);
    })
  }

  /**
   * 分享网页
   * @param uiContext
   * @param data
   * @param type
   */
  shareWebpage(uiContext: UIContext, data: ShareViewData, type: ShareAppType) {
    const context = uiContext.getHostContext() as Context;
    this.isWXAPPCallback(uiContext, async () => {
      const webpageObject = new wxopensdk.WXWebpageObject();
      webpageObject.webpageUrl = data.landingPageUrl;

      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.title = data.title;
      mediaMessage.description = data.subTitle;
      mediaMessage.mediaObject = webpageObject;
      try {
        if (data.thumbUrl) {
          let thumbBuffer = new ArrayBuffer(100);
          if (typeof data.thumbUrl === 'string') {
            const thumbRawData = await downloadImage(data.thumbUrl);
            thumbBuffer = await compressImage(thumbRawData);
          } else {
            const thumbRawData = await context.resourceManager.getMediaContent(data.thumbUrl.id);
            thumbBuffer = await compressImage(thumbRawData.buffer as ArrayBuffer);
          }
          if (thumbBuffer.byteLength / 1024 > 64) {
            UtilLog.error(TAG, `thumbData is over 64K, buffer length: ${thumbBuffer.byteLength / 1024}K`);
          }
          mediaMessage.thumbData = new Uint8Array(thumbBuffer);
        }
      } catch (error) {
        UtilLog.error(TAG, `Failed to get media content, errCode: ${error.code}, errMessage: ${error.message}`);
      }

      const req = new wxopensdk.SendMessageToWXReq();
      // 默认分享到朋友
      req.scene = wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage;

      if (type === ShareAppType.WECHAT_TIMELINE) {
        req.scene = wxopensdk.SendMessageToWXReq.WXSceneTimeline;
      }

      this.shareService.wxApi.sendReq(context as common.UIAbilityContext, req);
    })
  }

  /**
   * 监听分享回调
   * @param data
   */
  public registerOnWXRespCallback(data: ShareViewData) {
    this.shareData = data;
    this.shareService.wxEventHandler.registerOnWXRespCallback(this.handleResp);
  }

  /**
   * 取消监听分享回调
   */
  public unregisterOnWXRespCallback() {
    this.shareService.wxEventHandler.unregisterOnWXRespCallback(this.handleResp);
  }

  /**
   * 分享后回调处理
   * @param errCode
   */
  private handleResp: OnWXResp = (err) => {
    switch (err.errCode) {
      case wxopensdk.ErrCode.ERR_OK:
        promptAction.showToast({ message: '分享成功' });
        if (this.shareData.autoClose) {
          this.shareData.closeSheet();
        }
        break;
      case wxopensdk.ErrCode.ERR_USER_CANCEL:
        promptAction.showToast({ message: '分享取消' });
        break;
      default:
        promptAction.showToast({ message: '分享失败: ' + err.errStr });
        break;
    }
  }
}
