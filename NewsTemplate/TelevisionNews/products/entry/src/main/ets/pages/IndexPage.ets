import { AppStorageV2 } from '@kit.ArkUI';
import { TelevisionPage } from 'home';
import { Constants, TabBarData, TABS_INFO, WindowModel } from 'lib_common';
import { MinePage } from 'mine';
import { CustomTabBar } from '../components/CustomTabBar';
import { IndexVM } from '../viewmodel/IndexVM';

const TAG = '[IndexPage]'

@Builder
export function IndexPageBuilder() {
  IndexPage()
}

@ComponentV2
struct IndexPage {
  @Provider('currentIndex') currentIndex: number = 0;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  tabController: TabsController = new TabsController();
  vm: IndexVM = new IndexVM(this.getUIContext());

  aboutToAppear(): void {
    this.vm.checkJumpNewsDetail()
  }

  @Monitor('formCardModel.id')
  onFormCardClick() {
    this.vm.checkJumpNewsDetail();
  }

  @Builder
  tabBuilder(item: TabBarData, index: number) {
    CustomTabBar({ item: item, index })
      .animation({ duration: 200, curve: Curve.EaseInOut })
  }

  build() {
    NavDestination() {
      Stack() {
        Flex({
          direction: FlexDirection.Column,
        }) {
          Tabs({ controller: this.tabController, index: this.currentIndex }) {
            TabContent() {
              TelevisionPage({ index: this.currentIndex })
            }.tabBar(this.tabBuilder(TABS_INFO[0], 0));

            TabContent() {
              MinePage()
            }.tabBar(this.tabBuilder(TABS_INFO[1], 1));
          }
          .barWidth(this.vm.tabWidth)
          .barHeight(this.vm.tabBarHeight)
          .animation({ duration: 200, curve: Curve.EaseInOut })
          .vertical(this.vm.isTabVertical)
          .barPosition(this.vm.barPosition)
          .scrollable(false)
          .barOverlap(!this.vm.isTabVertical)
          .barMode(this.vm.isTabVertical ? BarMode.Scrollable : BarMode.Fixed)
          .barBackgroundColor($r('sys.color.background_primary'))
          .barBackgroundBlurStyle(BlurStyle.NONE)
          .animationDuration(0)
          .onChange((index) => {
            this.currentIndex = index;
          })
        }
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE);
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ bottom: this.windowModel.getWindowBottomHeight() })
  }
}