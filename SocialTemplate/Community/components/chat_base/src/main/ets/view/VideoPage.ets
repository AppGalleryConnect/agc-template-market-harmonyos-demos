/**
 * @usage: 播放聊天视频，支持静音/暂停与保存至相册
 * @layout: Column + 顶部返回 + 中心 Video + 底部操作区
 * @constraints: 控制状态一致性；相册写入权限；自动播放开启、循环关闭；黑底全屏
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 视频播放页
 * @subPage:
 * @component:
 */
import { common } from '@kit.AbilityKit'
import { rcp } from '@kit.RemoteCommunicationKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { saveAlbumTool, SaveAlbumTool } from '../utils/SaveAlbumTool';
import { ChatBreakpoint } from '../utils/ChatBreakpoint';
import { RcpDownloader } from '../utils/RcpDownloader';

@ComponentV2
export struct VideoPage {
  @Param @Require videoChatSrc: string
  @Param @Require videoStatus: boolean
  @Local mutedBoolean: boolean = true
  controller: VideoController = new VideoController()
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local isVideoStop: boolean = false
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  saveAlbumTool: SaveAlbumTool = new SaveAlbumTool()
  @Event onReturnClick: () => void = () => {
  }
  downloader: RcpDownloader = new RcpDownloader(this.context)
  aboutToAppear(): void {
    this.mutedBoolean = !this.videoStatus
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back_white'))
          .width(40)
          .height(40)
          .position({ left: 16, top: 4 + this.chatBreakpoint.topValue })
          .onClick(() => {
            this.onReturnClick()
          })
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height(85)
      .margin({ bottom: 10 })

      Stack({ alignContent: Alignment.BottomEnd }) {
        Stack({ alignContent: Alignment.Center }) {
          Video({
            src: this.videoChatSrc,
            controller: this.controller
          })
            .constraintSize({
              maxHeight: '100%', // 设置最大高度为屏幕高度的80%
              minHeight: 200    // 设置最小高度（单位vp）
            })
            .muted(this.mutedBoolean)// 设置是否静音
            .controls(false)// 设置是否显示默认控制条
            .autoPlay(true)// 设置是否自动播放
            .loop(false)// 设置是否循环播放
            .width('100%')
            .margin({bottom : 10})
            .onStop(() => { // 停止事件回调
              this.isVideoStop = true
            })
            .onStart(() => {
              this.isVideoStop = false;
            })
            .onPause(() => {
              this.isVideoStop = true;
            })
            .onClick(() => {
              if (this.isVideoStop) {
                this.isVideoStop = false
                this.controller.start();
              } else {
                this.isVideoStop = true
                this.controller.pause();
              }

            })
          if (this.isVideoStop) {
            Image($r('app.media.video_image_stop'))
              .width(100)
              .height(100)
              .onClick(() => {
                this.isVideoStop = false
                this.controller.start();
              })
          }
        }

        Row() {
          Image(this.mutedBoolean ? $r('app.media.mutetrue') : $r('app.media.mutedfalse'))
            .width(40)
            .height(40)
            .margin({ right: 10 })
            .onClick(() => {
              if (this.mutedBoolean) {
                this.mutedBoolean = false
              } else {
                this.mutedBoolean = true
              }
            })
          Image($r('app.media.download'))
            .width(40)
            .height(40)
            .onClick(() => {
              let videoName: string = this.videoChatSrc.split('/').pop() as string
              videoName = videoName.split('?')[0]
              let videoFilePath = `${this.context.cacheDir}/downloads/` + videoName
              this.downloader.startDownload(this.videoChatSrc, videoName).then((result: rcp.Response) => {
                if (result.statusCode === 200) {
                  saveAlbumTool.saveHttpVideo(videoFilePath, this.getUIContext())
                } else {
                  this.getUIContext().getPromptAction().showToast({ message: '视频下载成功' })
                }
              }).catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: '视频下载失败' })
              })
            })
        }
        .margin({ right: 20 , bottom : 20})
      }
      .height('87%')
      .margin({ bottom : 30})
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}