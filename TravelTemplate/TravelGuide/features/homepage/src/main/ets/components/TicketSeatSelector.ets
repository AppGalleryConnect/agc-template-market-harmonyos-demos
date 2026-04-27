import { TicketSeatItem } from '../common/model'
import { SeatItem, SeatItemData } from './SeatItem'

/**
 * 机票座位选择器组件配置
 */
export interface TicketSeatSelectorConfig {
  label: string // 标签：去程/返程（可选）
  seatList: TicketSeatItem[]
  selectedIndex: number
  itemWidth: string // 每个座位项的宽度
  onSeatSelected: (index: number, item: TicketSeatItem) => void
  showLabel?: boolean // 是否显示标签
  marginTop?: number // 上边距
  marginBottom?: number // 下边距
}

@ComponentV2
export struct TicketSeatSelector {
  @Param @Require config: TicketSeatSelectorConfig

  build() {
    if (this.config.showLabel) {
      // 带标签的布局（往返场景）
      Row() {
        this.renderLabel()
        this.renderSeatList(true)
      }
      .width('100%')
      .height(51)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: this.config.marginTop ?? 10,
        bottom: this.config.marginBottom ?? 0
      })
    } else {
      // 不带标签的布局（单程场景）
      this.renderSeatList(false)
    }
  }

  @Builder
  renderLabel() {
    Text(this.config.label)
      .fontSize(10)
      .width(22)
      .padding({
        top: 14,
        bottom: 14,
        left: 6,
        right: 6
      })
      .borderRadius(6)
      .margin({ right: 10 })
      .backgroundColor('#F1F3F5')
  }

  @Builder
  renderSeatList(showLabel: boolean) {
    List() {
      ForEach(this.config.seatList, (item: TicketSeatItem, index: number) => {
        ListItem() {
          Row() {
            this.renderSeatItem(item, index)
          }
          .width(showLabel ? undefined : '50%')
          .padding({ right: index === 0 ? 5 : 0, left: index === 1 ? 5 : 0 })
        }
      }, (item: TicketSeatItem) => item.type?.toString())
    }
    .layoutWeight(showLabel ? 1 : undefined)
    .height(showLabel ? undefined : 51)
    .width(showLabel ? undefined : '100%')
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .margin(showLabel ? undefined : {
      top: this.config.marginTop ?? 16,
      bottom: this.config.marginBottom ?? 12
    })
  }

  @Builder
  renderSeatItem(item: TicketSeatItem, index: number) {
    SeatItem({
      config: {
        item: {
          type: item.type,
          price: item.price
        } as SeatItemData,
        index: index,
        selectedIndex: this.config.selectedIndex,
        itemWidth: this.config.itemWidth,
        onItemClick: (idx: number) => {
          this.config.onSeatSelected(idx, item)
        }
      }
    })
  }
}
