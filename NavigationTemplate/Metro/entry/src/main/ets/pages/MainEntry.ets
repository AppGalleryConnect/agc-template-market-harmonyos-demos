import { TAB_LIST } from '../constants/Constants';
import { HomeView } from 'home';
import { MineView } from 'mine';
import { TabListItem } from '../types/Types';
import { MainEntryVM } from 'commonlib';
import { QRView } from 'qrcode'
import { RouterModule } from 'commonlib';
import { TripView } from 'trip';
import { BACKGROUND_COLOR_GRAY } from 'home/src/main/ets/constants/HomeViewConstants';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  pageInfos: NavPathStack = RouterModule.getStack()

  build() {
    Navigation(this.vm.navStack) {
      Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
        TabContent() {
          HomeView();
        }
        .align(Alignment.Top)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

        TabContent() {
          TripView();
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));

        TabContent() {
          QRView();
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .tabBar(this.tabBarBuilder(TAB_LIST[2], 2));

        TabContent() {
          MineView();
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .tabBar(this.tabBarBuilder(TAB_LIST[3], 3));
      }
      .scrollable(false)
      .height('100%')
      .backgroundColor(Color.White)
      .animationDuration(0)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.vm.curIndex = index;
      });
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .backgroundColor(BACKGROUND_COLOR_GRAY)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .mode(NavigationMode.Stack);
  }

  async aboutToAppear() {
    await this.vm.init();
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.icon_color_highlight') :
        $r('app.color.icon_color_level2'))
        .fontSize($r('app.string.font_size_12'))
        .margin({ top: $r('app.string.margin_xs') });

    }.width('100%').padding({ bottom: 10 })
  }
}