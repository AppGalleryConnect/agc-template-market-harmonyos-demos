import { TabIndexEnum } from '../model/Index';
import { CaloriesSummaryVM } from '../viewmodel/CaloriesSummaryVM';
import { CommonCharts } from './BarChart';
import { BaseTabs } from './BaseTabs';

@Preview
@ComponentV2
export struct CaloriesSummary {
  @Param todayCalories: number = 0
  @Param seriesData: number[] = [];
  @Local vm: CaloriesSummaryVM = new CaloriesSummaryVM()

  @Computed
  get newSeriesData() {
    let date = new Date().getDay() - 1
    return this.seriesData.map((item, index) => {
      if (date === index) {
        return this.todayCalories
      } else if (date < index) {
        return 0
      } else {
        return item
      }
    })
  }

  build() {
    Column() {
      BaseTabs({
        tabsTitle: ['日', '周'], currentIndex: this.vm.currentIndex, changeTabs: (index: number) => {
          this.vm.changeTabs(index)
        },
      }).margin({
        top: 12,
        bottom: 12,
      })

      Column() {
        Stack() {
          Progress({ value: this.todayCalories, total: 2000, type: ProgressType.Ring })
            .width(176).style({ strokeWidth: 20 })
            .color(this.vm.gradientColor)
          Column() {
            Text('维持塑形').fontSize(20).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
            Text('建议摄入').fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ top: 16 })
            Text('2000千卡').fontSize(12).fontColor('#64BB5C').margin({ top: 2 })
          }
        }.margin({ top: 30 })

        Row({ space: 84 }) {
          Column() {
            Row() {
              Image($r('app.media.ic_intake')).width(24)
              Text('今日摄入')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 4 })
            }

            Row() {
              Text(`${this.todayCalories}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Text('/').fontSize(10).fontColor($r('sys.color.font_primary')).margin({ left: 2 })
              Text('2000千卡').fontSize(10).fontColor($r('sys.color.font_secondary')).margin({ left: 2 })
            }.margin({ top: 4 })
          }

          Column() {
            Row() {
              Image($r('app.media.ic_resting_calories')).width(24)
              Text('静息热量')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 4 })
            }

            Text('1500千卡')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 4 })
          }
        }.margin({ top: 30 })
      }.visibility(this.vm.currentIndex === TabIndexEnum.FIRST ? Visibility.Visible : Visibility.None)

      CommonCharts({ xData: this.vm.xData, seriesData: this.newSeriesData })
        .visibility(this.vm.currentIndex === TabIndexEnum.SECOND ? Visibility.Visible : Visibility.None)
    }
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }
}
