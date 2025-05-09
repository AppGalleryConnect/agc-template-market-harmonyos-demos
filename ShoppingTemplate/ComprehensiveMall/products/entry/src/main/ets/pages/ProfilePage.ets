import { iData } from '@common/data';
import { router } from '@common/router';
import { LoginButton } from '@components/loginbutton';
import { CallButton } from '@components/callbutton';
import { ProfilePageLogic } from '../logic/ProfilePageLogic';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct ProfilePage {

  private logic: ProfilePageLogic = new ProfilePageLogic();

  build(): void {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('40%')
        .linearGradient({
          colors: [['#30E64566', 0], ['#00E64566', 1.0]]
        })
        .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP])
      Column() {
        Column() {
          Text('个人中心')
            .fontSize(18)
            .fontColor('#E6000000')
            .fontWeight(500)
            .margin({ left: 3 })
        }
        .width('100%')
        .height(56)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        buildUserInfoArea(this.logic)
        buildOrderInfoArea()
        buildMenuArea()
      }
      .width('100%')
      .height('100%')
      .padding({ left: 13, right: 13 })
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
export function buildProfilePage() {
  ProfilePage()
}

@Builder
function buildUserInfoArea(logic: ProfilePageLogic) {
  Row() {
    Row() {
      Image($r('app.media.default_avatar'))
        .width(68)
        .height(68)
        .draggable(false)
      Column() {
        Text(iData.global.isLogin ? iData.global.nickname : '华为用户')
          .fontWeight(600)
          .fontSize(15)
          .fontColor('#E6000000')
        if (iData.global.isLogin) {
          Text(iData.global.phone)
            .fontSize(15)
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .height(70)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ left: 10 })
    }
    LoginButton({
      onStart: (needWaitFinish: boolean) => logic.onLoginButtonStart(needWaitFinish)
    }) {
      Button() {
        Text(iData.global.isLogin ? '取消关联' : '关联账号')
          .fontSize(13)
          .fontColor(Color.White)
      }
      .width(80)
      .height(30)
      .type(ButtonType.Normal)
      .backgroundColor('#FFE64566')
      .borderRadius(21)
    }
  }
  .width('100%')
  .padding({ left: 10, right: 13 })
  .justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
}

@Builder
function buildOrderInfoArea() {
  Column() {
    Row() {
      Text('我的订单')
        .fontSize(15)
        .fontWeight(600)
        .fontColor('#E6000000')
      LoginButton({
        onStart: (needWaitFinish: boolean) => {
          if (!needWaitFinish && iData.global.isLogin) {
            router.pushPathByName('OrderBrowsingPage', 0)
          }
        },
        onFinish: () => {
          if (iData.global.isLogin) {
            router.pushPathByName('OrderBrowsingPage', 0)
          }
        }
      }) {
        Row() {
          Text('全部')
            .fontColor($r('sys.color.mask_tertiary'))
            .fontSize(12)
          Image($r('app.media.ic_left_arrow'))
            .height(13)
            .objectFit(ImageFit.Contain)
            .rotate({ angle: 180 })
            .fillColor($r('sys.color.mask_tertiary'))
            .draggable(false)
        }
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 18, right: 10 })
    Row() {
      buildOrderTab($r('app.media.ic_order_pending_payment'), '待付款', 1)
      buildOrderTab($r('app.media.ic_order_pending_shipment'), '待发货', 2)
      buildOrderTab($r('app.media.ic_order_pending_receipt'), '待收货', 3)
      buildOrderTab($r('app.media.ic_order_pending_review'), '待评价', -1)
      buildOrderTab($r('app.media.ic_order_refund_after_sale'), '退款/售后', 4)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 18, right: 18, bottom: 20, top: 6 })
  }
  .width('100%')
  .borderRadius(18)
  .backgroundColor(Color.White)
  .margin({ top: 24 })
}

@Builder
function buildMenuArea() {
  Column() {
    CallButton() {
      Row() {
        Image($r('app.media.ic_call_center'))
          .draggable(false)
          .height(18)
          .objectFit(ImageFit.Contain)
          .margin({ right: 10 })
        Row() {
          Text('联系客服')
            .fontSize(13)
            .fontColor($r('sys.color.mask_secondary'))
          Image($r('app.media.ic_left_arrow'))
            .height(18)
            .objectFit(ImageFit.Contain)
            .rotate({ angle: 180 })
            .fillColor($r('sys.color.mask_tertiary'))
            .draggable(false)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height(50)
    }
  }
  .width('100%')
  .borderRadius(18)
  .backgroundColor(Color.White)
  .margin({ top: 24 })
  .padding({ left: 13, right: 13 })
}

@Builder
function buildOrderTab(icon: ResourceStr, label: string, type: number) {
  LoginButton({
    onStart: (needWaitFinish: boolean) => {
      if (!needWaitFinish && iData.global.isLogin) {
        if (type === -1) {
          promptAction.showToast({ message: '您可以按照自身业务逻辑接入评论中心' });
        } else {
          router.pushPathByName('OrderBrowsingPage', type)
        }
      }
    },
    onFinish: () => {
      if (iData.global.isLogin) {
        if (type === -1) {
          promptAction.showToast({ message: '您可以按照自身业务逻辑接入评论中心' });
        } else {
          router.pushPathByName('OrderBrowsingPage', type)
        }
      }
    }
  }) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Cover)
        .fillColor($r('sys.color.mask_secondary'))
        .margin({ bottom: 7 })
      Text(label)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.mask_secondary'))
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
