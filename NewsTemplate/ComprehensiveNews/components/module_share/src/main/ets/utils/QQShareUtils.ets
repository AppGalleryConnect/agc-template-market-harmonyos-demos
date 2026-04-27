import { ShareResultType, ShareData } from '@tencent/qq-open-sdk';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { QQShareContent, ShareViewData } from '../common/ShareParams';
import { ShareService } from '../ShareService';

/**
 * QQ分享
 */
export class QQShareUtils {
  private static _instance: QQShareUtils;
  private shareService = ShareService.instance;
  shareData: ShareData = new ShareData();

  /**
   * 获取实例
   * @returns
   */
  static get instance() {
    if (!QQShareUtils._instance) {
      QQShareUtils._instance = new QQShareUtils();
    }
    return QQShareUtils._instance;
  }

  /**
   * 分享到qq
   * @param data
   */
  public async share(uiContext: UIContext, data: ShareViewData) {
    if (!this.shareService.qqOpenApi.isQQInstalled()) {
      uiContext.showAlertDialog({ message: '请先安装QQ' });
      return;
    }
    const shareData: QQShareContent = {
      msg_style: 0,
      title: data.title,
      summary: '',
      brief: '',
      url: data.landingPageUrl,
      picture_url: data.coverUrl,
    };
    this.sendShare(2, shareData, data);
  }

  /**
   * 分享图片到QQ
   * @param uiContext
   * @param data
   */
  public async shareImage(uiContext: UIContext, data: ShareViewData) {
    if (!this.shareService.qqOpenApi.isQQInstalled()) {
      uiContext.showAlertDialog({ message: '请先安装QQ' });
      return;
    }
    const shareData: QQShareContent = {
      msg_style: 6,
      share_uris: [data.imageUri],
    };
    this.sendShare(2, shareData, data);
  }

  /**
   * 执行分享
   * @param type
   * @param shareData
   * @param data
   */
  private async sendShare(type: number, shareData: QQShareContent, data: ShareViewData) {
    try {
      const signedShareData = await data.extraInfo.signQQShareData(JSON.stringify(shareData));
      const result = await this.shareService.qqOpenApi.share(type, signedShareData as ShareData);
      switch (result.resultType) {
        case ShareResultType.Success:
          promptAction.showToast({ message: '分享成功' });
          if (data.autoClose) {
            data.closeSheet();
          }
          break;
        case ShareResultType.Cancel:
          promptAction.showToast({ message: result.message ?? '分享取消' });
          break;
        case ShareResultType.Error:
          promptAction.showToast({ message: '分享失败: ' + result.message });
          break;
      }
    } catch (e) {
      promptAction.showToast({ message: '分享失败' });
    }
  }
}
