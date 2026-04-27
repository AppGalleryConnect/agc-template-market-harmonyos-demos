import { BrandViewProps } from '../viewmodel/MainPageVM'

@ComponentV2
export struct BrandView {
  @Param @Require item: BrandViewProps
  // 需要内边距
  @Param paddingWidth: number = 0

  build() {
    Column() {
      Image(this.item.icon)
        .height(48)
        .width(48)
        .padding(this.paddingWidth)

      Text(this.item.name)
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 0.85)')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}