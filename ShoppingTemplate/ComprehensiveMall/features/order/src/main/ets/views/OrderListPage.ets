import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, RouterMap, routerStack } from 'lib_foundation'
import { ContainerColumn, NavTitleBar } from 'lib_widget';
import { OrderItem } from 'lib_network';
import { ORDER_TAB_LIST } from '../common/Constants';
import { OrderType } from '../common/Types';
import { buildNoOrderCard } from '../components/NoOrderCard';
import { buildButtonList, buildOrderInfoCard } from '../components/OrderInfoCard';
import { OrderListPageVM } from '../viewmodels/OrderListPageVM';
import { OrderTabsMap } from '../common/Enums';

@Builder
export function buildOrderListPage() {
  OrderListPage()
}

@ComponentV2
export struct OrderListPage {
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  tabScroller: Scroller = new Scroller()
  vm: OrderListPageVM = new OrderListPageVM();

  build() {
    NavDestination() {
      NavTitleBar({
        title: '我的订单',
        showSearchIcon: true,
        onSearchClick: () => {
          routerStack.pushPath({ name: RouterMap.ORDER_SEARCH })
        },
      })
      this.buildSearchBar()
      this.buildOrderTab()
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady((context) => {
      const index = context.pathInfo.param as number | undefined
      this.vm.initOrderTab(index ?? 0)
    })
  }

  @Builder
  buildSearchBar() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontColor([$r('app.color.font_color_level2')])
          .margin({
            right: $r('app.float.space_s'),
          })
        Text('搜索订单')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
      }
      .width($r('app.string.size_percent_full'))
      .backgroundColor($r('app.color.background_color_button_grey'))
      .borderRadius($r('app.float.border_radius_capsule'))
      .padding($r('app.float.space_m'))
    }
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
      bottom: $r('app.float.space_m'),
      top: $r('app.float.space_m'),
    })
    .onClick(() => {
      routerStack.pushPath({ name: RouterMap.ORDER_SEARCH })
    })
  }

  @Builder
  buildOrderTab() {
    Column() {
      this.buildOrderTabBar()
      Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.vm.tabController }) {
        ForEach(ORDER_TAB_LIST, (tab: OrderType, index: number) => {
          TabContent() {
            Column() {
              if (this.vm.isLoading) {
                LoadingProgress().width(32)
              } else if (this.vm.currentIndex === index && !this.vm.isLoading) {
                if (index === OrderTabsMap.REVIEW) {
                  this.buildReviewOrderList()
                } else {
                  this.buildCommonOrderList(index)
                }
              }
            }
            .layoutWeight(1)
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .layoutWeight(1)
          .align(Alignment.Top)
          .width($r('app.string.size_percent_full'))
          .backgroundColor($r('app.color.background_color_grey'))
          .padding({
            left: $r('app.float.space_l'),
            right: $r('app.float.space_l'),
            top: $r('app.float.space_l'),
          })
        }, (_tab: OrderType, index: number) => index.toString())
      }
      .width($r('app.string.size_percent_full'))
      .layoutWeight(1)
      .vertical(false)
      .barHeight(0)
      .animationDuration(0)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .onChange((index) => {
        this.vm.changeTab(index)
      })
    }
    .width($r('app.string.size_percent_full'))
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildOrderTabBar() {
    List({
      space: 12,
      scroller: this.tabScroller,
    }) {
      ForEach(ORDER_TAB_LIST, (tab: OrderType, index: number) => {
        ListItem() {
          this.buildTabBarItem(tab.label, index)
        }
      }, (_tab: OrderType, index: number) => index.toString())
    }
    .width($r('app.string.size_percent_full'))
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
    .constraintSize({ minWidth: '100%' })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .height(40)
    .margin({ top: $r('app.float.space_s') })
  }

  @Builder
  buildCommonOrderList(tabIndex: number) {
    Refresh({ refreshing: this.vm.isRefreshing }) {
      Column() {
        if (!this.vm.orderList.length && !this.vm.isRefreshing) {
          buildNoOrderCard(tabIndex === 0)
        } else {
          List() {
            Repeat(this.vm.orderList)
              .each((ri: RepeatItem<OrderItem>) => {
                ListItem() {
                  ContainerColumn() {
                    buildOrderInfoCard(ri.item)
                    buildButtonList(ri.item.orderInfo, ControlSize.SMALL, (actionType) => {
                      this.vm.handleOrderItem(ri.item, actionType)
                    })
                  }
                }
              })
          }
          .lanes(this.curBreakpoint.value === BreakpointTypeEnum.LG ? 2 : 1, 12)
          .layoutWeight(1)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .onReachEnd(() => {
            this.vm.getOrderList()
          })
        }
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onRefreshing(() => {
      this.vm.refreshOrderList()
    })
  }


  @Builder
  buildReviewOrderList() {
    Column() {
      Row() {
        Text('待评价')
          .reviewTabStyle(this.vm.reviewTabIndex === 0)
          .onClick(() => {
            this.vm.switchReviewTab(0)
          })
        Text('已评价')
          .reviewTabStyle(this.vm.reviewTabIndex === 1)
          .onClick(() => {
            this.vm.switchReviewTab(1)
          })
      }
      .width($r('app.string.size_percent_full'))
      .margin({ bottom: $r('app.float.space_m') })
      .justifyContent(FlexAlign.End)

      this.buildCommonOrderList(OrderTabsMap.REVIEW)
    }
  }


  @Builder
  buildTabBarItem(name: string, index: number) {
    Button(name)
      .fontColor(this.vm.currentIndex === index ? $r('sys.color.font_on_primary') :
        $r('sys.color.font_primary'))
      .backgroundColor(this.vm.currentIndex === index ? $r('app.color.theme_color') :
        $r('app.color.background_color_button_grey'))
      .fontSize($r('sys.float.Body_M'))
      .height(36)
      .onClick(() => {
        this.vm.tabController.changeIndex(index)
        this.tabScroller.scrollToIndex(index, true, ScrollAlign.CENTER)
      })
  }
}

@Extend(Text)
function reviewTabStyle(isSelected: boolean) {
  .fontSize($r('app.float.font_size_14'))
  .fontWeight(FontWeight.Medium)
  .margin({ left: $r('app.float.space_m') })
  .fontColor(isSelected ? $r('app.color.theme_color') : $r('app.color.font_color_level1'))
}