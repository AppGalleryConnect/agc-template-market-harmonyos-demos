import { Home } from '@ohos_agcit/postpartum_care_center_home';
import { Mine } from '@ohos_agcit/postpartum_care_center_mine';
import { Stores } from '@ohos_agcit/postpartum_care_center_stores';
import { Activities } from '@ohos_agcit/postpartum_care_center_activities';
import { TAB_LIST } from '../contants/Constants';
import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { TabListItem } from '../model/TabListItem';
import { Logger } from '@ohos_agcit/postpartum_care_center_utils';

const TAG: string = '[MainEntry]';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    Navigation(this.vm.navStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
          TabContent() {
            Home();
          }
          .clip(false)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

          TabContent() {
            Stores();
          }
          .clip(false)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));

          TabContent() {
            Activities();
          }
          .clip(false)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .tabBar(this.tabBarBuilder(TAB_LIST[2], 2));

          TabContent() {
            Mine();
          }
          .clip(false)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .tabBar(this.tabBarBuilder(TAB_LIST[3], 3));
        }
        .clip(false)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .scrollable(false)
        .height('100%')
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .barHeight(56)
        .onChange((index: number) => {
          this.vm.curIndex = index;
        });
      }
      .clip(false)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    }
    .height('100%')
    .clip(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.60)')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.vm.curIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_xxs') });

    }.width('100%');
  }
}

