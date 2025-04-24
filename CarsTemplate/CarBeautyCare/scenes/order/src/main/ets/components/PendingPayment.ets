import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function PendingPaymentBuilder() {
  PendingPayment()
}

@ComponentV2
export struct PendingPayment {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Column() {


        Column() {
          Row() {
            Text('某某洗护（软件大道店）')
              .fontSize(16)
              .fontWeight(FontWeight.Bold);


          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center);

          Text('江宁区宏景大道99号达美广场')
            .fontSize(14)
            .fontColor(Color.Gray)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 8 });


          Row() {
            Image($r('app.media.pendingpay_contact'))
              .width(16)
              .height(16)
              .margin({ right: 8 });

            Text('18010000000')
              .fontSize(14)
              .fontColor(Color.Gray);
          }
          .width(CommonConstants.FULL_WIDTH)
          .margin({ top: 8 });

          Row() {
            Image($r('app.media.car_little'))
              .width(16)
              .height(16)
              .margin({ right: 8 });

            Text('宝马5系')
              .fontSize(14)
              .fontColor(Color.Gray);
          }
          .width(CommonConstants.FULL_WIDTH)
          .margin({ top: 8 });
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ top: 16 });

        Column() {
          Row() {
            Text('商品服务')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black);

            Image($r('app.media.pendingpay_gou'))
              .width(16)
              .height(16)
              .margin({ left: 8 });

            Text('随时退')
              .fontSize(14)
              .fontColor(Color.Gray)
              .margin({ left: 8 });

            Image($r('app.media.pendingpay_gou'))
              .width(16)
              .height(16)
              .margin({ left: 8 });

            Text('过期退')
              .fontSize(14)
              .fontColor(Color.Gray)
              .margin({ left: 8 });
          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center);

          Row() {
            Image($r('app.media.pendingpay_carfix'))
              .width(72)
              .height(72)
              .margin({ right: 8 });

            Text('前挡风玻璃清洗，全车打蜡')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
              .layoutWeight(2)
              .margin({ right: 12 });

            Column() {
              Column() {
                Text('￥100')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.Black);

                Text('x1')
                  .fontSize(14)
                  .fontColor(Color.Gray)
                  .margin({ left: 8 });
              }
              .justifyContent(FlexAlign.End);

              Text('施工说明')
                .fontSize(12)
                .fontColor(Color.Gray)
                .alignSelf(ItemAlign.End);
            }
            .width(120)
            .layoutWeight(1)
            .margin({ left: 8 });
          }
          .width(CommonConstants.FULL_WIDTH)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .padding(6)
          .backgroundColor(Color.White)
          .margin({ top: 16 });
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ top: 16 });

        Column() {
          Row() {
            Text('订单总价')
              .fontSize(12);

            Text('￥100')
              .fontSize(12)
              .fontColor(Color.Black)
              .margin({ left: 8 });
          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center);

          Row() {
            Text('需付款')
              .fontSize(12);

            Text('￥100')
              .fontSize(12)
              .fontColor(Color.Red)
              .margin({ left: 8 });
          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .margin({ top: 8 });
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ top: 16 });

        Column() {
          Row() {
            Text('订单号')
              .fontSize(12);

            Text('123456789   复制')
              .fontSize(12);
          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center);

          Row() {
            Text('下单时间')
              .fontSize(12);

            Text('2023-10-01 12:00:00')
              .fontSize(12)
              .margin({ left: 8 });
          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .margin({ top: 8 });
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ top: 16, bottom: 62 });

        Row() {
          Button('取消订单')
            .width('45%')
            .height(40)
            .backgroundColor(Color.White)
            .fontColor(Color.Black)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 });

          Button('立即付款')
            .width('45%')
            .height(40)
            .backgroundColor(Color.Red)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Bold);
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding(16)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .margin({ top: 42 });
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .backgroundColor('#F1F3F5')
      .padding(16);
    }
    .title('待付款')
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });

  }
}