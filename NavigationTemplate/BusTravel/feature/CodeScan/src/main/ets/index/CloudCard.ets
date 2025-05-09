import { RouteEntryVM } from 'common'
import { Common, Logger, preferencesUtil } from 'common'
import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@kit.BasicServicesKit';
import { CodeScanPage } from './CodeScanPage';
import { UserInfo } from 'common';

@Builder
export function CloudCardBuilder() {
  CloudCard()
}

@Component
export struct CloudCard {
  @StorageLink('cloudCard') cloudCard: boolean = AppStorage.get('cloudCard') ?? false;
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? new UserInfo();
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State usingTexts: string[] =
    ['1.开通乘车码：点击下方“领取电子卡”，确认信息，勾选协议，点击“点击同意协议并领卡”和“开通免密支付”。',
      ' 2.扫码乘车：上车时打开乘车码界面，将手机屏幕上的乘车码对准公交车上的扫码设备，听到“滴”声或看到相关提示即表示刷码成功，乘车费用会在余额中自动扣除。'];

  aboutToAppear(): void {
    //进入时判断用户是否已开通云卡
    preferencesUtil.getPreferencesValue(Common.CLOUDCARD, Common.CLOUDCARD_USE, false)
      .then((value: dataPreferences.ValueType | undefined) => {
        this.cloudCard = value as boolean
      }).catch((e: BusinessError) => {
      Logger.error(`Preferences value get error. code: ${e.code}. msg:${e.message}`)
    })
  }

  saveCloudCardUse() {
    this.cloudCard = true
    preferencesUtil.putPreferencesValue(Common.CLOUDCARD, Common.CLOUDCARD_USE, true)
  }

  build() {
    NavDestination() {
      if (this.isLogin === true && this.cloudCard) {
        CodeScanPage()
      } else {
        Column() {
          Column(){
            this.buildTitle()
            this.buildCard()
            this.buildUsing()
          }

          Button('开通')
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Body_L'))
            .width('312lpx')
            .backgroundColor($r('app.color.system_color_green'))
            .onClick(() => {
              if (this.isLogin === false) {
                this.vm.toRouteDetail('Login')
              } else if (this.cloudCard === false) {
                this.vm.toRouteDetail('ActivateCloudCard')
              } else { // 跳转到二维码页面并且记住用户已经开通过云卡
                this.saveCloudCardUse()
              }
            })
            .margin({bottom:20})
        }
        .width('100%')
        .height('100%')
        .align(Alignment.TopStart)
        .backgroundImageSize(ImageSize.Auto)
        .backgroundColor('#F1F3F5')
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }.hideTitleBar(true)
  }

  @Builder
  buildTitle() {
    Row() {
      Text('乘车码')
        .fontColor($r('sys.color.black'))
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 24 })
    }
    .width('100%')
    .height(70)
    .align(Alignment.Start)
  }

  @Builder
  buildCard() {
    Column() {
      Row() {
        Text('南京公交')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_secondary'))
          .textAlign(TextAlign.Start)
        Row()
      }
      .width('100%')
      .height(19)
      .justifyContent(FlexAlign.SpaceBetween)

      Text('城市一卡通')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_secondary'))
        .textAlign(TextAlign.Center)
        .width('100%')
        .align(Alignment.Center)

      Row()
        .width('100%')
        .height(19)
    }
    .width('328lpx')
    .height('160lpx')
    .backgroundImage($r('app.media.grey'))
    .backgroundImageSize({ width: '328lpx', height: '160lpx' })
    .padding({ left: 17, top: 13, bottom: 13 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildUsing() {
    Column() {
      Text('使用说明：')
        .fontSize(14)
        .width('100%')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
        .align(Alignment.Start)
      Text(this.usingTexts[0])
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: 12 })
        .width('100%')
      Text(this.usingTexts[1])
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .width('100%')
    }
    .width('328lpx')
    .padding(20)
    .margin({ top: 12 })
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius(20)
    .align(Alignment.Start)
  }
}