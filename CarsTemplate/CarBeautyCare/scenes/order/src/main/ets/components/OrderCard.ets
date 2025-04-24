import { LocationVM } from '@ohos_agcit/car_beauty_care_shop';
import { PromptAction } from '@kit.ArkUI';
import { ProductCard, ProductVM } from '@ohos_agcit/car_beauty_care_product';
import { Order, OrderVM } from '../model/OrderVM';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';
import { CouponVM } from '@ohos_agcit/car_beauty_care_coupon';


@ComponentV2
export struct OrderCard {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  productVM: ProductVM = ProductVM.instance;
  locationVM: LocationVM = LocationVM.instance;
  orderVM: OrderVM = OrderVM.instance;
  // couponVM: CouponVM = CouponVM.instance;
  @Local totalCount: number = 0;
  @Param orderCard: Order = this.orderVM.orderList[0]; // 订单信息
  @Local totalPrice: number = 0; // 订单总价格

  aboutToAppear() {
    this.calculateTotalPrice();
    this.calTotalCount();
  }


  calTotalCount() {
    if (this.orderCard.coupon !== null) {
      this.totalCount = this.totalPrice - this.orderCard.coupon.couponNumber;
    }
  }

  calculateTotalPrice() {
    this.totalPrice = this.orderCard.product.reduce((sum, product) => sum + product.price, 0);
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.shop'))
          .width(16)
          .height(16)
          .margin({ right: 6 });

        Text(this.orderCard.shop.name)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .layoutWeight(1);

        Text($r('app.string.closed'))
          .fontSize(14)
          .fontColor($r('app.color.littleRed'));
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding(16);

      // 产品信息，需要foreach循环
      ForEach(this.orderCard.product, (product: ProductCard) => {
        Row() {
          Image($r('app.media.order_car'))
            .width(72)
            .height(72)
            .margin({ right: 12 });

          Text(product.introduction)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .layoutWeight(1)
            .margin({ right: 12 });

          Column() {
            Text('￥' + product.price)
              .fontSize(14)
              .fontColor($r('app.color.deepDark'));
            Text('x' + 1)
              .fontSize(12)
              .fontColor($r('app.color.lightDark'))
              .alignSelf(ItemAlign.End);
          }
          .padding({ left: 12 });
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.FULL_WIDTH)
        .padding({ left: 16, right: 16 });
      });

      Column() {
        Row() {
          Text(`共${this.orderCard.product.length}项服务，`)
            .fontSize(12)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: 12 })
            .alignSelf(ItemAlign.End);

          Text(`实付款${this.totalCount}`)
            .fontSize(12)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: 12 })
            .alignSelf(ItemAlign.End);
        }
        .justifyContent(FlexAlign.End)
        .width(CommonConstants.FULL_WIDTH)

        Button($r('app.string.good_deal'))
          .width(82)
          .height(28)
          .fontColor($r('app.color.lightRed'))
          .fontSize(12)
          .borderRadius(14)
          .alignSelf(ItemAlign.End)
          .backgroundColor(Color.White)
          .borderColor($r('app.color.lightRed'))
          .borderWidth(1);
      }
      .padding(16)
      .width(CommonConstants.FULL_WIDTH);
    }
    .onClick(() => {

    })
    .width(CommonConstants.FULL_WIDTH)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(10)
    .margin({ bottom: 12 });
  }
}