/**
 * @usage: 全屏展示图片，支持返回与保存到相册
 * @layout: Column + 全屏 Image + 顶部返回 + 底部下载
 * @constraints: 图片占满全屏、宽高自适应，布局不可变
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 全屏图片页
 * @subPage:
 * @component:
 * @image:
 */
import { common } from '@kit.AbilityKit'
import { AppStorageV2 } from '@kit.ArkUI'
import { fileIo as fs } from '@kit.CoreFileKit';
import { rcp } from '@kit.RemoteCommunicationKit'
import { ChatBreakpoint } from '../utils/ChatBreakpoint'
import { RcpDownloader } from '../utils/RcpDownloader'
import { saveAlbumTool } from '../utils/SaveAlbumTool';

@ComponentV2
export struct FullScreenImagePage {
  @Param @Require imgSrc: string = ''
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private uiCtx = this.getUIContext() as UIContext;
  private downloader: RcpDownloader = new RcpDownloader(this.context)
  @Event backAction: () => void = () => {
  }

  build() {
    Column() {
      Image(this.imgSrc)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.backAction()
        })

      Image($r('app.media.ic_back_white'))
        .width(40)
        .height(40)
        .position({ left: 16, top: 4 + this.chatBreakpoint.topValue })
        .onClick(() => {
          this.backAction()
        })

      Image($r('app.media.download'))
        .width(40)
        .height(40)
        .position({ right: 20, bottom: 20 + this.chatBreakpoint.bottomValue })
        .onClick(() => {
          let fileName: string = this.imgSrc.split('/').pop() as string
          fileName = fileName.split('?')[0]
          let filePath = `${this.context.cacheDir}/downloads/` + fileName
          if (fs.accessSync(filePath)) {
            saveAlbumTool.saveAlbum(filePath, this.uiCtx)
            return
          }

          this.downloader.startDownload(this.imgSrc, fileName).then((result: rcp.Response) => {
            if (result.statusCode === 200) {
              saveAlbumTool.saveAlbum(filePath, this.uiCtx)
            } else {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.image_download_failed') })
            }
          }).catch(() => {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.image_download_failed') })
          })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
