import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { Logger } from '../common/Logger';
import { ShareAppType } from '../common/ShareEnum';
import { ShareViewData } from '../common/ShareParams';
import { OnWXResp } from '../model/WXApiWrap';
import { ShareService } from '../ShareService';
import { downloadImage, compressImage, saveImgToSandbox } from './FileUtils';

const TAG = 'WXShareUtils';

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
   * @param callback
   */
  private isWXAPPCallback(callback: Function) {
    if (!this.shareService.wxApi.isWXAppInstalled()) {
      AlertDialog.show({ message: '请先安装微信' });
    } else {
      callback();
    }
  }

  /**
   * 分享图片
   * @param type
   * @param image
   */
  shareImage(image: PixelMap, type: ShareAppType) {
    this.isWXAPPCallback(async () => {
      const imageObject = new wxopensdk.WXImageObject();
      imageObject.uri = await saveImgToSandbox(image);

      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.mediaObject = imageObject;

      const req = new wxopensdk.SendMessageToWXReq();
      // 默认分享到朋友
      req.scene = wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage;

      if (type === ShareAppType.WECHAT_TIMELINE) {
        req.scene = wxopensdk.SendMessageToWXReq.WXSceneTimeline;
      }

      this.shareService.wxApi.sendReq(getContext(this) as common.UIAbilityContext, req);
    })
  }

  /**
   * 分享网页
   * @param data
   * @param type
   */
  shareWebpage(data: ShareViewData, type: ShareAppType) {
    this.isWXAPPCallback(async () => {
      const webpageObject = new wxopensdk.WXWebpageObject();
      webpageObject.webpageUrl = data.landingPageUrl;

      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.title = data.title;
      mediaMessage.description = data.subTitle;
      mediaMessage.mediaObject = webpageObject;

      if (data.thumbUrl) {
        let thumbBuffer = new ArrayBuffer(100);
        if (typeof data.thumbUrl === 'string') {
          const thumbRawData = await downloadImage(data.thumbUrl);
          thumbBuffer = await compressImage(thumbRawData);
        } else {
          const thumbRawData = await getContext(this).resourceManager.getMediaContent(data.thumbUrl);
          thumbBuffer = await compressImage(thumbRawData.buffer as ArrayBuffer);
        }
        if (thumbBuffer.byteLength / 1024 > 64) {
          Logger.error(TAG, `thumbData is over 64K, buffer length: ${thumbBuffer.byteLength / 1024}K`);
        }

        mediaMessage.thumbData = new Uint8Array(thumbBuffer);
      }

      const req = new wxopensdk.SendMessageToWXReq();
      // 默认分享到朋友
      req.scene = wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage;

      if (type === ShareAppType.WECHAT_TIMELINE) {
        req.scene = wxopensdk.SendMessageToWXReq.WXSceneTimeline;
      }

      this.shareService.wxApi.sendReq(getContext(this) as common.UIAbilityContext, req);
    })
  }

  /**
   * 监听分享回调
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
