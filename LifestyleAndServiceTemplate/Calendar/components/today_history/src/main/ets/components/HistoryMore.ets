import { BaseNavTitle } from 'base_apis'
import dayjs from 'dayjs'
import { HistoryParams, TodayHistoryData } from '../model/Model'
import { ThemeVM } from '../viewModel/ThemeController'
import { HistoryDaysCard } from './HistoryDaysCard'
import { HistoryDetailsCard } from './HistoryDetailsCard'

@Builder
export function HistoryMoreBuilder() {
  HistoryMore()
}

@ComponentV2
export struct HistoryMore {
  @Local selectDate: Date = new Date()
  @Local todayHistoryList: TodayHistoryData[] = []
  @Local todayDayList: TodayHistoryData[] = []
  @Local pathStack: NavPathStack = new NavPathStack()
  @Local themeVM: ThemeVM = ThemeVM.instance;

  build() {
    NavDestination() {
      BaseNavTitle({
        title: '历史上的今天',
        titleColor: this.themeVM.titleColor,
        currentTheme: this.themeVM.selectColor,
        routerModule: this.pathStack,
      })

      Scroll() {
        Column() {
          Stack() {
            Image($r('app.media.title_bg'))
              .width('100%')
              .height(184)
              .borderRadius(18)
              .clip(true)
              .objectFit(ImageFit.Cover)
            Column({ space: 8 }) {
              Text('历史上的今天')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_on_primary'))
              Text(`-${dayjs(this.selectDate).format('YYYY-MM-DD')}-`)
                .fontSize(16)
                .fontColor($r('sys.color.font_on_primary'))
            }
          }.padding({ left: 16, right: 16 })


          Column() {
            HistoryDaysCard({
              todayDayList: this.todayDayList,
            })
          }
          .padding({ left: 16, right: 16, top: 32 })

          Column() {
            HistoryDetailsCard({
              todayHistoryList: this.todayHistoryList,
            })
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 32 })
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.pathStack = ctx.pathStack
      const params = this.pathStack.getParamByName('HistoryMore')[0] as HistoryParams
      this.todayHistoryList = params.todayHistoryList
      this.todayDayList = params.todayDayList
      this.selectDate = params.selectDate
    })
  }
}