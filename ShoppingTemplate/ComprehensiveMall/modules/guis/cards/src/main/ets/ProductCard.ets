import { ComponentEntryProxy } from '@common/customtypes';
import { ProductCardLogic } from './logic/ProductCardLogic';

@Builder
export function buildProductCard(logic: ProductCardLogic) {
  if (logic.isVertical) {
    Column() {
      ForEach(logic.viewData, (v: ComponentEntryProxy) => {
        v.wrappedBuilder.builder(...v.args)
      })
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .onClick(logic.onClick)
  } else {
    Row() {
      Column() {
        logic.viewData[0].wrappedBuilder.builder(...logic.viewData[0].args)
      }
      .width(85)
      .height(85)
      Column() {
        ForEach(logic.viewData, (v: ComponentEntryProxy, index: number) => {
          if (index > 0) {
            v.wrappedBuilder.builder(...v.args)
          }
        })
      }
      .layoutWeight(1)
      .borderWidth({ bottom: 0.7 })
      .borderColor('#1A000000')
      .constraintSize({ minHeight: 90 })
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
    .onClick(logic.onClick)
  }
}
