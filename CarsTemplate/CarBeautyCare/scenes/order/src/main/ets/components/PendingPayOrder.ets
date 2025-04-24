import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function PendingPayOrderBuilder() {
  PendingPayOrder()
}

@ComponentV2
export struct PendingPayOrder {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }
  build() {
    NavDestination() {
      Scroll() {
        Column() {
          OrderItem()
          OrderItem()
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_HEIGHT)
        .backgroundColor('#F1F3F5')
      }
    }
    .title('全部订单')
    .margin({
      top:px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })

  }
}

@ComponentV2
struct OrderItem {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();


  build() {
    Column() {
      Row() {
        Image($r('app.media.shop'))
          .width(16)
          .height(16)
          .margin({ right: 6 });

        Text('华为洗护（软件大道店）')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .layoutWeight(1)

        Text('待付款')
          .fontSize(14)
          .fontColor('#FF5500')
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding(16)

      ServiceItem()

      ServiceItem()

      Column() {
        Text('共2项服务，实付款199')
          .fontSize(12)
          .fontColor('#000000')
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: 12 })
          .alignSelf(ItemAlign.End)

        Button('立即付款')
          .width(82)
          .height(28)
          .fontColor('#EE3B55')
          .fontSize(12)
          .fontFamily('鸿蒙黑体')
          .borderRadius(14)
          .alignSelf(ItemAlign.End)
          .backgroundColor(Color.White)
          .borderColor('#EE3B55')
          .borderWidth(1)
      }
      .padding(16)
      .width(CommonConstants.FULL_WIDTH)
    }
    .onClick(() => {
      this.appPathStack.pushPathByName('pendingPay', true)
    })
    .margin({ top: 12 })
    .height(286)
    .width(322)
    .borderRadius(16)
    .padding(2)
    .backgroundColor(Color.White)

  }

}

@Component
struct ServiceItem {
  build() {
    Row() {
      Image($r('app.media.order_car'))
        .width(72)
        .height(72)
        .margin({ right: 12 })

      Text('标准贴片补胎,17寸及以下含动态平衡')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .layoutWeight(1)
        .margin({ right: 12 })

      Column() {
        Text('￥100')
          .fontSize(14)
          .fontColor('#333333')
        Text('x1')
          .fontSize(12)
          .fontColor('#666666')
          .alignSelf(ItemAlign.End)
      }
      .padding({ left: 12 })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_WIDTH)
    .padding({ left: 16, right: 16 })
  }
}