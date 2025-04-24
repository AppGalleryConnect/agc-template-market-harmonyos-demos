import { WindowConfig } from 'commonlib';
import { TAB_LIST } from '../constants/Constants';
import { TabListItem } from '../types/Types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  @Provider('mainTabController') mainTabController: TabsController = new TabsController();
  @Provider('windowConfig') windowConfig: WindowConfig = AppStorageV2.connect(WindowConfig, 'windowConfig', () => new WindowConfig())!;

  build() {
    Navigation(this.vm.navStack) {
      RelativeContainer() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex, controller: this.mainTabController }) {
          ForEach(TAB_LIST, (item: TabListItem, index: number) => {
            TabContent() {
              item.component.builder();
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[index], index))
            .clip(index !== 0)
          }, (item: TabListItem) => item.label)
        }
        .scrollable(false)
        .height('100%')
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.vm.curIndex = index;
        })
        .id('main_tab_container')
      }
      .backgroundColor($r('sys.color.background_secondary'));
    }
    .padding({ bottom: this.windowConfig.windowBottomHeight })
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
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
        .fontColor(this.vm.curIndex === index ? $r('sys.color.multi_color_09') :
        $r('app.color.system_color_grey_60'))
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_s') });
    }
    .padding({ top: $r('app.string.padding_xs'), bottom: $r('app.string.padding_xs') })
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White);
  }
}