import { Home } from 'home';
import { Mine } from 'mine';
import { Logger, CommonConstants } from 'utils';

class TabItemModel {
  label: ResourceStr = '';
  icon: ResourceStr = '';
  iconSelected: ResourceStr = '';
}

@Builder
export function MainBuilder() {
  Main()
}

@Entry
@ComponentV2
struct Main {
  @Local selectedIndex: number = 0;

  aboutToAppear() {
    Logger.info('Main onCreate');
  }

  @Builder
  tabBuilder(index: number, item: TabItemModel) {
    Column({ space: 4 }) {
      Image(this.selectedIndex === index ? item.iconSelected : item.icon)
        .width(17)
        .height(17)
        .objectFit(ImageFit.Contain)
      Text(item.label)
        .fontColor(this.selectedIndex === index ? $r('app.color.common_theme_color') :
        $r('app.color.home_tab_unselected'))
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width(CommonConstants.FULL_PERCENT)
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ index: $$this.selectedIndex }) {
          TabContent() {
            Home()
          }
          .clip(false)
          .tabBar(this.tabBuilder(0, {
            label: $r('app.string.tab_home'),
            icon: $r('app.media.ic_home_home_grey'),
            iconSelected: $r('app.media.ic_home_home_highlight'),
          }))

          TabContent() {
            Mine()
          }
          .clip(false)
          .tabBar(this.tabBuilder(1, {
            label: $r('app.string.tab_mine'),
            icon: $r('app.media.ic_public_person'),
            iconSelected: $r('app.media.ic_public_person_highlight'),
          }))
        }
        .clip(false)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .scrollable(false)
        .barPosition(BarPosition.End)
        .onTabBarClick((index: number) => {
          this.selectedIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }.hideTitleBar(true)
  }
}