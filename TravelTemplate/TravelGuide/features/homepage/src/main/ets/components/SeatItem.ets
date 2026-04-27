/**
 * 通用座位项组件
 * 用于统一 TicketSeatSelector 和 SeatTypeSelector 的座位项渲染
 */

/**
 * 座位项数据接口
 */
export interface SeatItemData {
  type: string
  price: number
  tickets?: number // 可选，用于显示票数
}

/**
 * 座位项配置
 */
export interface SeatItemConfig {
  item: SeatItemData
  index: number
  selectedIndex: number
  itemWidth: string
  showTickets?: boolean // 是否显示票数信息
  onItemClick: (index: number, item: SeatItemData) => void
}

@ComponentV2
export struct SeatItem {
  @Param @Require config: SeatItemConfig

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Text() {
          Span(this.config.item.type)
            .fontSize(14)
            .margin({ right: 2 })
          Span('8.7折')
            .fontSize(10)
            .opacity(0.7)
        }
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ bottom: 5 })

        Text() {
          this.renderPriceText()
        }
        .textAlign(TextAlign.Center)
        .width('100%')
      }
      .width(this.config.itemWidth)
      .height(51)
      .backgroundColor(this.config.selectedIndex === this.config.index ? '#FFFBE4' : '#fff')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderWidth(1)
      .borderColor(this.config.selectedIndex === this.config.index ? '#FEE231' : '#0F000000')
      .onClick(() => {
        this.config.onItemClick(this.config.index, this.config.item)
      })

      Image($r('app.media.ic_order_checked'))
        .width(14)
        .height(14)
        .visibility(this.config.selectedIndex === this.config.index ? Visibility.Visible : Visibility.None)
    }
  }

  @Builder
  renderPriceText() {
    if (this.config.showTickets && this.config.item.tickets !== undefined) {
      Span(this.config.item.price.toString())
        .fontSize(10)
      Span(this.config.item.tickets > 10 ? '/有票' : '/' + String(this.config.item.tickets) + '张')
        .fontSize(10)
    } else {
      Span('¥' + this.config.item.price)
        .fontSize(10)
    }
  }
}
