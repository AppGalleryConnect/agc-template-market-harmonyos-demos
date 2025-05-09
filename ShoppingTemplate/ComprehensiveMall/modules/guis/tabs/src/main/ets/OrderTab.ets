import { OrderTabLogic } from './logic/OrderTabLogic';

@ComponentV2
export struct OrderTab {

  @Param
  public logic: OrderTabLogic = new OrderTabLogic();

  build() {
    Column() {
      Text(this.logic.label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.logic.textColor)
    }
    //.width('20%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}

@Builder
export function buildOrderTab(logic: OrderTabLogic) {
  OrderTab({ logic: logic })
}
