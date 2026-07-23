import { Constants, OrderTabBarType } from 'constant';
import { Order } from 'type';
import { AppStorageBank, Logger } from 'util';
import { OrderType, ORDER_TYPES } from '../model/OrderTabInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@ComponentV2
export struct OrderHeader {
  vm: OrderPageVM = OrderPageVM.instance;
  @Param@ Require order: Order;
  @Provider('count') count: number = 0;
  textTimerController: TextTimerController = new TextTimerController();
  @Local format: string = 'HH:mm:ss';

  getOrderRsr(): OrderType | undefined {
    let orderType = ORDER_TYPES.find((item) => item.status === this.order.orderStatus);
    return orderType;
  }

  modifyOrderSilent() {
    this.vm.orderList.map((item => {
      if (item.orderSn === this.order.orderSn) {
        this.order.orderStatus = OrderTabBarType.CANCEL;
        item.orderStatus = OrderTabBarType.CANCEL;
        AppStorageBank.updateOrder(this.vm.orderList);
      }
    }));
  }

  aboutToAppear(): void {
    let curStamp = new Date().getTime();
    let createStamp = new Date(this.order.createTime).getTime();
    this.count = createStamp + 10 * 60 * 1000 - curStamp;
    if (this.count < 0 && this.order.orderStatus === OrderTabBarType.TO_PAY) {
      this.modifyOrderSilent();
    }
  }

  build() {
    Column() {
      Text(this.getOrderRsr()?.text ?? '')
        .fontSize(24)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium);

      if (this.order.orderStatus === 1) {
        Row({ space: 4 }) {
          Text('订单将在 ')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(12);
          TextTimer({ isCountDown: true, count: this.count, controller: this.textTimerController })
            .format(this.format)
            .fontColor($r('app.color.keyword_type_font_color'))
            .fontSize(12)
            .onTimer((utc: number, elapsedTime: number) => {
              Logger.info('textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime);
              if ((elapsedTime + 1) * 1000 >= this.count) {
                this.modifyOrderSilent();
              }
            })
            .onAppear(() => {
              this.textTimerController.start();
            });
          Text(' 后取消，请尽快支付')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(12);
        }
        .margin({ top: 8 });
      }
    }
    .width(Constants.FULL_SCREEN)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_tertiary'));
  }
}
