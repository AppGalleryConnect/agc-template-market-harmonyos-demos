@Builder
export function ProhibitedItemsPageBuilder() {
  ProhibitedItemsPage()
}

@Component
export struct ProhibitedItemsPage {
  scroller: Scroller = new Scroller()
  build() {
    NavDestination() {
      Scroll(this.scroller) {
      Column() {
        Column(){
          Image($r('app.media.h_prohibit'))
            .width('100%')
          Column() {
            Text($r('app.string.prohibit_rule_title'))
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ top: 4, bottom: 4 })
            Text($r('app.string.prohibit_rule_content'))
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ bottom: 16 })
            Text($r('app.string.prohibit_nanjing_list_title'))
              .fontSize(12)
              .width('100%')
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 4 })
            Text($r('app.string.prohibit_jiangsu_list_content'))
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ bottom: 16 })
            Text($r('app.string.prohibit_jiangsu_list_title'))
              .fontSize(12)
              .width('100%')
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 4 })
            Text($r('app.string.prohibit_nanjing_list_content'))
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ bottom: 16 })
          }
          .padding({left:12,right:12,bottom:12})
          .backgroundColor($r('sys.color.white'))
        }
        .borderRadius(16)
        .backgroundColor($r('sys.color.white'))

      }
      // .height('100%')
      .width('100%')
      .backgroundColor('#F1F3F5')
      .padding({left:12,right:12,bottom:12})
      }
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
      .scrollBar(BarState.Auto) // 滚动条常驻显示
      .scrollBarColor(Color.Gray) // 滚动条颜色
      .scrollBarWidth(0) // 滚动条宽度
      .friction(0.6)
      .edgeEffect(EdgeEffect.None)
      .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
        console.info(xOffset + ' ' + yOffset)
      })
      .onScrollEdge((side: Edge) => {
        console.info('To the edge')
      })
      .onScrollStop(() => {
        console.info('Scroll Stop')
      })
    }
    .title('禁携物品')
  }
}