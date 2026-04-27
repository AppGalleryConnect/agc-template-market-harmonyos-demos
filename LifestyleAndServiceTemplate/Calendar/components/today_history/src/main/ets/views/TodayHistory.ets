import { BaseCell, getDataFromJSON } from 'base_apis';
import { TodayHistoryCard } from '../components/TodayHistoryCard';
import { TodayHistoryData, TodayHistorySize } from '../model/Model';
import { ThemeVM } from '../viewModel/ThemeController';

@ComponentV2
export struct TodayHistory {
  @Param selectDate: Date = new Date()
  @Local todayHistoryList: TodayHistoryData[] = []
  @Param routerModule: NavPathStack = new NavPathStack()
  @Local themeVM: ThemeVM = ThemeVM.instance;
  /*
  * selectColor
  * */
  @Param selectColor: ResourceStr = '#c4272b';
  /*
    * titleColor
    * */
  @Param titleColor: ResourceStr = '#ffffff';

  @Monitor('selectColor titleColor')
  selectColorChange() {
    this.themeVM.setTheme(this.selectColor, this.titleColor)
  }

  aboutToAppear(): void {
    this.todayHistoryList =
      getDataFromJSON<TodayHistoryData>(this.getUIContext().getHostContext()!, 'Today_History_Data.json');
    this.themeVM.setTheme(this.selectColor, this.titleColor)
  }

  @Builder
  showMore() {
    Row({ space: 5 }) {
      Text('更多')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .onClick(() => {
          this.routerModule.pushPathByName('HistoryMore', this.todayHistoryList)
        })
      Image($r('app.media.chevron_right')).width(12).height(24)
    }
  }

  @Builder
  todayHistory() {
    TodayHistoryCard({
      todayHistoryList: this.todayHistoryList.reverse().slice(0, 4),
    })
      .margin({ top: 20 })
  }

  build() {
    BaseCell({
      cellTitle: '历史上的今天',
      rightTextBuilderParam: () => this.showMore(),
      customBuilderParam: () => this.todayHistory(),
    })
  }
}