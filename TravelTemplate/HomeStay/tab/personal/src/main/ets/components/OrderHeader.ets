import { Constants, OrderTabBarType } from 'constant';
import { Order } from 'type';
import { Logger, updateOrder } from 'util';
import { OrderType, ORDER_TYPES } from '../model/OrderTabInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Component
export struct OrderHeader {
  vm: OrderPageVM = OrderPageVM.instance;
  @Link order: Order;
  @Provide('count') count: number = 0;
  textTimerController: TextTimerController = new TextTimerController();
  @State format: string = 'HH:mm:ss';

  getOrderRsr(): OrderType | undefined {
    let orderType = ORDER_TYPES.find((item) => item.status === this.order.orderStatus);
    return orderType;
  }

  modifyOrderSilent() {
    // 订单状态修改为已取消
    this.vm.orderList.map((item => {
      if (item.orderSn === this.order.orderSn) {
        this.order.orderStatus = OrderTabBarType.CANCEL;
        item.orderStatus = OrderTabBarType.CANCEL;
        //更新本地持久化数据
        updateOrder(this.vm.orderList);
      }
    }));
  }

  aboutToAppear(): void {
    let curStamp = new Date().getTime();
    let createStamp = new Date(this.order.createTime).getTime();
    this.count = createStamp + Constants.MAX_TO_PAY_TIME - curStamp;
    if (this.count < 0 && this.order.orderStatus === OrderTabBarType.TO_PAY) {
      this.modifyOrderSilent();
    }
  }

  build() {
    Row({ space: 8 }) {
      Image($r(`${this.getOrderRsr()?.icon}`)).size({ width: 24, height: 24 });
      Text(this.getOrderRsr()?.text).fontSize(14).fontWeight(600);
      if (this.order.orderStatus === 1) {
        Row() {
          Text('还有').opacity(0.4).fontSize(12);
          TextTimer({ isCountDown: true, count: this.count, controller: this.textTimerController })
            .format(this.format)
            .fontColor(Color.Black)
            .fontSize(12)
            .opacity(0.4)
            .onTimer((utc: number, elapsedTime: number) => {
              Logger.info('textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime);
              if ((elapsedTime + 1) * 1000 >= this.count) {
                // 再请求更新
                this.modifyOrderSilent();
              }
            })
            .onAppear(() => {
              this.textTimerController.start();
            });
          Text('关闭订单').opacity(0.4).fontSize(12);
        };
      }
    }
    .padding({ left: 16, top: 14, bottom: 14 })
    .justifyContent(FlexAlign.Start)
    .width(Constants.FULL_SCREEN)
    .backgroundColor('#F5F6FA')
    .margin({ bottom: 20 });
  }
}