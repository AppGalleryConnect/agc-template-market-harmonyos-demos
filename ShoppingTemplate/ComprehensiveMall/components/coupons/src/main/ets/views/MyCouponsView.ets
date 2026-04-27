import { MY_TAB_BAR } from '../commons/Constants';
import { ScenarioStatus } from '../commons/Enums';
import { CouponItem } from '../commons/Types';
import { CouponCard } from '../components/CouponCard';
import { CouponCommonLoading } from '../components/CouponCommonLoading';
import { buildCouponEmptyStatus } from '../components/CouponEmptyStatus';
import { getScenarioStatus } from '../utils/CouponCalculator';
import { CouponsController } from '../viewmodels/CouponsController';

/** 我的优惠券页本地断点类型 */
enum CouponBreakpointType {
  SM = 'sm',
  MD = 'md',
  LG = 'lg'
}

@ComponentV2
export struct MyCouponsView {
  @Require @Param controller: CouponsController;
  @Local currentIndex: number = 0;
  @Local currentBreakpoint: CouponBreakpointType = CouponBreakpointType.SM;
  private _tabsController: TabsController = new TabsController();

  @Computed
  get contentData() {
    const data: CouponItem[][] = [[], [], []];
    this.controller.couponList.forEach(item => {
      const status = getScenarioStatus(item, 0);
      if (status === ScenarioStatus.EXPIRE) {
        data[2].push(item);
      } else if (status === ScenarioStatus.HAS_USED) {
        data[1].push(item);
      } else {
        data[0].push(item);
      }
    });
    return data;
  }

  /** 返回当前断点下的瀑布流列模板 */
  @Computed
  get waterFlowColumnsTemplate(): string {
    if (this.currentBreakpoint === CouponBreakpointType.SM) {
      return '1fr';
    }
    if (this.currentBreakpoint === CouponBreakpointType.MD) {
      return '1fr 1fr';
    }
    return '1fr 1fr 1fr';
  }

  async aboutToAppear() {
    await this.controller.loadCoupons();
  }

  build() {
    Column() {
      GridRow({ breakpoints: { value: ['320vp', '600vp', '840vp'] } }) {
      }
      .width('100%')
      .height(0)
      .onBreakpointChange((breakpoints: string) => {
        this.updateBreakpoint(breakpoints);
      })

      Row() {
        ForEach(MY_TAB_BAR, (tab: string, index: number) => {
          this.tabBarItemBuilder(tab, index)
        }, (item: string, index: number) => index + item)
      }
      .padding($r('app.float.padding_16'))

      if (this.controller.isLoading) {
        CouponCommonLoading()
      } else {
        Tabs({ index: this.currentIndex, controller: this._tabsController }) {
          ForEach(MY_TAB_BAR, (label: string, i: number) => {
            TabContent() {
              this.tabContentBuilder(i)
            }
            .expandSafeArea()
          }, (label: string, i: number) => label + '_' + i)
        }
        .layoutWeight(1)
        .expandSafeArea()
        .barHeight(0)
        .animationDuration(300)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color_grey'))
    .expandSafeArea()
  }

  private updateBreakpoint(breakpoints: string): void {
    if (breakpoints === 'xs' || breakpoints === CouponBreakpointType.SM) {
      this.currentBreakpoint = CouponBreakpointType.SM;
      return;
    }
    if (breakpoints === CouponBreakpointType.MD) {
      this.currentBreakpoint = CouponBreakpointType.MD;
      return;
    }
    this.currentBreakpoint = CouponBreakpointType.LG;
  }

  @Builder
  tabBarItemBuilder(label: string, index: number) {
    Button(label)
      .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.currentIndex === index ? $r('sys.color.font_on_primary') :
        $r('sys.color.font_tertiary'))
      .backgroundColor(this.currentIndex === index ? this.controller.themeColor :
        $r('app.color.background_color_button_grey'))
      .height(36)
      .margin({ right: 12 })
      .onClick(() => {
        this.currentIndex = index;
      })
  }

  @Builder
  couponActionBuilder(item: CouponItem, status: ScenarioStatus) {
    if (!(status === ScenarioStatus.HAS_USED || status === ScenarioStatus.EXPIRE)) {
      Button($r('app.string.use_now'))
        .backgroundColor(this.controller.themeColor)
        .controlSize(ControlSize.SMALL)
        .onClick(() => {
          this.controller.useNow(item.couponID);
        })
    }
  }

  @Builder
  tabContentBuilder(index: number) {
    if (this.contentData[index].length === 0) {
      buildCouponEmptyStatus(this.emptyMessageForTab(index))
    } else {
      WaterFlow() {
        ForEach(this.contentData[index], (item: CouponItem) => {
          FlowItem() {
            CouponCard({
              coupon: item,
              totalMoney: 0,
              isAvailable: index === 0,
              themeColor: this.controller.themeColor,
              actionSlot: (status: ScenarioStatus) => {
                this.couponActionBuilder(item, status);
              },
            })
          }
          .width('100%')
        }, (item: CouponItem, i: number) => JSON.stringify(item) + '_' + i)
      }
      .width('100%')
      .height('100%')
      .columnsTemplate(this.waterFlowColumnsTemplate)
      .columnsGap($r('app.float.margin_12'))
      .rowsGap($r('app.float.margin_12'))
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .padding({ left: $r('app.float.padding_16'), right: $r('app.float.padding_16') })
      .expandSafeArea()
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
  }

  private emptyMessageForTab(tabIndex: number): ResourceStr {
    if (tabIndex === 1) {
      return $r('app.string.coupon_empty_used');
    }
    if (tabIndex === 2) {
      return $r('app.string.coupon_empty_expired');
    }
    return $r('app.string.coupon_empty_pending');
  }
}
