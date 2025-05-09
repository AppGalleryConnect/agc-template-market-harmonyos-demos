import { OrderBrowsingPageLogic } from '../logic/OrderBrowsingPageLogic';
import { Style } from '@common/const';
import { TitleBar } from '@components/titlebar';
import { router } from '@common/router';
import { buildProductGhostSearchBar } from '@guis/search';
import { TabSwiper } from '@components/tabswiper';

@ComponentV2
export struct OrderBrowsingPage {

  @Param
  public type: number = 0;

  private logic: OrderBrowsingPageLogic = new OrderBrowsingPageLogic();

  aboutToAppear(): void {
    this.logic.initialIndex = this.type;
    this.logic.initTabSwiper();
  }

  build(): void {
    NavDestination() {
      Column() {
        TitleBar({
          barPadding: { right: Style.MENU_BAR_MARGIN_RIGHT },
          barColor: Color.White
        }) {
          buildProductGhostSearchBar('搜索我的订单', () => router.pushPathByName('OrderSearchPage', null, false))
        }
        TabSwiper({
          viewData: this.logic.tabSwiperViewData,
          tabLayoutMode: 'SpaceAround',
          tabsContainerMinHeight: 36,
          trackEdgeEffectMode: EdgeEffect.None,
          barBackgroundColor: Color.White,
          barExpandSafeArea: false,
          swiperInitialIndex: this.logic.initialIndex,
          swiperBackgroundColor: '#FFF1F3F5',
          swiperExpandSafeArea: true,
          onChange: this.logic.onTabSwiperChange,
          swiperEffectMode: EdgeEffect.Spring,
          indicatorWidth: 23,
          indicatorHeight: 3.5,
          indicatorRadius: 0,
          indicatorColor: '#FFE64566'
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor('#FFF1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}

@Builder
export function buildOrderBrowsingPage(_: string, type: number) {
  OrderBrowsingPage({ type: type })
}
