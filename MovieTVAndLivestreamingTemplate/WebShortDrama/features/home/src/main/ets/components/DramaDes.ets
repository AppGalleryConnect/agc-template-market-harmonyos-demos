import { DramaItemVM } from '../viewmodel/DramaItemVM';
import { ProcessBar, VideoPlayData, PlayController, PlaySession } from 'video_swiper';
import { DramaInfo, RequestAPI } from '@agctemplate/server';
import { jumpDetailPage } from '@agctemplate/detail';
import { DramaDesLayer } from './DramaDesLayer';
import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { commentBuilder, CommentParam } from './CommentComp';
import { appRouter, container, Logger, WindowManager } from '@agctemplate/utils';
import { AppStorageV2, ComponentContent, display, window } from '@kit.ArkUI';
import { FontModel, UserInfoModel } from '@agctemplate/widgets';
import { QQShareData, SharePicker } from 'aggregated_share';
import { emitter, deviceInfo } from '@kit.BasicServicesKit';
import { ProcessController } from 'video_swiper/src/main/ets/view/ProcessController';
import { AVPlayerListener } from 'video_swiper/src/main/ets/controller/AvPlayerListener';

const TAG = '[DramaDes]'

/**
 * 功能描述：
 * 1. Home剧集信息流上层独立绘制页面，视频描述信息，海报，看全集。
 *
 */
