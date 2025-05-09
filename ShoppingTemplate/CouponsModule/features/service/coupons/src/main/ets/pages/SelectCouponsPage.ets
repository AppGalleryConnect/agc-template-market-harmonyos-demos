import { CommonConstants, OnPopParams, RouterMap, RouterModule } from 'commonlib'
import { CommonHeader } from 'componentlib'
import { CouponItem } from 'network'
import { CouponCard } from '../components/CouponCardComp'
import { TabComp } from '../components/TabComp'
import { SELECT_TAB_BAR } from '../constants'
import { ScenarioStatus, SelectCouponParams } from '../types'
import { getCouponList, getReduceAmount, getScenarioStatus } from '../utils'

@ComponentV2
struct SelectCouponsPage {
  @Local selectCouponMoney: number = 0;
  @Local myCouponsAll: CouponItem[] = [];
  @Local refreshing: boolean[] = [];
  @Local currentIndex: number = 0;
  @Local selectId: string = '';
  private totalMoney: number = 0;
  private tabBar: string[] = [];

  @Computed
  get contentData() {
    const data: Array<CouponItem[]> = [[], []];
    this.myCouponsAll.forEach(item => {
      if (item.couponID === this.selectId) {
        this.selectCouponMoney = getReduceAmount(item, this.totalMoney);
      }
      const status = getScenarioStatus(item, this.totalMoney);
      switch (status) {
        case ScenarioStatus.NOW_USE:
          data[0].push(item);
          break;
        case ScenarioStatus.LESS_FULL:
        case ScenarioStatus.FUTURE_USE:
          data[1].push(item);
          break;
        default:
          break;
      }
    })
    // 减免多 => 减免少
    data[0].sort((a, b) => getReduceAmount(b, this.totalMoney) - getReduceAmount(a, this.totalMoney));
    // 满额不足 => 活动未开始
    data[1].sort((a, b) => getScenarioStatus(a, this.totalMoney) - getScenarioStatus(b, this.totalMoney));
    return data
  }

  aboutToAppear() {
    this.tabBar = SELECT_TAB_BAR;
    this.refreshing = Array.from<boolean>({ length: this.tabBar.length }).fill(false);
    this.getParams();
    getCouponList().then((res) => {
      this.myCouponsAll = res;
    })
  }

  getParams() {
    const params = RouterModule.getNavParam({ url: RouterMap.SELECT_COUPONS }) as SelectCouponParams | undefined;
    if (params) {
      this.totalMoney = params.totalMoney;
      this.selectId = params.selectId;
    }
  }

  backToOrder() {
    const onPopParams: OnPopParams = { selectId: this.selectId, reduce: this.selectCouponMoney };
    RouterModule.popWithRes(onPopParams);
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '选择优惠券' })
      TabComp({
        tabBar: this.tabBar,
        index: this.currentIndex!!, // 双向绑定
        contentUi: (index: number) => {
          this.tabContentBuilder(index)
        },
      })
      if (!this.currentIndex) {
        this.bottomBuilder()
      }
    }
    .hideTitleBar(true)
  }

  @Builder
  tabContentBuilder(index: number) {
    Refresh({ refreshing: this.refreshing[index] }) {
      List({ space: 8 }) {
        ForEach(this.contentData[index], (item: CouponItem) => {
          ListItem() {
            CouponCard({
              coupon: item,
              isOrder: true,
              selectId: this.selectId,
              totalMoney: this.totalMoney,
              clickCoupon: (coupon: CouponItem) => {
                if (this.selectId === coupon.couponID) {
                  this.selectId = '';
                  this.selectCouponMoney = 0;
                } else {
                  this.selectId = coupon.couponID;
                  this.selectCouponMoney = getReduceAmount(coupon, this.totalMoney);
                }
              },
            })
          }
        },(item:CouponItem,index)=>JSON.stringify(item)+'_'+index)
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .scrollBar(BarState.Off)
    }
    .onStateChange(status => {
      if (status === RefreshStatus.Refresh) {
        this.refreshing[index] = true;
      }
    })
    .onRefreshing(() => {
      getCouponList().then((res) => {
        this.myCouponsAll = res;
        this.refreshing[index] = false;
      })
    })
    .align(Alignment.Top)
    .padding({
      top: 8,
      left: 12,
      right: 12,
      bottom: 4,
    })
  }

  @Builder
  bottomBuilder() {
    Row() {
      Text($r('app.string.selected_coupon', `${this.selectId ? 1 : 0}`))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_M'))
        .lineHeight($r('app.string.line_height_14'))

      Row() {
        Text($r('app.string.currency_symbol'))
          .fontColor($r('sys.color.multi_color_09'))
          .fontSize($r('app.string.font_size_8'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.string.line_height_12'))
          .margin({ bottom: 1 })
        Text(this.selectCouponMoney.toFixed(2))
          .fontColor($r('app.color.sys_brand_fuchsia'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.string.line_height_18'))
      }
      .margin({ left: $r('app.string.margin_6') })
      .alignItems(VerticalAlign.Bottom)

      Button($r('app.string.confirm'))
        .fontColor($r('sys.color.comp_background_list_card'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Bold)
        .height(32)
        .backgroundColor($r('app.color.sys_brand_fuchsia'))
        .padding({
          top: 8,
          left: 32,
          right: 32,
          bottom: 8,
        })
        .margin({ left: $r('app.string.margin_12') })
        .onClick(() => {
          this.backToOrder();
        })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(56)
    .padding({ top: 12, right: 14 })
    .justifyContent(FlexAlign.End)
    .transition(TransitionEffect.translate({ y: '100%' }).animation({ duration: 100, curve: Curve.Smooth }))
  }
}

@Builder
function selectCouponsPageBuilder() {
  SelectCouponsPage()
}
