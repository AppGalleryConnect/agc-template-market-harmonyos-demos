import { Home } from 'business_home';
import { Mine } from 'business_mine';
import { CommonConstants } from 'lib_foundation';
import { MainVM } from '../viewmodels/MainVM';

@Builder
export function mainBuilder() {
  Main()
}

@ComponentV2
struct Main {
  vm: MainVM = MainVM.instance;

  build() {
    NavDestination() {
      Tabs({ index: $$this.vm.curIndex }) {
        TabContent() {
          Home()
        }.tabBar(this.tabBarBuilder(0))

        TabContent() {
          Mine()
        }.tabBar(this.tabBarBuilder(1))
      }
      .clip(false)
      .barMode(BarMode.Fixed)
      .animationDuration(0)
      .barHeight(this.vm.tabBarHeight)
      .barWidth(this.vm.tabBarWidth)
      .vertical(this.vm.tabVertical)
      .scrollable(false)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .barPosition(this.vm.tabBarPosition)
      .barBackgroundColor($r('sys.color.comp_background_primary'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Builder
  tabBarBuilder(index: number) {
    Column({ space: 4 }) {
      if (this.vm.curIndex === index) {
        Image(this.vm.tabList[index].iconSelected)
          .height(20)
          .width(18)
          .objectFit(ImageFit.Contain)
      } else {
        Image(this.vm.tabList[index].icon)
          .fillColor($r('sys.color.icon_secondary'))
          .height(20)
          .width(18)
          .objectFit(ImageFit.Contain)
      }
      Text(this.vm.tabList[index].label)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor(this.vm.curIndex === index ? $r('app.color.common_theme_color') :
          $r('sys.color.font_secondary'))
    }
    .justifyContent(this.vm.isLargeWindow ? FlexAlign.Center : FlexAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
    .height(this.vm.tabItemHeight)
    .padding({ top: this.vm.tabItemTopPadding })
  }
}
