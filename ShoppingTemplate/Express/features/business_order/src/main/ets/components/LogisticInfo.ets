import { OrderInfoPageVM } from '../viewModels/OrderInfoPageVM'
import { CommonTimeLine } from './CommonTimeLine'


@ComponentV2
export struct LogisticInfo {
  vm: OrderInfoPageVM = OrderInfoPageVM.instance
  @Param minHeight: number = 54

  build() {
    Column() {
      Text('物流详情')
        .fontColor(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 12 })
      Column() {
        CommonTimeLine({ nodeList: this.vm.nodeList })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .constraintSize({ minHeight: 400 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
    .padding({
      top: 12,
      bottom: 40,
      left: 12,
      right: 12
    })
  }
}