import { ProductVM } from '@ohos_agcit/car_beauty_care_product';
import { LocationVM } from '@ohos_agcit/car_beauty_care_shop';
import { Order, OrderVM } from '../model/OrderVM';
import { OrderCard } from './OrderCard';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';

@Builder
export function OrderCardListBuilder() {
  OrderCardList();
}

@ComponentV2
export struct OrderCardList {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private scroller: Scroller = new Scroller();
  topRectHeight: number = 0;

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  productVM: ProductVM = ProductVM.instance;
  locationVM: LocationVM = LocationVM.instance;
  orderVM: OrderVM = OrderVM.instance;

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        if (this.orderVM.orderList.length === 0) {
          Column() {
            Image($r('app.media.noappointment'))
              .width(120)
              .height(120)
              .margin({ bottom: 12 });

            Text($r('app.string.noorder'))
              .fontSize(16)
              .fontColor($r('app.color.lightDark'));
          }
          .margin({ top: 100 })
          .padding(15)
          .alignItems(HorizontalAlign.Center);
        } else {
          // 如果不为空，显示订单列表
          Row() {
            List({ space: 12 }) {
              ForEach(this.orderVM.orderList, (item: Order) => {
                ListItem() {
                  OrderCard({
                    orderCard: item,
                  });
                }
                .backgroundColor(Color.White)
                .borderRadius(16)
                .padding(10);
              });
            }
            .width(CommonConstants.FULL_WIDTH);
          }
          .padding({
            top: 12,
            bottom: 12,
            left: 16,
            right: 16,
          })
          .backgroundColor($r('app.color.lightGrey'))
          .alignItems(VerticalAlign.Top);
        }
      };
    }
    .title('我的订单')
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle: 135,
      colors: [['#D2E2F5', 0.0], ['#F1F3F5', 0.4]],
    });
  }
}

