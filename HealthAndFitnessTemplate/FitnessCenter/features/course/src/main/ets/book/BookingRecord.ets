import {
  BookState,
  MockService,
} from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { RecordContent } from '../components/RecordContent'
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
@ComponentV2
export struct BookingRecord {
  stateList: BookState[] =
    [BookState.ALL, BookState.TO_BE_USE, BookState.COMPLETED, BookState.EXPIRED, BookState.CANCELED]
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Local currentTabIndex: number = 0;

  @Builder
  tabBarBuilder(bookState: BookState, index: number) {
    Text(MockService.getBookStateString(bookState))
      .height('100%')
      .fontSize(14)
      .fontColor(this.currentTabIndex === index ? '#FF9019' : Color.Black)
      .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Regular)
      .border({
        width: { bottom: this.currentTabIndex === index ? 2 : 0 },
        color: '#FF9019'
      })
  }

  build() {
    NavDestination() {
      TitleBar({ title: '预约记录',  onBackClick:()=>{this.pathStack.pop()}})
        .margin({ left: 16, right: 16 })
      Tabs() {
        ForEach(this.stateList, (item: BookState, index: number) => {
          TabContent() {
            RecordContent({
              bookState: item,
              pathStack: this.pathStack,
              currentTabIndex: this.currentTabIndex,
              index: index
            })
          }
          .foregroundColor(this.currentTabIndex === index ? '#FF9019' : Color.Black)
          .tabBar(this.tabBarBuilder(item, index))
        }, (item: BookState) => JSON.stringify(item))
      }
      .barHeight(50)
      .barMode(BarMode.Fixed)
      .layoutWeight(1)
      .backgroundColor($r('app.color.main_background_color'))
      .onChange((index: number) => {
        this.currentTabIndex = index
      })
    }.hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
  }
}
