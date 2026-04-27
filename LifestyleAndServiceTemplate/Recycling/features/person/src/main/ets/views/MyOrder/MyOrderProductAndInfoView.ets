import { OrderItem } from '../../viewmodel/MyOrderPageVM';
import { MyOrderInfoView } from './MyOrderInfoView';
import { MyOrderProductInfoView } from './MyOrderProductInfoView';

@ComponentV2
export struct MyOrderProductAndInfoView {
  // 是否支持拓展
  @Param isExpand: boolean = false;
  // 订单信息
  @Param @Require orderInfo: OrderItem

  build() {
    Column() {
      // 商品信息
      MyOrderProductInfoView({ order: this.orderInfo }).margin({ bottom: 12 })

      // 订单信息
      MyOrderInfoView({ order: this.orderInfo, isExpand: this.isExpand })
    }.width('100%')
  }
}