import { AppStorageV2, ComponentContent, display, window } from '@kit.ArkUI';
import { ShortDramaDetailItemVM } from '../viewmodels/ShortDramaDetailItemVM';
import { PlayController } from 'video_swiper';
import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { FontModel, UserInfoModel } from '@agctemplate/widgets';
import { commentBuilder, CommentParam } from './CommentComp';
import { QQShareData, SharePicker } from 'aggregated_share';
import { appRouter, Logger, WindowManager } from '@agctemplate/utils';
import { MyMessageStorage } from '../models/MyMessageStorage';
import { emitter } from '@kit.BasicServicesKit';
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG: string = '[Side]'

/**
 * 功能描述：
 * 1. 展示视频播放界面右侧用户头像、视频评论数量、收藏数量、分享数量、作者是否被用户关注等信息
 *
 */
@ComponentV2
export struct Side {
  @Param @Require videoDes: ShortDramaDetailItemVM = new ShortDramaDetailItemVM;
  @Param @Require playControl: PlayController;
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  @Local myMessageStorage: MyMessageStorage = MyMessageStorage.instance()
  @Local isShowShareSheet: boolean = false
  @Local commentShow: boolean = false
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
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
  private commentNode: ComponentContent<CommentParam> | undefined = undefined

  openCommentDialog() {
    this.getUIContext().getPromptAction().openCustomDialog(this.commentNode, {
      enableHoverMode: true,
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
        this.commentShow = false
        this.myMessageStorage.showFlag = false
        this.myMessageStorage.isShowCommentSheet = false
        this.playControl.setPlayerHeight(`100%`)
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

  // 点击点赞按钮的回调函数
  private changeLikeCount(isAdd: boolean) {
    if (isAdd) {
      this.videoDes.dramaSocialInfo.setLike();
      this.getUIContext().getPromptAction().showToast({
        message: '点赞成功',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    } else {
      this.videoDes.dramaSocialInfo.unsetLike();
      this.getUIContext().getPromptAction().showToast({
        message: '取消点赞',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    }
  }

  // 点击收藏按钮的回调函数
  private changeFavoriteCount(isIncrease: boolean) {
    if (isIncrease) {
      this.videoDes.dramaSocialInfo.setFavor();
      this.getUIContext().getPromptAction().showToast({
        message: '收藏成功',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    } else {
      this.videoDes.dramaSocialInfo.unsetFavor();
      this.getUIContext().getPromptAction().showToast({
        message: '取消收藏',
        backgroundColor: 'rgba(46, 48, 51, 0.9)',
        backgroundBlurStyle: BlurStyle.NONE,
        textColor: 'rgba(255, 255, 255, 0.9)',
        bottom: '12%'
      })
    }
  }

  aboutToAppear(): void {
    try {
      display.on('foldStatusChange', this.callback2)
      display.on('change', this.callback)
    } catch (e) {
    }
    if (this.myMessageStorage.showFlag) {
      return
    } else {
      this.commentShow = this.myMessageStorage.isShowCommentSheet
      if (this.commentShow) {
        this.openCommentDialog()
        this.myMessageStorage.showFlag = true
      }
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange', this.callback2)
      display.off('change', this.callback)
    } catch (error) {
      console.error('failed.')
    }
  }

  sideSendFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 7
    };
    let eventData: emitter.EventData = {
      data: {
        id: 7
      }
    };
    try {
      emitter.emit(event, eventData);
    } catch (e) {
    }
  }

  build() {
    Column({ space: 16 }) {
      Column() {
        Image(this.videoDes.dramaSocialInfo.isLike ? getMedia('app.media.thumb_select') :
          getMedia('app.media.thumb_white'))
          .width(22)
          .height(20)
          .margin({ top: 2 })
          .accessibilityText(this.videoDes.dramaSocialInfo.isLike ? '取消点赞' : '点赞')
        Text(`${this.videoDes.dramaSocialInfo.likeCount}`)
          .fontSize(this.fontModel.getFg(10))
          .fontColor('#fff')
          .margin({ top: 4 })
          .accessibilityText(`有${this.videoDes.dramaSocialInfo.likeCount}个点赞`)
      }
      .onClick(() => {
        if (this.userInfo.isPhoneAssociated) {
          this.changeLikeCount(!this.videoDes.dramaSocialInfo.isLike)
          this.sideSendFavoriteEmitter()
        } else {
          this.playControl.pause()
          appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
        }
      })
      .width(40)
      .height(40)
      .id('fabulousButton')

      Column() {
        Image(getMedia('app.media.comment_white'))
          .accessibilityText('评论')
          .width(22)
          .height(20)
          .margin({ top: 2 })
        Text(this.videoDes.commentCount)
          .accessibilityText(`有${this.videoDes.commentCount}条评论`)
          .fontSize(this.fontModel.getFg(10))
          .fontColor('#fff')
          .margin({ top: 4 })
      }
      .width(40)
      .height(40)
      .id('comment_button')
      .onClick(() => {
        this.commentNode = new ComponentContent(
          this.getUIContext(),
          wrapBuilder<[CommentParam]>(commentBuilder),
          {
            dramaInfo: this.videoDes.dramaInfo,
            commentNum: (comments: number) => {
              this.videoDes.commentCount = comments.toString()
            },
            closeSheet: () => {
              this.commentShow = false
              this.closeCommentDialog()
            }
          } as CommentParam
        )
        if (this.isTabletLandScape) {
          this.playControl.setPlayerPositionX('-15%')
        } else if (this.isExpanded) {
          this.playControl.setPlayerWidth('50%')
        } else {
          this.playControl.setPlayerHeight('40%')
        }
        this.commentShow = true
        this.openCommentDialog()
      })

      Column() {
        Image(this.videoDes.dramaSocialInfo.isFavorite ? getMedia('app.media.favorite_select') :
          getMedia('app.media.favorite_white'))
          .width(22)
          .height(20)
          .margin({ top: 2 })
          .accessibilityText(this.videoDes.dramaSocialInfo.isFavorite ? '取消收藏' : '收藏')
        Text(`${this.videoDes.dramaSocialInfo.favoriteCount}`)
          .accessibilityText(`有${this.videoDes.dramaSocialInfo.favoriteCount}人收藏`)
          .fontSize(this.fontModel.getFg(10))
          .fontColor('#fff')
          .margin({ top: 4 })
      }
      .onClick(() => {
        if (this.userInfo.isPhoneAssociated) {
          this.changeFavoriteCount(!this.videoDes.dramaSocialInfo.isFavorite ? true : false);
        } else {
          this.playControl.pause()
          appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
        }
      })
      .width(40)
      .height(40)
      .id('favoriteButton')

      this.shareCommentBuilder()

    }
    .width(40)
    .height(208)
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
        title: this.videoDes.dramaInfo.name,
        subTitle: '微短剧应用模板',
        coverUrl: this.videoDes.dramaInfo.coverUrl,
        createTime: new Date('2025/09-15 08:00:00').getTime(),
        thumbUrl: this.videoDes.dramaInfo.coverUrl,
        landingPageUrl: `https://linking.xiaobingtang.cn/DramaDetail?id=${this.videoDes.dramaInfo.id}&index=${this.playControl.curentIndex}`
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
}