import { TabListItem } from '../types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { HomePage } from 'business_home';
import { OrderPage } from 'business_order';
import { MinePage } from 'business_mine';
import { ControllerModule, Logger } from 'module_base';
import { WidgetCardVM } from '../viewmodels/WidgetCardVM';
import { emitter } from '@kit.BasicServicesKit';


@Builder
export function MainEntryBuilder() {
  MainEntry()
}

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

  aboutToAppear() {
    this.vm.init();
    ControllerModule.set(this.controller)
  }

  aboutToDisappear(): void {
    try {
      emitter.off('refreshCard', this.callBackFunc);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex, controller: this.controller }) {
          TabContent() {
            HomePage()
          }
          .expandSafeArea([SafeAreaType.SYSTEM])
          .tabBar(this.tabBarBuilder(0, {
            label: '寄快递',
            icon: $r('app.media.ic_home'),
            iconChecked: $r('app.media.ic_home_selected'),
          }))

          TabContent() {
            OrderPage()
          }
          .expandSafeArea([SafeAreaType.SYSTEM])
          .tabBar(this.tabBarBuilder(1, {
            label: '查快递',
            icon: $r('app.media.ic_express'),
            iconChecked: $r('app.media.ic_express_selected'),
          }))

          TabContent() {
            MinePage()
          }
          .expandSafeArea([SafeAreaType.SYSTEM])
          .tabBar(this.tabBarBuilder(2, {
            label: '我的',
            icon: $r('app.media.ic_mine'),
            iconChecked: $r('app.media.ic_mine_selected'),
          }))
        }
        .scrollable(false)
        .height('100%')
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.vm.curIndex = index;
          let info: emitter.EventData = {
            data: {
              index: index,
            },
          };
          try {
            emitter.emit('index', info);
          } catch (e) {
            Logger.error(JSON.stringify(e))
          }
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
      }
      .backgroundColor(Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onShown(async () => {
      this.cardVm.subscribeFormId()
      await this.cardVm.getLatestOrder();
      await this.cardVm.updateFormInfo();
      try {
        emitter.on('refreshCard', this.callBackFunc);
      } catch (e) {
        Logger.error(JSON.stringify(e))
      }
    })
  }

  @Builder
  tabBarBuilder(index: number, item: TabListItem) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? '#0A59F7' :
          $r('sys.color.icon_secondary'))
        .fontSize(10)
        .margin({ top: 4 });

    }.width('100%');
  }
}