import { Constant } from 'common';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@ComponentV2
export struct OrderEmpty {
  vm: OrderPageVM = OrderPageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      Image(this.vm.orderType === 0 ? $r('app.media.no_ticket') : $r('app.media.no_commodity'))
        .size({ height: 160, width: 160 })
        .margin({ top: 36 });
      Text(`还没有相关订单哟\n` +
        `快去购买心仪${this.vm.orderType === 0 ? '门票' : '物品'}吧～`)
        .fontSize(14)
        .margin({ top: 24, bottom: 24 })
        .opacity(0.4);
      Button(`${this.vm.orderType === 0 ? '去买票' : '去购物'}`)
        .width(200)
        .borderRadius(20)
        .backgroundColor('#64BB5C')
        .fontColor(Color.White)
        .fontWeight(500)
        .margin({ bottom: 60 })
        .onClick(() => {
          this.mainPathStack.pushPathByName(this.vm.orderType === 0 ? 'Tickets' : 'Mall', null, false);
        });
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center);
  }
}