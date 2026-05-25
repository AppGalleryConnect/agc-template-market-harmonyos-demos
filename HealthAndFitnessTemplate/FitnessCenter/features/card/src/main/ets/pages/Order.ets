import {
  MockService,
  OrderState,
} from 'external_interactions';
import { JSON } from '@kit.ArkTS';
import { OrderContent } from '../components/OrderContent'
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
@ComponentV2
export struct Order {
  stateList: OrderState[] =
    [OrderState.ALL, OrderState.COMPLETED, OrderState.TO_BE_PAY]
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  @Local currentTabIndex: number = 0;

  @Builder
  tabBarBuilder(orderState: OrderState, index: number) {
    Text(MockService.getOrderStateString(orderState))
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
      TitleBar({ title: '我的订单',
        onBackClick: ()=>{
          this.pathStack.pop()
        }
      })
        .margin({ left: 16, right: 16 })
      Tabs() {
        ForEach(this.stateList, (item: OrderState, index: number) => {
          TabContent() {
            OrderContent({
              orderState: item,
              pathStack: this.pathStack,
              currentTabIndex: this.currentTabIndex,
              index: index
            })
          }
          .tabBar(this.tabBarBuilder(item, index))
        }, (item: OrderState) => JSON.stringify(item))
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

