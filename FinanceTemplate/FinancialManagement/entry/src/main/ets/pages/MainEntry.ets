import { TabListItem } from '../types';
import { MainEntryVM } from '../viewModels/MainEntryVM';
import { WidgetCardVM } from '../viewModels/WidgetCardVM';
import { emitter } from '@kit.BasicServicesKit';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  cardVm: WidgetCardVM = WidgetCardVM.instance;
  callBackFunc: () => void = async () => {
    await this.cardVm.getLatestOrder();
    await this.cardVm.updateFormInfo();
  };
  private controller: TabsController = new TabsController();

  async onPageShow(): Promise<void> {
    this.cardVm.subscribeFormId()
    await this.cardVm.getLatestOrder();
    await this.cardVm.updateFormInfo();
    emitter.on('refreshCard', this.callBackFunc);
  }

  build() {
    Navigation(this.vm.navStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex, controller: this.controller }) {
          ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
            TabContent() {
              item.component.builder();
            }
            .tabBar(this.tabBarBuilder(item, index))
            .clip(index !== 0)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          }, (item: TabListItem[]) => JSON.stringify(item))
        }
        .scrollable(false)
        .height('100%')
        .animationDuration(0)
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
    .mode(NavigationMode.Stack)
  }

  async aboutToAppear() {
    await this.vm.init();
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text(item.label)
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.curIndex === index ? '#E4480C' : $r('sys.color.font_secondary'))

    }.width('100%')
  }
}
;