@Preview
@ComponentV2
export struct HomeDramaDes {
  @Param @Once @Require dramaInfo: DramaInfo = new DramaInfo([]) //剧集信息
  @Param @Require playControl: PlayController;
  @Param @Require playerSession: PlaySession
  @Local isThumb: boolean = false
  @Local likeCount: number = 0
  @Local favoriteCount: number = 0
  @Local isFavorite: boolean = false
  @Local isShowCommentSheet: boolean = false
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local commentCount: number = 3
  @Local isShowShareSheet: boolean = false
  @Consumer('curTabIndex') curTabIndex: number = 0;
  @Local processController: ProcessController | undefined = undefined
  @Local isExpanded: boolean = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED
  @Local isTabletLandScape: boolean = deviceInfo.deviceType === 'tablet' &&
    (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED)
  callback: Callback<number> = (data: number) => {
    if (deviceInfo.deviceType === 'tablet' &&
      (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
        display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED)) {
      if (!this.isTabletLandScape) {
        this.closeCommentDialog()
        this.isTabletLandScape = true
      }
    } else {
      if (this.isTabletLandScape) {
        this.closeCommentDialog()
        this.isTabletLandScape = false
      }
    }
  }
  callback2: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      if (!this.isExpanded) {
        this.closeCommentDialog()
        this.isExpanded = true
      }
    } else {
      if (this.isExpanded) {
        this.closeCommentDialog()
        this.isExpanded = false
      }
    }
  }
  windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  // 获取主窗口的方式
  mainWin: window.Window = this.windowStage.getMainWindowSync();
  avPlayerListener: AVPlayerListener = {
    onEnded: () => {
      Logger.info(TAG, 'onEnded')
      this.closeCommentDialog()
      this.playerSession.avPlayer?.pause()
      this.unEmitter()
      this.playerSession.unregisterListener(this.avPlayerListener)
      jumpDetailPage(this.dramaInfo, this.dramaInfo.curIndex + 1, 0, (data: PopInfo) => {
        Logger.info(TAG, 'onReEnter')
        this.onReEnter()
      })
    }
  }
  private commentNode: ComponentContent<CommentParam> | undefined = undefined

  openCommentDialog() {
    this.getUIContext().getPromptAction().openCustomDialog(this.commentNode, {
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        Logger.info(TAG, 'reason' + JSON.stringify(dismissDialogAction.reason))
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
      alignment: this.isTabletLandScape || this.isExpanded ? DialogAlignment.CenterEnd :
        DialogAlignment.Bottom,
      onWillDisappear: () => {
        this.isShowCommentSheet = false
        this.playControl.setPlayerHeight('100%')
        this.playControl.setPlayerWidth('100%')
        this.playControl.setPlayerPositionX(0)
      },
      keyboardAvoidMode: KeyboardAvoidMode.NONE
    })
  }

  closeCommentDialog() {
    if (this.commentNode) {
      this.getUIContext().getPromptAction().closeCustomDialog(this.commentNode)
    }
  }

  aboutToAppear(): void {
    try {
      display.on('foldStatusChange', this.callback2)
      display.on('change', this.callback)
    } catch (error) {
      console.error('failed')
    }
    this.playerSession.registerListener(this.avPlayerListener)
    this.getDeleteEmitter()
    this.getDetailInfoFavoriteEmitter()
    this.getSideFavoriteEmitter()
    this.isFavorite = this.dramaInfo.isFavorite
    this.isThumb = this.dramaInfo.isLike
    this.likeCount = this.dramaInfo.likeCount
    this.favoriteCount = this.dramaInfo.favoriteCount
    container.resolve(RequestAPI).getCommentList({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.commentCount = res.getBody().commentList.length
    })
    this.registerEmitter()
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange', this.callback2)
      display.off('change', this.callback)
    } catch (e) {
    }
  }

  registerEmitter() {
    this.backEmitter()
    this.foreEmitter()
  }

  onForeground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    Logger.info(TAG, `onForeground: ${JSON.stringify(eventData)}`);
    // 不响应非本tab事件
    if (this.curTabIndex === 0) {
      return
    }
    this.playControl.pause()
  }
  onBackground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    Logger.info(TAG, `onBackground: ${JSON.stringify(eventData)}`);
    if (this.curTabIndex !== 0) {
      return
    }
    this.playControl.pause()
  }

  backEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    try {
      emitter.on(event, this.onBackground);
    } catch (error) {
      console.error('failed')
    }
  }

  foreEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 2
    };
    try {
      emitter.on(event, this.onForeground);
    } catch (e) {
    }
  }

  unEmitter() {
    try {
      Logger.info(TAG, 'on jump')
      emitter.off(1, this.onBackground)
      emitter.off(2, this.onForeground)
    } catch (e) {
    }
  }

  getDeleteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 6
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.isFavorite = this.dramaInfo.isFavorite
      this.isThumb = this.dramaInfo.isLike
      this.likeCount = this.dramaInfo.likeCount
      this.favoriteCount = this.dramaInfo.favoriteCount
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  getDetailInfoFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 5
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.isFavorite = this.dramaInfo.isFavorite
      this.isThumb = this.dramaInfo.isLike
      this.likeCount = this.dramaInfo.likeCount
      this.favoriteCount = this.dramaInfo.favoriteCount
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  getSideFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 7
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.isFavorite = this.dramaInfo.isFavorite
      this.isThumb = this.dramaInfo.isLike
      this.likeCount = this.dramaInfo.likeCount
      this.favoriteCount = this.dramaInfo.favoriteCount
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      DramaDesLayer({
        dramaInfo: this.dramaInfo,
        playControl: this.playControl,
        playerSession: this.playerSession,
        onJump: () => {
          Logger.info(TAG, 'onJump')
          this.playControl.pause()
          this.unEmitter()
          jumpDetailPage(this.dramaInfo, this.dramaInfo.curIndex, this.playerSession.avPlayer?.currentTime,
            (data: PopInfo) => {
              Logger.info(TAG, 'onReEnter')
              this.onReEnter()
            })
        }
      })

      Column({ space: 16 }) {
        Column() {
          Image(this.isThumb ? getMedia('app.media.thumb_select') : getMedia('app.media.thumb_white'))
            .accessibilityText(this.isThumb ? '取消点赞' : '点赞')
            .width(22)
            .height(20)
            .margin({ top: 2 })
          Text(`${this.likeCount}`)
            .accessibilityText(`有${this.likeCount}个点赞`)
            .fontSize(this.fontModel.getFg(10))
            .fontColor('#fff')
            .margin({ top: 4 })
        }
        .onClick(() => {
          if (this.userInfo.isPhoneAssociated) {
            if (this.isThumb) {
              this.likeCount--
              container.resolve(RequestAPI).unsetLike(this.dramaInfo.id)
            } else {
              this.likeCount++
              container.resolve(RequestAPI).setLike(this.dramaInfo.id)
            }
            this.isThumb = !this.isThumb
          } else {
            this.playControl.pause()
            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
          }
        })
        .width(40)
        .height(40)

        Column() {
          Image(getMedia('app.media.comment_white'))
            .accessibilityText('评论')
            .width(22)
            .height(20)
            .margin({ top: 2 })
          Text(`${this.commentCount}`)
            .accessibilityText(`有${this.commentCount}条评论`)
            .fontSize(this.fontModel.getFg(10))
            .fontColor('#fff')
            .margin({ top: 4 })
        }
        .width(40)
        .height(40)
        .onClick(() => {
          this.commentNode = new ComponentContent(
            this.getUIContext(),
            wrapBuilder<[CommentParam]>(commentBuilder),
            {
              dramaInfo: this.dramaInfo,
              commentNum: (comments: number) => {
                this.commentCount = comments
              },
              closeSheet: () => {
                this.isShowCommentSheet = false
                this.closeCommentDialog()
              }
            } as CommentParam
          )
          this.isShowCommentSheet = !this.isShowCommentSheet
          if (this.isTabletLandScape) {
            this.playControl.setPlayerPositionX('-15%')
          } else if (this.isExpanded) {
            this.playControl.setPlayerWidth('50%')
          } else {
            this.playControl.setPlayerHeight('40%')
          }
          this.openCommentDialog()
        })

        Column() {
          Image(this.isFavorite ? getMedia('app.media.favorite_select') :
            getMedia('app.media.favorite_white'))
            .accessibilityText(this.isFavorite ? '取消收藏' : '收藏')
            .width(22)
            .height(20)
            .margin({ top: 2 })
          Text(`${this.favoriteCount}`)
            .accessibilityText(`有${this.favoriteCount}人收藏`)
            .fontSize(this.fontModel.getFg(10))
            .fontColor('#fff')
            .margin({ top: 4 })
        }
        .onClick(() => {
          if (this.userInfo.isPhoneAssociated) {
            if (this.isFavorite) {
              this.favoriteCount--
              container.resolve(RequestAPI).unsetFavorite(this.dramaInfo.id)
            } else {
              this.favoriteCount++
              container.resolve(RequestAPI).setFavorite(this.dramaInfo.id)
            }
            this.isFavorite = !this.isFavorite
          } else {
            this.playControl.pause()
            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
          }
        })
        .width(40)
        .height(40)

        this.shareCommentBuilder()

      }
      .width(40)
      .height(208)
      .margin({ bottom: 72, right: 8 })
      .onVisibleAreaChange([0], (isExpanding: boolean, currentRatio: number) => {
        if (isExpanding) {
          this.playControl.play()
        }
      })

      if (this.playerSession.avPlayer?.isReady) {
        ProcessBar({ avPlayer: this.playerSession.avPlayer })
          .hitTestBehavior(HitTestMode.Transparent)
      }

    }
    .width('100%')
    .height('100%')
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.share_white'))
        .width(21)
        .height(21)
      Text('分享')
        .fontSize(this.fontModel.getFg(10))
        .fontColor($r('sys.color.font_on_primary'))
    }
    .accessibilityGroup(true)
    .accessibilityText('分享')
    .onClick(() => {
      const picker: SharePicker = new SharePicker({
        title: this.dramaInfo.name,
        subTitle: '微短剧应用模板',
        coverUrl: this.dramaInfo.coverUrl,
        createTime: new Date('2025/09-15 08:00:00').getTime(),
        thumbUrl: this.dramaInfo.coverUrl,
        landingPageUrl: `https://linking.xiaobingtang.cn/DramaDetail?id=${this.dramaInfo.id}&index=0`
      });

      picker.setSignQQShareDataCB((shareJson: string) => {
        const signData = new QQShareData();
        signData.shareJson = shareJson;
        signData.timestamp = Date.parse(new Date().toString()) / 1000;
        signData.nonce = 62695688;
        signData.shareJsonSign = 'Hsvqs0IpjiN6DfFfhboGp+r3XzQ=';
        return Promise.resolve(signData);
      })

      picker.show({
        autoClose: true,
      });
    })
  }

  onReEnter() {
    this.playControl.seek(0)
    this.playControl.play()
    this.registerEmitter()
    Logger.info(TAG, 'registerListener')
    this.playerSession.registerListener(this.avPlayerListener)
  }
}

@Builder
export function DramaDesComponent(videoData: VideoPlayData, playControl: PlayController, playerSession: PlaySession) {
  HomeDramaDes({
    dramaInfo: (videoData as DramaItemVM).dramaInfo,
    playControl: playControl,
    playerSession: playerSession
  })
}
