import { TodayHistoryData } from '../model/Model'

@ComponentV2
export struct HistoryDaysCard {
  @Param @Require todayDayList: TodayHistoryData[]

  build() {
    Column() {
      Row({ space: 8 }) {
        Image($r('app.media.title_icon')).width(16).height(16)
        Text('节日').fontSize(18).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')

      Column({ space: 5 }) {
        ForEach(this.todayDayList, (item: TodayHistoryData) => {
          Column({ space: 16}) {
            Text(item.title).fontSize(16).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium)
            Text(item.description).fontSize(14).fontColor($r('sys.color.font_primary'))
          }
          .margin({ top: 16 })
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        })
      }
    }
    .visibility(this.todayDayList.length >= 1 ? Visibility.Visible : Visibility.None)
  }
}