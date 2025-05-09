import { BreakpointConstants, CommonConstants, NewsTypeModel, NewsViewModel, HomeConstants as Const } from 'commonlib';
import { BaseTitle } from 'componentlib';
import { HomePageVM } from '../viewModels/HomePageVM';
import { PullToRefreshNews } from './PullToRefreshNews';

@ComponentV2
export default struct TabBar {
  @Local tabBarArray: NewsTypeModel[] = new NewsViewModel().getDefaultTypeList();
  @Local currentIndex: number = CommonConstants.ZERO;
  vm: HomePageVM = HomePageVM.instance;

  @Builder
  TabBuilder(id: number, index: number) {
    Column() {
      Text(this.tabBarArray[id].name)
        .height(CommonConstants.FULL_PERCENT)
        .margin({left: 24, right: 22})
        .fontSize(`${16 + this.vm.changeFontSize}`)
        .fontWeight(this.currentIndex === index ?
        Const.TAB_BARS_SELECT_TEXT_FONT_WEIGHT : Const.TAB_BARS_UN_SELECT_TEXT_FONT_WEIGHT)
        .fontColor(this.currentIndex === index ? $r('app.color.fontColor_text3') : $r('app.color.news_time_fontColor'))
        .borderColor({bottom: '#DC6450'})
        .borderWidth({bottom: this.currentIndex === index ? 3 : 0})
        .padding({bottom: 8})
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HomeTitleBuilder() {
    Text('首页')
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.HomeTitleBuilder()
        },
      })
      Tabs({ barPosition: BarPosition.Start }) {
        ForEach(this.tabBarArray, (tabsItem: NewsTypeModel, index: number) => {
          TabContent() {
            PullToRefreshNews()
          }
          .backgroundColor('#F1F3F5')
          .padding({top: 8})
          .tabBar(this.TabBuilder(tabsItem.id, index))
        }, (item: NewsTypeModel) => JSON.stringify(item));
      }
      .margin({top: 12})
      .barHeight(Const.TAB_BARS_BAR_HEIGHT)
      .barMode(BarMode.Scrollable)
      .barWidth(Const.TAB_BARS_BAR_WIDTH)
      .vertical(false)
      .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
        this.currentIndex = targetIndex;
      })
    }
    .width('100%')
    .height('100%')
  }
}