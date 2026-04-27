import * as wXOpenSdk from '@tencent/wechat_open_sdk';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { buffer } from '@kit.ArkTS';
import { ShareOptions } from '../model/Model';
import { MockService } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';

/**
 * 微信分享
 */
export class WxShareViewModel {
  // ToDo 后序这个AppId改成真实的AppId
  wXApi = wXOpenSdk.WXAPIFactory.createWXAPI('wxc92d9d6570127a32')
  private static _instance: WxShareViewModel
  isWXApp: boolean = this.wXApi.isWXAppInstalled()
  fileListSelectViewVM = new FileListSelectViewVM(MockService.allFileList)

  static get instance() {
    if (!WxShareViewModel._instance) {
      WxShareViewModel._instance = new WxShareViewModel()
    }
    return WxShareViewModel._instance
  }


  isWXAPPCallback(callback: Function) {
    if (!this.isWXApp) {
      AlertDialog.show({ message: JSON.stringify('请先安装微信') })
    } else {
      callback()
    }
  }


  async pixToBase64(coverUrl:PixelMap): Promise<string> {
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 20 };
    return new Promise((resolve) => {
      try {
        imagePackerApi.packing(coverUrl, packOpts).then((data: ArrayBuffer) => {
          let buf: buffer.Buffer = buffer.from(data);
          let base64 = 'data:image/jpeg;base64,' + buf.toString('base64', 0, buf.length);
          resolve(base64)
        })
      } catch (e) {
      }
    })
  }

  /**
   * 分享网页
   * @param text 文本内容
   */
  newsWebShare(qrCodeInfo: ShareOptions) {
    this.isWXAPPCallback(async () => {
      const webpageObject = new wXOpenSdk.WXWebpageObject()
      /*
       * 填写真实web地址
       * */
      webpageObject.webpageUrl = ''

      const mediaMessage = new wXOpenSdk.WXMediaMessage()
      mediaMessage.mediaObject = webpageObject
      mediaMessage.title = qrCodeInfo.title
      mediaMessage.description = `${qrCodeInfo.createTime}`

      try {
        const thumbData = await getContext(this).resourceManager.getMediaContent($r('app.media.startIcon'))
        const thumbPixel = image.createImageSource(thumbData.buffer).createPixelMapSync()
        const thumbBuffer = await image.createImagePacker().packToData(thumbPixel, { format: 'image/png', quality: 100 })
        mediaMessage.thumbData = new Uint8Array(thumbBuffer)
        const req = new wXOpenSdk.SendMessageToWXReq()
        req.scene = wXOpenSdk.SendMessageToWXReq.WXSceneSession
        req.message = mediaMessage
        this.wXApi.sendReq(getContext(this) as common.UIAbilityContext, req)
        MockService.addFileListToTargetList(this.fileListSelectViewVM.getAllSelected(), MockService.shareFileList)
      } catch (e) {
      }
    })
  }

  /**
   * 分享海报
   * @param text 文本内容
   */
  newsPosterShare(type:string,coverUrl:PixelMap) {
    this.isWXAPPCallback(async () => {
      let imageObject = new wXOpenSdk.WXImageObject
      imageObject.imageData = await this.pixToBase64(coverUrl);

      let mediaMessage = new wXOpenSdk.WXMediaMessage()
      mediaMessage.mediaObject = imageObject

      let req = new wXOpenSdk.SendMessageToWXReq()
      req.scene = wXOpenSdk.SendMessageToWXReq.WXSceneSession
      if(type === 'WXSceneTimeline') {
        req.scene = wXOpenSdk.SendMessageToWXReq.WXSceneTimeline
      }
      req.message = mediaMessage

      this.wXApi.sendReq(getContext(this) as common.UIAbilityContext, req)
      MockService.addFileListToTargetList(this.fileListSelectViewVM.getAllSelected(), MockService.shareFileList)
    })
  }
}
