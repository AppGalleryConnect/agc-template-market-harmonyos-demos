import { BaseCell, getDataFromJSON } from 'base_apis';
import { TodayHistoryCard } from '../components/TodayHistoryCard';
import { HistoryParams, TodayHistoryData } from '../model/Model';
import { ThemeVM } from '../viewModel/ThemeController';

@ComponentV2
export struct TodayHistory {
  @Param selectDate: Date = new Date()
  @Local todayHistoryList: TodayHistoryData[] = []
  @Local todayDaysList: TodayHistoryData[] = []
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

  @Monitor('selectDate')
  historyListChange() {
    this.todayHistoryList = this.getRawfileJson('Today_History_Data.json');
    this.todayDaysList = this.getRawfileJson('Today_Day_Data.json');
  }

  getRawfileJson(json: string) {
    const allHistory =
      getDataFromJSON<TodayHistoryData>(this.getUIContext().getHostContext()!, json);
    const month = this.selectDate.getMonth() + 1;
    const day = this.selectDate.getDate();
    const targetDay = `${month}/${day}`;
    return allHistory.filter(item => item.day === targetDay);
  }

  goToHistoryMore() {
    let params: HistoryParams = {
      todayHistoryList: this.todayHistoryList,
      selectDate: this.selectDate,
      todayDayList: this.todayDaysList,
    }
    this.routerModule.pushPathByName('HistoryMore', params)
  }

  aboutToAppear(): void {
    this.historyListChange();
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
          this.goToHistoryMore()
        })
      Image($r('app.media.chevron_right')).width(12).height(24)
    }
  }

  @Builder
  todayHistory() {
    TodayHistoryCard({
      todayHistoryList: this.todayHistoryList,
      onCellEvent: () => {
        this.goToHistoryMore()
      },
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