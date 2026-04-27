import { SeatTypeItem } from '../common/model'
import { SeatItem, SeatItemData, SeatItemConfig } from './SeatItem'

/**
 * 座位类型选择器组件
 */
@ComponentV2
export struct SeatTypeSelector {
  @Param seatList: SeatTypeItem[] = []
  @Param selectedIndex: number = 0
  @Param onSeatSelected: ((index: number, item: SeatTypeItem) => void) | undefined = undefined
  @Param itemWidth: string = '28%' // 默认宽度，可自定义
  @Param showTickets: boolean = false // 是否显示票数信息

  build() {
    List({ space: 10 }) {
      ForEach(this.seatList, (item: SeatTypeItem, index: number) => {
        ListItem() {
          SeatItem({
            config: {
              item: {
                type: item.type,
                price: item.price,
                tickets: item.tickets
              } as SeatItemData,
              index: index,
              selectedIndex: this.selectedIndex,
              itemWidth: this.itemWidth,
              showTickets: this.showTickets,
              onItemClick: (idx: number, seatItem: SeatItemData) => {
                if (this.onSeatSelected) {
                  this.onSeatSelected(idx, item)
                }
              }
            }
          })
        }
      }, (item: SeatTypeItem) => item.type?.toString())
    }
    .height(88)
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }
}

/**
 * 座位类型选择器（横向布局，用于往返场景）
 */
@ComponentV2
export struct SeatTypeSelectorRow {
  @Param label: string = '' // 标签，如"去程"、"返程"
  @Param seatList: SeatTypeItem[] = []
  @Param selectedIndex: number = 0
  @Param onSeatSelected: ((index: number, item: SeatTypeItem) => void) | undefined = undefined

  build() {
    Row() {
      Text(this.label)
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
      List({ space: 10 }) {
        ForEach(this.seatList, (item: SeatTypeItem, index: number) => {
          ListItem() {
            SeatItem({
              config: {
                item: {
                  type: item.type,
                  price: item.price,
                  tickets: item.tickets
                } as SeatItemData,
                index: index,
                selectedIndex: this.selectedIndex,
                itemWidth: '26%',
                onItemClick: (idx: number, seatItem: SeatItemData) => {
                  if (this.onSeatSelected) {
                    this.onSeatSelected(idx, item)
                  }
                }
              }
            })
          }
        }, (item: SeatTypeItem) => item.type?.toString())
      }
      .height(58)
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Horizontal)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    }
  }
}
