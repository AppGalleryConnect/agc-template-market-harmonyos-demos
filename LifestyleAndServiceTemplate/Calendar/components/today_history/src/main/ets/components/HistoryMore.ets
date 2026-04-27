import { BaseNavTitle } from 'base_apis'
import { TodayHistoryData } from '../model/Model'
import { ThemeVM } from '../viewModel/ThemeController'
import { TodayHistoryCard } from './TodayHistoryCard'

@Builder
export function HistoryMoreBuilder() {
  HistoryMore()
}

@ComponentV2
export struct HistoryMore {
  @Local todayHistoryList: TodayHistoryData[] = []
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
      Column() {
        TodayHistoryCard({
          todayHistoryList: this.todayHistoryList,
        })
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 16 })
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.pathStack = ctx.pathStack
      this.todayHistoryList = this.pathStack.getParamByName('HistoryMore')[0] as []
    })
  }
}