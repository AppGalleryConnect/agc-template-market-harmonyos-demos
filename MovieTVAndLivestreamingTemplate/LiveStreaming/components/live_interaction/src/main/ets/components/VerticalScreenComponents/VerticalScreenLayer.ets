import { LiveInteractionMgr, LoginUserInfo } from '../../manager/LiveInteractionMgr'
import { CanvasLike as CanvasLikeLayer } from '../../view/CanvasLike'
import { BottomLineLayer } from '../BottomLineLayer'
import { BulletLayer } from '../BulletLayer'
import { DetailTopInfo } from '../DetailTopInfo'
import { LiveList } from '../MoreLive'
import { PublicScreenLayer } from '../PublicScreenLayer'
import { TopSecondLineLayer } from '../TopSecondLineLayer'
import { DimLayer } from '../DimLayer'
import { VideoMaskLayer } from '../VideoMaskLayer'
import { BulletVM } from '../../viewModels/BulletVM'
import { AppStorageV2 } from '@kit.ArkUI'

export enum PreferType {
  PORTRAIT = 0,
  LANDSCAPE = 1
}

@ComponentV2
export struct VerticalScreenLayer {
  userName: string = ''
  @Param preferType: PreferType = PreferType.PORTRAIT;
  @Param @Require interactionMgr: LiveInteractionMgr
  @Local showControl: boolean = true
  @Local userAvatar: Resource | string = $r('app.media.person')
  @Local isShowMoreLive: boolean = false
  @Local bulletVM: BulletVM = AppStorageV2.connect(BulletVM, 'bulletVM', () => new BulletVM())!
  private promptAction = this.getUIContext().getPromptAction()
  private moreLive: number = 0


  aboutToAppear(): void {
    this.bulletVM.direction = 0
    if (this.interactionMgr.onCheckLogin()) {
      let userInfo: LoginUserInfo = this.interactionMgr.onGetLoginUserInfo()
      if (userInfo) {
        this.userAvatar = userInfo.avatar
        this.userName = userInfo.name
      }
    }
    this.interactionMgr.chatMgr.play()
  }

  aboutToDisappear(): void {
    this.interactionMgr.chatMgr.stop()
  }

  build() {
    Stack() {
      Stack({ alignContent: Alignment.TopStart }) {
        DimLayer({ dimOpacity: 0.2, dimBlur: 50 })

        TopSecondLineLayer({
          rankId: this.interactionMgr.rankId,
          rankList: this.interactionMgr.rankList,
          openMoreLive: async () => {
            this.moreLive = await this.promptAction.openCustomDialog({
              builder: () => {
                this.moreLiveBuilder()
              },
              width: '100%',
              height: '100%',
              backgroundBlurStyle: BlurStyle.NONE,
              backgroundColor: Color.Transparent,
              cornerRadius: 0,
              alignment: DialogAlignment.Bottom
            })
            this.isShowMoreLive = true
          }
        })
        BulletLayer({ bulletVM: this.bulletVM })
        PublicScreenLayer({ chatManager: this.interactionMgr.chatMgr, interactionMgr: this.interactionMgr })

        if (this.preferType === PreferType.LANDSCAPE) {
          VideoMaskLayer({
            onFullScreen: () => {
              this.interactionMgr.onFullScreen()
            }
          }).position({ y: 160 })
            .width('100%')
            .height(204)
        }

        BottomLineLayer({
          shareInfo:this.interactionMgr.shareInfo,
          defaultResolution: this.interactionMgr.defaultResolution,
          bulletVM: this.bulletVM,
          giftData: this.interactionMgr.giftData,
          clearScreen: () => {
            this.showControl = false
            this.interactionMgr.onClearScreen(!this.showControl)
          },
          toComment: () => {
            this.interactionMgr.onComment()
          },
          onPip: this.interactionMgr.onPip,
          onChangeResolution: this.interactionMgr.onChangeResolution,
          onReport: this.interactionMgr.onReport,
          onCheckAndLogin: (): boolean => {
            if (!this.interactionMgr.onCheckLogin()) {
              if (!this.interactionMgr.onLogin()) {
                return false;
              }
            }
            return true;
          },
          onGetUserInfo: this.interactionMgr.onGetLoginUserInfo,
          onPay: this.interactionMgr.onPay,
          userAvatar: this.userAvatar
        })
        CanvasLikeLayer({ onLike: this.interactionMgr.onLike })
          .hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%')
      .height('100%')
      .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)

      DetailTopInfo({
        presenter: this.interactionMgr.presenter,
        audienceList: this.interactionMgr.audiences,
        onCheckLogin: this.interactionMgr.onCheckLogin,
        onLogin: this.interactionMgr.onLogin,
        onDeleteFollowingClick: this.interactionMgr.onDeleteFollowingClick,
        onAddFollowingClick: this.interactionMgr.onAddFollowingClick,
        onProfileClick: this.interactionMgr.onProfileClick,
        onExit: this.interactionMgr.onExit,
        showControl: this.showControl
      })

      if (!this.showControl) {
        Row() {
          Column() {
            Text('退出清屏')
              .width(64)
              .height(21)
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#fff')
              .textAlign(TextAlign.Center)
          }
          .width(96)
          .height(40)
          .borderRadius(20)
          .margin({ right: 16 })
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.showControl = true
            this.interactionMgr.onClearScreen(!this.showControl)
          })
        }
        .justifyContent(FlexAlign.End)
        .width('100%')
        .position({ top: 676 })
      }

    }
    .zIndex(3)
    .width('100%')
    .height('100%')
  }

  @Builder
  moreLiveBuilder() {
    Row() {
      Column()
      .height('100%')
      .layoutWeight(1)
        .onClick(() => {
          this.promptAction.closeCustomDialog(this.moreLive)
          this.isShowMoreLive = false
        })
      Row() {
        LiveList({
          setHide: () => {
            this.promptAction.closeCustomDialog(this.moreLive)
            this.isShowMoreLive = false
          },
          onGetMoreLive: this.interactionMgr.onGetMoreLives,
          onLiveClick: this.interactionMgr.onLiveClick
        })
      }
      .height('100%')
      .width('90%')
      .backgroundColor($r('app.color.normal_font_color'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    }
    .position({ right: this.isShowMoreLive ? 0 : -330 })
    .animation({ duration: 200, curve: Curve.Smooth })
    .backgroundColor(Color.Transparent)
    .width('100%')
    .height('100%')
  }
}