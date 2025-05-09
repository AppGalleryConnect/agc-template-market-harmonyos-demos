import { TAB_LIST } from '../constants/Constants';
import { TabListItem } from '../types/Types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { emitter } from '@kit.BasicServicesKit';
import { WidgetCardVM } from '../viewmodels/WidgetCardVM';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  cardVm: WidgetCardVM = WidgetCardVM.instance;
  callBackFunc: () => void = async () => {
    await this.cardVm.getLatestOrder();
    await this.cardVm.updateFormInfo();
  };

  build() {
    Navigation(this.vm.navStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
          ForEach(TAB_LIST, (item: TabListItem, index: number) => {
            TabContent() {
              item.component.builder();
            }
            .tabBar(this.tabBarBuilder(item, index))
            .clip(index !== 0)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
          }, (item: TabListItem) => item.label);
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .scrollable(false)
        .height('100%')
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.vm.curIndex = index;
          // 刷新订单列表
          if (index === 1) {
            emitter.emit('refreshTable');
          }
        });
      }
      .backgroundColor(Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .mode(NavigationMode.Stack);
  }

  async aboutToAppear() {
    await this.vm.init();
  }

  async onPageShow(): Promise<void> {
    this.cardVm.subscribeFormId()
    await this.cardVm.getLatestOrder();
    await this.cardVm.updateFormInfo();
    emitter.on('refreshCard', this.callBackFunc);
  }

  aboutToDisappear(): void {
    emitter.off('refreshCard', this.callBackFunc);
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.font_color_green') :
        $r('sys.color.ohos_id_color_text_tertiary'))
        .fontSize($r('sys.float.ohos_id_text_size_caption'))
        .margin({ top: $r('app.string.margin_xs') });

    }.width('100%');
  }
}