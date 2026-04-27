import { TodayHistoryData } from '../model/Model'

@ComponentV2
export struct TodayHistoryCard {
  @Param @Require todayHistoryList:TodayHistoryData[]
  @Local todayHistorySizeMap: Map<number, number> = new Map()

  aboutToAppear(): void {
    this.todayHistoryList.forEach((item, index) => {
      if (!this.todayHistorySizeMap.has(index)) {
        this.todayHistorySizeMap.set(index, 0)
      }
    })
  }

  build() {
    List({ space: 5 }) {
      Repeat(this.todayHistoryList)
        .key((item) => item.eId)
        .virtualScroll({ totalCount: this.todayHistoryList.length })
        .each((item: RepeatItem<TodayHistoryData>) => {
          ListItem() {
            Flex({ alignItems: ItemAlign.Center }) {
              Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                Row()
                  .width(8)
                  .height(8)
                  .backgroundColor('#CBCBCB')
                  .borderRadius('50%')
                  .margin({ top: 3 })
                Row()
                  .width(2)
                  .flexGrow(1)
                  .margin({ top: 5 })
                  .backgroundColor('#CBCBCB')
                  .visibility(item.index === this.todayHistoryList.length - 1 ? Visibility.None : Visibility.Visible)
              }
              .height(this.todayHistorySizeMap.get(item.index))
              .margin({ right: 12 })

              Column({ space: 8 }) {
                Text(item.item.date).fontSize(14).fontColor($r('sys.color.font_secondary'))
                Column() {
                  Text(item.item.title)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
                .padding({
                  top: 18,
                  bottom: 18,
                  left: 12,
                  right: 12,
                })
                .borderRadius(16)
                .backgroundColor($r('sys.color.background_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
              .padding({ bottom: 14 })
            }
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.todayHistorySizeMap.set(item.index, Number(newValue.height))
            })
          }
        })
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }
}