import { TodayHistoryData } from '../model/Model'

@ComponentV2
export struct HistoryDetailsCard {
  @Param @Require todayHistoryList: TodayHistoryData[]

  build() {
    Column() {
      Row({ space: 8 }) {
        Image($r('app.media.title_icon')).width(16).height(16)
        Text('大事件').fontSize(18).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')

      Column({ space: 5 }) {
        ForEach(this.todayHistoryList, (item: TodayHistoryData) => {
          Row({ space: 8 }) {
            Text(item.date).fontSize(14).fontColor($r('sys.color.font_primary'))
            Text(item.title).fontSize(14).fontColor($r('sys.color.font_primary'))
          }
          .margin({ top: 12 })
          .width('100%')
        })
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
    }
  }
}