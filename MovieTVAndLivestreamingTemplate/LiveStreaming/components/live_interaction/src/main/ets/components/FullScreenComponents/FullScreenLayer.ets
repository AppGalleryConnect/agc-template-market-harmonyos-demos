import { LiveInteractionMgr, LoginUserInfo } from '../../manager/LiveInteractionMgr'
import { CanvasLike } from '../../view/CanvasLike'
import { BottomLineLayer } from '../BottomLineLayer'
import { BulletLayer } from '../BulletLayer'
import { DetailTopInfo } from '../DetailTopInfo'
import { FullScreenBulletSetting } from './FullScreenBulletSetting'
import { FullScreenGift } from './FullScreenGift'
import { FullScreenReport } from './FullScreenReport'
import { FullScreenResolution } from './FullScreenResolution'
import { FullScreenShare } from './FullScreenShare'
import { FullScreenSharePost } from './FullScreenSharePost'
import { AppStorageV2, window } from '@kit.ArkUI'
import { BulletVM } from '../../viewModels/BulletVM'

const TAG = '[FullScreenLayer]'

@ComponentV2
export struct FullScreenLayer {
  @Param @Require interactionMgr: LiveInteractionMgr
  @Local showControl: boolean = true
  @Local isShowBullet: boolean = true
  @Local canChange: boolean = true
  @Local isLock: boolean = true
  @Local userAvatar: Resource | string = $r('app.media.person')
  @Local userName: string = 'momo'
  @Local bulletVM: BulletVM = AppStorageV2.connect(BulletVM, 'bulletVM', () => new BulletVM())!
  private promptAction = this.getUIContext().getPromptAction()
  private moreSetting: number = 0
  private share: number = 0
  private poster: number = 0
  private bulletSetting: number = 0
  private resolution: number = 0
  private report: number = 0
  private gift: number = 0
  private windowStage: window.WindowStage = AppStorage.get('windowStage')!;

  onBackPressed(): boolean | void {
    this.interactionMgr.onFullScreen(false)
  }

  aboutToAppear(): void {
    this.windowStage.getMainWindowSync().setWindowSystemBarEnable([])
    this.bulletVM.direction = 1
    if (this.interactionMgr.onCheckLogin()) {
      let userInfo: LoginUserInfo = this.interactionMgr.onGetLoginUserInfo()
      if (userInfo) {
        this.userAvatar = userInfo.avatar
        this.userName = userInfo.name
      }
    }
  }

  aboutToDisappear(): void {
    this.windowStage.getMainWindowSync().setWindowSystemBarEnable(['status', 'navigation'])
  }

