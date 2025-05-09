import { TAB_LIST } from '../constants/Constants';
import { minePageBuilder } from 'mine';
import { homePageBuilder } from 'home';
import { videoViewBuilder } from 'video';
import { TabListItem } from '../types/Types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { Logger, PreferencesUtil } from 'commonlib';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  onPageShow() {
    PreferencesUtil.getChangeFontSize().then((value) => {
      this.vm.changeFontSize = value;
      Logger.info('changeFontSize', 'Get the value of changeFontSize: ' + this.vm.changeFontSize);
    });
  }

  async aboutToAppear() {
    await this.vm.init();
  }


  build() {
    Navigation(this.vm.navStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
          TabContent() {
            if(this.vm.curIndex === 0){
              homePageBuilder();
            }

          }
          .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

          TabContent() {
            if(this.vm.curIndex === 1){
               videoViewBuilder();
            }
          }
          .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));

          TabContent() {
            if(this.vm.curIndex === 2){
               minePageBuilder();
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .tabBar(this.tabBarBuilder(TAB_LIST[2], 2));
        }
        .scrollable(false)
        .height('100%')
        .barHeight(56)
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .onChange((index: number) => {
          this.vm.curIndex = index;
          PreferencesUtil.getChangeFontSize().then((value) => {
            this.vm.changeFontSize = value;
            Logger.info('changeFontSize', 'Get the value of changeFontSize: ' + this.vm.changeFontSize);
          });
        });
      }
      .backgroundColor(Color.White);
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack);

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

    }.width('100%');
  }
}