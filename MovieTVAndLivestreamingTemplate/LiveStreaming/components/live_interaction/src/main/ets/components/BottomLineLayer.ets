import { titleBuilder } from './Common'
import { Gifts } from './VerticalScreenComponents/Gifts'
import { Settings } from './Settings'
import { GiftModel } from '../models/GiftGroup'
import { ChangeScreen } from '../view/ChangeScreen'
import { BulletVM } from '../viewModels/BulletVM'
import { display, MeasureText } from '@kit.ArkUI'
import { BulletItem } from '../models/BulletItem'
import { Audience } from '../models/Audience'
import { ShareInfo } from '../manager/LiveInteractionMgr'
import { deviceInfo } from '@kit.BasicServicesKit'

@ComponentV2
export struct BottomLineLayer {
  @Param @Require shareInfo: ShareInfo
  @Param @Require defaultResolution: string
  @Param @Require bulletVM: BulletVM
  @Local isShowPlaySettingSheet: boolean = false
  @Local isShowGiftSheet: boolean = false
  @Local isShowGiftPopup: boolean = false
  @Local myBullet: string = ''
  @Local isBulletOpen: boolean = true
  @Param screenDirection: number = 0
  private uiContext: UIContext = this.getUIContext();
  @Require @Param giftData: Array<GiftModel>
  @Local userName: string = ''
  @Event clearScreen: () => void
  @Event openMore: () => void
  @Event openGift: () => void
  @Event toComment: () => void
  @Event openBulletSetting: () => void
  @Event hideBullet: () => void
  @Event onPip: Function = () => {
  }
  @Event onChangeResolution: Function = () => {
  }
  @Event onReport: Function = () => {
  }
  @Event onCheckAndLogin: Function = () => {
  }
  @Event onGetUserInfo: Function = () => {
  }
  @Param userAvatar: Resource | string = $r('app.media.person')
  @Event onPay: Function = (item: GiftModel) => {

  }
  @Event onChangeScreen: Function = () => {
  }

  @Builder
  playSettingSheetBuilder() {
    Settings({
      shareInfo: this.shareInfo,
      defaultResolution: this.defaultResolution,
      bulletVM: this.bulletVM,
      sheetHide: () => {
        this.isShowPlaySettingSheet = false
      },
      clearScreen: () => this.clearScreen(),
      onPip: this.onPip,
      onChangeResolution: this.onChangeResolution,
      onReport: this.onReport
    })
      .height(169)
  }

  onBack() {
    if (deviceInfo.deviceType === 'phone' &&
      display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
      this.isShowGiftSheet = false
    } else {
      this.isShowGiftPopup = false
    }
  }

  @Builder
  giftSheetBuilder() {
    Gifts({
      giftData: this.giftData, onPay: this.onPay, onBack: () => {
        this.onBack()
      }
    })
      .width('100%')
      .height(deviceInfo.deviceType === 'phone' &&
        display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED ? 240 : 560)
      .borderRadius({ topLeft: 32, topRight: 32 })
  }

  build() {
    Stack() {
      Row() {
        if (this.screenDirection === 1) {
          Row() {
            Image(this.isBulletOpen ? $r('app.media.bullet_open') : $r('app.media.bullet_close'))
              .width(32)
              .height(32)
          }
          .margin({ left: 24 })
          .width(40)
          .height(40)
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .onClick(() => {
            this.isBulletOpen = !this.isBulletOpen
            this.hideBullet()
          })

          Row() {
            Image($r('app.media.bullet_white'))
              .width(32)
              .height(32)
          }
          .margin({ left: 8 })
          .width(40)
          .height(40)
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .onClick(() => {
            this.openBulletSetting()
          })
        }

        Row() {
          Image(this.userAvatar)
            .width(32)
            .height(32)
            .backgroundColor(Color.White)
            .borderRadius(32)
            .margin({ left: 4 })
          if (this.screenDirection === 0) {
            Text('聊一聊吧')
              .fontSize(14)
              .lineHeight(19)
              .fontWeight(500)
              .margin({ left: 8 })
              .fontColor('rgba(255, 255, 255, 0.6)')
              .onClick(() => {
                if (this.onCheckAndLogin()) {
                  this.toComment()
                }
              })
              .layoutWeight(1)
          } else {
            TextInput({ placeholder: '聊一聊吧', text: this.myBullet })
              .fontColor('rgba(255, 255, 255, 0.9)')
              .fontSize(14)
              .maxLength(20)
              .margin({ left: 8 })
              .onChange((v) => {
                this.myBullet = v
              })
              .onClick(() => {
                this.onCheckAndLogin()
              })
              .onSubmit(() => {
                this.bulletVM.bulletComments = [...this.bulletVM.bulletComments, new BulletItem(
                  this.myBullet,
                  true,
                  this.bulletVM.storage.setting.get('setting')?.rowsNum!,
                  this.bulletVM.storage.setting.get('setting')?.notOpacity!,
                  this.bulletVM.storage.setting.get('setting')?.danMuSpeed!,
                  this.bulletVM.storage.setting.get('setting')?.danMuSize!,
                )]
                this.bulletVM.xTrans = [...this.bulletVM.xTrans,
                  (this.bulletVM.xTrans[this.bulletVM.bulletComments.length -
                    this.bulletVM.storage.setting.get('setting')?.rowsNum!] + 30 +
                  this.uiContext.px2vp(this.uiContext.getMeasureUtils().measureText({
                    textContent: this.bulletVM.bulletComments[this.bulletVM.bulletComments.length -
                      this.bulletVM.storage.setting.get('setting')?.rowsNum!].content,
                    fontSize: `20vp`
                  })))]
                this.myBullet = ''
              })
          }
        }
        .height(40)
        .backgroundColor('rgba(0,0,0,0.4)')
        .borderRadius(999)
        .margin({ left: this.screenDirection === 0 ? 16 : 8, right: 8 })
        .layoutWeight(1)

        if (this.screenDirection === 1) {
          ChangeScreen({ onChangeScreen: this.onChangeScreen })
            .margin({ right: 8 })
        }

        Row() {
          Image($r('app.media.gifts'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.mask_tertiary'))
        .margin({ right: 8 })
        .onClick(() => {
          if (this.onCheckAndLogin()) {
            if (this.screenDirection === 0) {
              if (deviceInfo.deviceType === 'phone' &&
                display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
                this.isShowGiftSheet = true
              } else {
                this.isShowGiftPopup = true
              }
            } else {
              this.openGift()
            }
          }
        })
        .bindSheet($$this.isShowGiftSheet, this.giftSheetBuilder(), {
          height: 294,
          preferType: SheetType.CENTER,
          showClose: false
        })
        .bindPopup(this.isShowGiftPopup, {
          builder: this.giftSheetBuilder(),
          placement: Placement.TopRight,
          offset: { x: 8 },
          width: 400,
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.isShowGiftPopup = false
            }
          }
        })

        Image($r('app.media.more'))
          .margin({ right: 16 })
          .padding(8)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .onClick(() => {
            if (this.screenDirection === 0) {
              this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet
            } else {
              this.openMore()
            }
          })
          .bindSheet($$this.isShowPlaySettingSheet, this.playSettingSheetBuilder(), {
            height: 233,
            preferType: SheetType.CENTER,
            title: titleBuilder('更多')
          })
      }
      .width('100%')
      .height(40)
    }
    .position({ bottom: 16 })
  }
}

