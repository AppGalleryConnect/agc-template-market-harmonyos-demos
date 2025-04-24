/**
 * 日期选择横向列表
 */
@ComponentV2
export struct DateSelectView {
  @Param @Once dayOfWeekList: string[] = []
  @Param @Once dateList: string[] = []
  @Consumer() selectedDateIndex: number = 0

  build() {
    List({ space: 4 }) {
      ForEach(this.dayOfWeekList, (item: string, index: number) => {
        ListItem() {
          Column() {
            Text(this.dayOfWeekList[index])
              .fontSize(12)
              .fontColor(
                index === this.selectedDateIndex ?
                $r('sys.color.ohos_id_color_text_primary_activated') :
                $r('sys.color.ohos_id_color_text_primary')
              )
            Text(this.dateList[index])
              .fontSize(12)
              .fontColor(
                index === this.selectedDateIndex ?
                $r('sys.color.ohos_id_color_text_primary_activated') :
                $r('sys.color.ohos_id_color_text_primary')
              )
          }
          .backgroundColor(
            index === this.selectedDateIndex ?
            $r('sys.color.ohos_id_color_text_highlight_bg') :
            $r('sys.color.ohos_id_color_background')
          )
          .borderRadius(4)
          .padding({
            top: 5,
            bottom: 5,
            left: 8,
            right: 8
          })
        }
        .height(44)
        .onClick(() => {
          this.selectedDateIndex = index
        })
      }, (item: string) => item)
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(44)
  }
}