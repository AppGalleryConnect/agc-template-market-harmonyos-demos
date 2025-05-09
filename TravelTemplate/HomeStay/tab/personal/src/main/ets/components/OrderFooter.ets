import { Constants, OrderTabBarType } from 'constant';
import { Order } from 'type';
import { updateOrder } from 'util';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Component
export struct OrderFooter {
  vm: OrderPageVM = OrderPageVM.instance;
  @Prop order: Order;
  @Consume('orderTabIndex') orderTabIndex: number;
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
    Row() {
      Button('取消订单', { type: ButtonType.Normal })
        .width(150)
        .height(40)
        .fontColor(Color.Black)
        .backgroundColor(Color.White)
        .border({ width: 1, color: Color.Black, radius: $r('sys.float.corner_radius_level4') })
        .margin({ bottom: 16, right: 16 })
        .onClick(() => {
          // 订单状态修改为已取消
          this.vm.orderList.map((item => {
            if (item.orderSn === this.order.orderSn) {
              this.order.orderStatus = OrderTabBarType.CANCEL;
              item.orderStatus = OrderTabBarType.CANCEL;
            }
          }));
          // 更新到AppStorage
          updateOrder(this.vm.orderList);
          this.mainPathStack.pop(this.order);
        });

      Button('立即支付', { type: ButtonType.Normal })
        .width(150)
        .height(40)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('app.color.keyword_type_font_color'))
        .border({ width: 0, radius: $r('sys.float.corner_radius_level4') })
        .margin({ bottom: 16, left: 16 })
        .onClick(() => {
          // 订单状态修改为已完成
          let desIndex: number = this.order.orderType === 1 ? OrderTabBarType.READY : OrderTabBarType.TO_USE;
          this.vm.orderList.map((item => {
            if (item.orderSn === this.order.orderSn) {
              this.order.orderStatus = desIndex;
              item.orderStatus = desIndex;
            }
          }));
          // 更新到AppStorage
          updateOrder(this.vm.orderList);
          this.mainPathStack.pop(this.order);
        });
    }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Center);
  }
}