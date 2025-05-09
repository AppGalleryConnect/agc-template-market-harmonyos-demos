import { TAB_LIST } from '../constants/Constants';
import { HomeView } from '../components/HomeView';
import { MineView } from '../components/MineView';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { CheckInActivityView } from '../components/CheckInActivityView';
import { CoursesView } from '../components/CoursesView';
import { TabsIndexMap } from 'commonlib';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    Navigation(this.vm.navStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex, controller: this.vm.tabController }) {
          TabContent() {
            HomeView();
          }
          .tabBar(this.tabBarBuilder(TabsIndexMap.HOME))
          .clip(false)

          TabContent() {
            CoursesView({
              courseType:this.vm.courseType,
            });
          }
          .tabBar(this.tabBarBuilder(TabsIndexMap.COURSES_LIST));

          TabContent() {
            CheckInActivityView();
          }
          .tabBar(this.tabBarBuilder(TabsIndexMap.CHECK_IN));

          TabContent() {
            MineView();
          }
          .clip(false)
          .tabBar(this.tabBarBuilder(TabsIndexMap.MINE));
        }
        .scrollable(false)
        .layoutWeight(1)
        .animationDuration(0)
        .divider({ strokeWidth: 1, color: $r('app.color.system_color_grey') })
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.vm.curIndex = index;
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      }
      .backgroundColor(Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack);
  }

  async aboutToAppear() {
    await this.vm.initData();
  }

  @Builder
  tabBarBuilder(index: number) {
    Column() {
      Image(this.vm.curIndex === index ? TAB_LIST[index].iconChecked : TAB_LIST[index].icon)
        .width(32)
        .height(32);
      Text(TAB_LIST[index].label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.system_theme_color') :
        $r('app.color.icon_color_level3'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_xs') });
    }
    .width('100%');
  }
}