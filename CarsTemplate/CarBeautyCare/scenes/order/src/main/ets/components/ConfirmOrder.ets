import { ProductItem } from './ProductItem';
import { ProductVM, ProductCard } from '@ohos_agcit/car_beauty_care_product';
import { LocationVM } from '@ohos_agcit/car_beauty_care_shop';
import { OrderVM } from '../model/OrderVM';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'
import { VehicleVM } from '@ohos_agcit/car_beauty_care_garage'
import { CouponVM } from '@ohos_agcit/car_beauty_care_coupon'
import { ContactVM } from '@ohos_agcit/car_beauty_care_contact'

@Builder
export function ConfirmOrderBuilder() {
  ConfirmOrder();
}

@ComponentV2
export struct ConfirmOrder {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  productVM: ProductVM = ProductVM.instance;
  locationVM: LocationVM = LocationVM.instance;
  orderVM: OrderVM = OrderVM.instance;
  vehicleVM: VehicleVM = VehicleVM.instance;
  contactVM: ContactVM = ContactVM.instance;
  scroller = new Scroller();
  couponVM: CouponVM = CouponVM.instance;
  @Local totalCount: number = this.productVM.paidAmount;

  @Monitor('couponVM.willUserCoupon')
  calTotalCount() {
    if (this.couponVM.willUserCoupon !== null) {
      this.totalCount = this.productVM.paidAmount - this.couponVM.willUserCoupon.couponNumber;
    }
  }

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Scroll(this.scroller) {
          Column({ space: 12 }) {
            Column({ space: 8 }) {
              Row() {
                Text(this.locationVM.selectShopData.name)
                  .fontSize(14)
                  .fontColor('rgba(0,0,0,0.9)');
              }
              .width(CommonConstants.FULL_WIDTH);

              Row() {
                Text(this.locationVM.selectShopData.address)
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.4)');
              }
              .width(CommonConstants.FULL_WIDTH);

              Row() {
                Image($r('app.media.pendingpay_contact'))
                  .height(16)
                  .width(16)
                  .margin({
                    right: 8,
                  });
                Text(this.contactVM.getCurrentContact()?.contactNumber || '请选择')
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.9)');
                Blank();
                Image($r('app.media.ic_right_arrow'))
                  .height(14)
                  .width(14);
              }
              .width(CommonConstants.FULL_WIDTH)
              .onClick(() => {
                this.appPathStack.pushPathByName('contact', true)
              })

              Row() {
                Image($r('app.media.car_little'))
                  .height(16)
                  .width(16)
                  .margin({
                    right: 8,
                  });
                Text(this.vehicleVM.vehicle?.brandingMessage.name || '请选择车辆')
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.9)');
                Blank();
                Image($r('app.media.ic_right_arrow'))
                  .height(14)
                  .width(14);
              }
              .width(CommonConstants.FULL_WIDTH)
              .onClick(() => {
                this.appPathStack.pushPathByName('carSelect', true)
              })
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .width(CommonConstants.FULL_WIDTH)
            .padding({
              top: 16,
              left: 12,
              right: 12,
              bottom: 12,
            });

            Column() {
              Text($r('app.string.beauty_service'))
                .fontSize(18)
                .fontColor('rgba(0,0,0,0.9)')
                .fontWeight(FontWeight.Bold)
                .margin({
                  bottom: 16,
                })

              List({ space: 12 }) {
                ForEach(this.productVM.selectProduct, (item: ProductCard) => {
                  ListItem() {
                    ProductItem({
                      card: item,
                    })
                  }
                })
              }
              .layoutWeight(1)
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .padding({
              left: 12,
              right: 12,
              bottom: 12,
              top: 24,
            })
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column({ space: 12 }) {
              Row() {
                Text($r('app.string.order_price'))
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular);
                Blank();
                Text(`￥${this.productVM.paidAmount}`)
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular);
              }
              .width(CommonConstants.FULL_WIDTH);

              Row() {
                Text('优惠券')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                Blank()
                Text(this.couponVM.willUserCoupon === null?'请选择优惠券': String(this.couponVM.willUserCoupon.couponNumber))
                  .fontColor('#EE3B55')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                Image($r('app.media.ic_right_arrow'))
                  .width(14)
                  .height(14)
                  .fillColor('#EE3B55')
              }
              .width('100%')
              .onClick(() => {
                this.appPathStack.pushPathByName('myCouponList', true)
              })

              Row() {
                Text($r('app.string.payment_required'))
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium);
                Blank();
                Text(`￥${this.totalCount}`)
                  .fontColor($r('app.color.lightRed'))
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium);
              }
              .width(CommonConstants.FULL_WIDTH);
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .width(CommonConstants.FULL_WIDTH)
            .padding(12);

          }
          .width(CommonConstants.FULL_WIDTH)
          .height(CommonConstants.FULL_HEIGHT)
          .padding({
            left: 16,
            right: 16,
            bottom: 70
          })
        }
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)



        Row() {
          Column() {
            Row() {
              Text($r('app.string.renminbi'))
                .fontSize(12)
                .fontColor($r('app.color.lightRed'))
                .offset({
                  y: 4,
                });
              Text(`${this.totalCount}`)
                .fontSize(20)
                .fontColor($r('app.color.lightRed'))
                .lineHeight(28);
            };

            Row() {
              Text($r('app.string.totalDiscount'))
                .fontSize(10)
                .fontColor('rgba(0,0,0,0.4)');
              Text(this.couponVM.willUserCoupon === null?'0': String(this.couponVM.willUserCoupon.couponNumber))
                .fontSize(10)
                .fontColor($r('app.color.lightRed'))
            };
          }
          .margin({
            left: 12,
          })
          .alignItems(HorizontalAlign.Start);

          Blank();

          Button($r('app.string.orderSubmit'))
            .backgroundColor($r('app.color.lightRed'))
            .onClick(() => {
              this.contactVM.clearSelectContact();
              this.orderVM.submitOrder(this.locationVM.selectShopData, this.productVM.selectProduct,
                this.couponVM.willUserCoupon, this.vehicleVM.vehicle, this.contactVM.getCurrentContact());
              this.productVM.clearSelectProduct();
              this.appPathStack.replacePathByName('orderCard', true);
            });
        }
        .width(CommonConstants.FULL_WIDTH)
        .backgroundColor(Color.White)
        .padding({
          top: 10,
          bottom: 10,
          left: 16,
          right: 16,
        })
        .shadow({
          radius: 10,
          color: $r('app.color.middleGrey'),
          offsetY: -1,
        });
      };
    }
    .title('确认订单')
    .backgroundColor($r('app.color.littleGrey'))
    .margin({
      top: px2vp(this.topRectHeight),
    });
  }
}