  build() {
    Stack() {
      Stack({ alignContent: Alignment.TopStart }) {
        DetailTopInfo({
          screenDirection: 1,
          presenter: this.interactionMgr.presenter,
          audienceList: this.interactionMgr.audiences,
          setToVertical: this.interactionMgr.onFullScreen,
          onCheckLogin: this.interactionMgr.onCheckLogin,
          onLogin: this.interactionMgr.onLogin,
          onDeleteFollowingClick:this.interactionMgr.onDeleteFollowingClick,
          onAddFollowingClick:this.interactionMgr.onAddFollowingClick,
          onProfileClick:this.interactionMgr.onProfileClick
        })
          .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)
          .zIndex(2)
        Column(){
          BulletLayer({ screenDirection: 1, bulletVM: this.bulletVM })
            .visibility(this.isShowBullet ? Visibility.Visible : Visibility.Hidden)
            .zIndex(1)
          Blank()
          BottomLineLayer({
            shareInfo:this.interactionMgr.shareInfo,
            defaultResolution: this.interactionMgr.defaultResolution,
            bulletVM: this.bulletVM,
            giftData: this.interactionMgr.giftData,
            userAvatar: this.userAvatar,
            screenDirection: 1,
            openMore: async () => {
              this.moreSetting = await this.promptAction.openCustomDialog({
                builder: () => {
                  this.moreSettingBuilder()
                },
                width: '100%',
                height: '100%',
                backgroundBlurStyle: BlurStyle.NONE,
                backgroundColor: Color.Transparent,
                cornerRadius: 0,
                alignment: DialogAlignment.Bottom
              })
              this.showControl = false
              this.isLock = false
            },
            openGift: async () => {
              this.gift = await this.promptAction.openCustomDialog({
                builder: () => {
                  this.giftBuilder()
                },
                width: '100%',
                height: '100%',
                backgroundBlurStyle: BlurStyle.NONE,
                backgroundColor: Color.Transparent,
                cornerRadius: 0,
                alignment: DialogAlignment.Bottom
              })
            },
            hideBullet: () => {
              this.isShowBullet = !this.isShowBullet
            },
            openBulletSetting: async () => {
              this.bulletSetting = await this.promptAction.openCustomDialog({
                builder: () => {
                  this.bulletSettingBuilder()
                },
                width: '100%',
                height: '100%',
                backgroundBlurStyle: BlurStyle.NONE,
                backgroundColor: Color.Transparent,
                cornerRadius: 0,
                alignment: DialogAlignment.Bottom
              })
            },
            onCheckAndLogin: (): boolean => {
              if (!this.interactionMgr.onCheckLogin()) {
                if (!this.interactionMgr.onLogin()) {
                  return false;
                }
              }
              this.userAvatar = this.interactionMgr.onGetLoginUserInfo()?.avatar
              this.userName = this.interactionMgr.onGetLoginUserInfo()?.name
              return true;
            },
            onGetUserInfo: this.interactionMgr.onGetLoginUserInfo,
            onChangeScreen: this.interactionMgr.onFullScreen,
            toComment: () => {
              this.interactionMgr.onComment()
            },
          })
            .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)
        }
        .height('100%')
        CanvasLike({ onLike: this.interactionMgr.onLike })
          .hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%')
      .height('100%')
      .onClick(() => {
        if(this.canChange) {
          this.showControl = !this.showControl
          this.isLock = this.showControl
        }else {
          this.isLock = !this.isLock
        }
      })

      Row() {
        Row() {
          Image(this.canChange ? $r('app.media.lock_open') : $r('app.media.lock_close'))
            .width(40)
            .height(40)
        }
        .width(40)
        .height(40)
        .borderRadius(69)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 22 })
        .backgroundColor($r('app.color.report_placeholder'))
        .onClick(() => {
          this.canChange = !this.canChange
          this.showControl = this.canChange
        })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.End)
      .visibility(this.isLock ? Visibility.Visible : Visibility.Hidden)
      .onClick(() => {
        if(this.canChange) {
          this.showControl = !this.showControl
          this.isLock = this.showControl
        }else {
          this.isLock = !this.isLock
        }
      })
    }
    .zIndex(3)
    .width('100%')
    .height('100%')
  }


  @Builder
  moreSettingBuilder() {
    Row() {
      Column()
        .height('100%')
        .layoutWeight(1)
        .onClick(() => {
          this.promptAction.closeCustomDialog(this.moreSetting)
        })
      Column() {
        Row() {
          Text('更多')
            .height(27)
            .fontSize(20)
            .fontWeight(700)
            .fontColor('#fff')
            .margin({ left: 24 })
        }
        .width('100%')
        .height(56)
        .margin({ top: 22 })

        Row() {
          Column() {
            Image($r('app.media.share_white'))
              .width(32)
              .height(32)
              .margin({ bottom: 2, top: 4 })
            Text('分享')
              .width(74)
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(500)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 })
          }
          .width(82)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(async () => {
            this.share = await this.promptAction.openCustomDialog({
              builder: () => {
                this.shareBuilder()
              },
              width: '100%',
              height: '100%',
              backgroundBlurStyle: BlurStyle.NONE,
              backgroundColor: Color.Transparent,
              cornerRadius: 0,
              alignment: DialogAlignment.Bottom
            })
          })

          Column() {
            Image($r('app.media.bullet_white'))
              .width(32)
              .height(32)
              .margin({ bottom: 2, top: 4 })
            Text('弹幕设置')
              .width(74)
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(500)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 })
          }
          .width(82)
          .height(56)
          .onClick(async () => {
            this.bulletSetting = await this.promptAction.openCustomDialog({
              builder: () => {
                this.bulletSettingBuilder()
              },
              width: '100%',
              height: '100%',
              backgroundBlurStyle: BlurStyle.NONE,
              backgroundColor: Color.Transparent,
              cornerRadius: 0,
              alignment: DialogAlignment.Bottom
            })
          })
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.small_window_white'))
              .width(32)
              .height(32)
              .margin({ bottom: 2, top: 4 })
            Text('画中画')
              .width(74)
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(500)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 })
          }
          .width(82)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.promptAction.closeCustomDialog(this.moreSetting)
            this.interactionMgr.onPip()
            this.interactionMgr.onFullScreen()
          })

          Column() {
            Image($r('app.media.hd_plus_rectangle_white'))
              .width(32)
              .height(32)
              .margin({ bottom: 2, top: 4 })
            Text('清晰度')
              .width(74)
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(500)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 })
          }
          .width(82)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(async () => {
            this.resolution = await this.promptAction.openCustomDialog({
              builder: () => {
                this.resolutionBuilder()
              },
              width: '100%',
              height: '100%',
              backgroundBlurStyle: BlurStyle.NONE,
              backgroundColor: Color.Transparent,
              cornerRadius: 0,
              alignment: DialogAlignment.Bottom
            })
          })
        }
        .width('100%')
        .height(58)
        .margin({ left: 29, top: 8 })

        Row() {
          Column() {
            Image($r('app.media.report_white'))
              .width(32)
              .height(32)
              .margin({ bottom: 2, top: 4 })
            Text('举报')
              .width(74)
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(500)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 })
          }
          .width(82)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(async () => {
            this.report = await this.promptAction.openCustomDialog({
              builder: () => {
                this.reportBuilder()
              },
              width: '100%',
              height: '100%',
              backgroundBlurStyle: BlurStyle.NONE,
              backgroundColor: Color.Transparent,
              cornerRadius: 0,
              alignment: DialogAlignment.Bottom
            })
          })
        }
        .width('100%')
        .height(58)
        .margin({ left: 29, top: 8 })
      }
      .width(368)
      .height('100%')
      .backgroundColor($r('app.color.normal_font_color'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    }
    .width('100%')
    .height('100%')
  }


  @Builder
  shareBuilder() {
    FullScreenShare({
      setHide: () => {
        this.promptAction.closeCustomDialog(this.share)
      },
      closeAll: () => {
        this.promptAction.closeCustomDialog(this.share)
        this.promptAction.closeCustomDialog(this.moreSetting)
      },
      openSharePost: async () => {
        this.poster = await this.promptAction.openCustomDialog({
          builder: () => {
            this.posterBuilder()
          },
          width: '100%',
          height: '100%',
          backgroundBlurStyle: BlurStyle.NONE,
          backgroundColor: Color.Transparent,
          cornerRadius: 0,
          alignment: DialogAlignment.Bottom
        })
      }
    })
  }


  @Builder
  posterBuilder() {
    FullScreenSharePost({
      setHide: () => {
        this.promptAction.closeCustomDialog(this.poster)
      },
      closeAll: () => {
        this.promptAction.closeCustomDialog(this.poster)
        this.promptAction.closeCustomDialog(this.share)
        this.promptAction.closeCustomDialog(this.moreSetting)
      }
    })
  }


  @Builder
  bulletSettingBuilder() {
    FullScreenBulletSetting({
      setHide: () => {
        this.promptAction.closeCustomDialog(this.bulletSetting)
      },
      closeAll: () => {
        this.promptAction.closeCustomDialog(this.bulletSetting)
        this.promptAction.closeCustomDialog(this.moreSetting)
      }
    })
  }


  @Builder
  resolutionBuilder() {
    FullScreenResolution({
      defaultResolution: this.interactionMgr.defaultResolution,
      setHide: () => {
        this.promptAction.closeCustomDialog(this.resolution)
      },
      closeAll: () => {
        this.promptAction.closeCustomDialog(this.resolution)
        this.promptAction.closeCustomDialog(this.moreSetting)
      },
      onChangeResolution: this.interactionMgr.onChangeResolution
    })
  }


  @Builder
  reportBuilder() {
    FullScreenReport({
      setHide: () => {
        this.promptAction.closeCustomDialog(this.report)
      },
      closeAll: () => {
        this.promptAction.closeCustomDialog(this.report)
        this.promptAction.closeCustomDialog(this.moreSetting)
      },
      onReport: this.interactionMgr.onReport
    })
  }


  @Builder
  giftBuilder() {
    FullScreenGift({
      giftData: this.interactionMgr.giftData,
      setHide: () => {
        this.promptAction.closeCustomDialog(this.gift)
      },
      onPay: this.interactionMgr.onPay
    })
  }


}