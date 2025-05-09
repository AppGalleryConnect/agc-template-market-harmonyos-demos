import { CommonConstants } from 'commonlib'
import { CommonHeader } from 'componentlib'
import { CouponItem } from 'network'
import { CouponCard } from '../components/CouponCardComp'
import { TabComp } from '../components/TabComp'
import { MY_TAB_BAR } from '../constants'
import { ScenarioStatus } from '../types'
import { getCouponList, getScenarioStatus } from '../utils'

@ComponentV2
struct MyCouponsPage {
  @Local myCouponsAll: CouponItem[] = [];
  @Local refreshing: boolean[] = [];
  private tabBar: string[] = [];
  private currentIndex: number = 0;

  @Computed
  get contentData() {
    const data: Array<CouponItem[]> = [this.myCouponsAll, [], [], []];
    this.myCouponsAll.forEach(item => {
      const status = getScenarioStatus(item, 0);
      if (status === ScenarioStatus.EXPIRE) {
        data[3].push(item);
      } else if (status === ScenarioStatus.HAS_USED) {
        data[2].push(item);
      } else {
        data[1].push((item));
      }
    })
    return data;
  }

  aboutToAppear() {
    this.tabBar = MY_TAB_BAR;
    this.refreshing = Array.from<boolean>({ length: this.tabBar.length }).fill(false);
    getCouponList().then((res) => {
      this.myCouponsAll = res;
    })
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '我的优惠券' })
      TabComp({
        tabBar: this.tabBar,
        index: this.currentIndex,
        contentUi: (index: number) => {
          this.tabContentBuilder(index);
        },
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  tabContentBuilder(index: number) {
    Refresh({ refreshing: this.refreshing[index] }) {
      List({ space: 8 }) {
        ForEach(this.contentData[index], (item: CouponItem) => {
          ListItem() {
            CouponCard({ coupon: item })
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
    .padding({ top: 8, left: 12, right: 12 })
  }
}

@Builder
function myCouponsPageBuilder() {
  MyCouponsPage()
}
