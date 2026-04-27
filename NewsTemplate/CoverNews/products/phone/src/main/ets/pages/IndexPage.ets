import { CommonConstants } from 'lib_common';
import { HomePage } from 'business_home';
import { MinePage } from 'business_mine';
import { IndexPageVM } from '../viewmodels/IndexPageVM';
import { TabItemModel } from '../models/TabModel';
import { TAB_LIST } from '../common/Constants';

@Builder
export function IndexPageBuilder() {
  IndexPage()
}

@ComponentV2
struct IndexPage {
  private vm: IndexPageVM = new IndexPageVM();

  aboutToAppear(): void {
    this.vm.setUIContext(this.getUIContext())
    this.vm.onJumpNewsDetail();
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ index: $$this.vm.selectedIndex, controller: this.vm.tabController }) {
          TabContent() {
            HomePage()
          }
          .tabBar(this.tabBuilder(TAB_LIST[0]))

          TabContent() {
            MinePage()
          }
          .tabBar(this.tabBuilder(TAB_LIST[1]))
        }
        .barWidth(this.vm.tabWidth)
        .barHeight(this.vm.tabHeight)
        .animation({ duration: 200, curve: Curve.EaseInOut })
        .vertical(this.vm.breakPointModel.isTabVertical)
        .divider(this.vm.showDivider)
        .backgroundColor($r('sys.color.background_secondary'))
        .barPosition(this.vm.barPosition)
        .scrollable(false)
        .onTabBarClick((index: number) => {
          this.vm.selectedIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onWillShow(() => {
      this.vm.setWindowFullScreen(this.vm.breakPointModel.isTabVertical);
    })
    .onWillHide(() => {
      this.vm.setWindowFullScreen(false);
    })
  }

  @Builder
  tabBuilder(item: TabItemModel) {
    Column({ space: 4 }) {
      Image(this.vm.selectedIndex === item.id ? item.iconSelected : item.icon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(item.label)
        .fontColor(this.vm.selectedIndex === item.id ? $r('app.color.common_theme_color') :
          $r('app.color.home_tab_unselected'))
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width(CommonConstants.FULL_PERCENT)
  }
}