import { Constants, NavHeaderBar } from 'common';
import { OrderListComp } from '../components/OrderListComp';

@Builder
export function OrderListPageBuilder() {
  OrderListPage()
}

@ComponentV2
struct OrderListPage {
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: $r('app.string.order_list'), hasBackButton: false })
        OrderListComp().layoutWeight(1)
      }
      .height(Constants.FULL_SIZE)
      .width(Constants.FULL_SIZE)
      .backgroundColor('#F1F3F5F2')
    }.hideTitleBar(true)
  }
}
