import { DevicesNotifyView, ShowType } from '../view/DevicesNotifyView';
import { DevicesNotifyViewModel } from '../viewmodel/DevicesNotifyViewModel';

@Builder
export function NotifyPageBuilder(name: string, param: Object) {
  DevicesNotifyPage();
}

@ComponentV2
export struct DevicesNotifyPage {
  pathStack: NavPathStack = new NavPathStack();
  @Local currentIndex: number = 0;
  devicesNotifyViewModel: DevicesNotifyViewModel = new DevicesNotifyViewModel();
  private contentTabController: TabsController = new TabsController();
  private tabArray: string[] =
    ['全部', '已读', '未读'];

  @Builder
  BuildTabBar() {
    Row({ space: 20 }) {
      ForEach(this.tabArray, (item: string, index: number) => {
        Column() {
          Text(item)
            .fontColor(this.currentIndex === index ? '#000000' : '#333333')
            .fontWeight((this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal))
            .fontSize(18)
            .onClick(() => {
              this.contentTabController.changeIndex(index);
              this.currentIndex = index;
            });

          Divider()
            .width(36)
            .strokeWidth(3)
            .color('#000000')
            .opacity(this.currentIndex === index ? 1 : 0)
            .margin({ top: 5 });
        };
      }, (item: string, index: number) => item);
    }
    .width('90%')
    .justifyContent(FlexAlign.Start)
    .margin({top: 18 });
  }

  @Builder
  BuildTabContent() {
    Tabs({ barPosition: BarPosition.Start, controller: this.contentTabController }) {
      TabContent() {
        DevicesNotifyView({ showType: ShowType.ALL, pathStack: this.pathStack });
      };

      TabContent() {
        DevicesNotifyView({ showType: ShowType.READ, pathStack: this.pathStack });
      };

      TabContent() {
        DevicesNotifyView({ showType: ShowType.UNREAD, pathStack: this.pathStack });
      };
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('90%')
    .barHeight(0)
    .margin({ top: 20 });
  }

  @Builder
  BuildDevicesNotify() {
    Column() {
      this.BuildTabBar();
      this.BuildTabContent();
    };
  }

  build() {
    NavDestination() {
      this.BuildDevicesNotify();
    }
    .title('通知')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor('#F1F3F5');
  }
}