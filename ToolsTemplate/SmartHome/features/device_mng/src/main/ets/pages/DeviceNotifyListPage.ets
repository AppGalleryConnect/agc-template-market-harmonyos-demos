import { DeviceNotifyListViewModel } from '../viewmodel/DeviceNotifyListViewModel';
import { DeviceNotifyListView } from '../view/DeviceNotifyListView';
import { DeviceBaseInfoView } from 'uicomponents';

@Builder
export function MessageListPageBuilder(name: string, param: Object) {
  DeviceNotifyListPage({ deviceId: param as string });
}

@ComponentV2
export struct DeviceNotifyListPage {
  pathStack: NavPathStack = new NavPathStack();
  @Require @Param deviceId: string = '';
  messageListViewModel: DeviceNotifyListViewModel = new DeviceNotifyListViewModel(this.deviceId);

  build() {
    NavDestination() {
      Column() {
        DeviceBaseInfoView({ image: this.messageListViewModel.deviceImage,
                             name: this.messageListViewModel.deviceName });
        DeviceNotifyListView({ messageListViewModel: this.messageListViewModel }).margin({ top: 20 });
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('消息列表')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onBackPressed(() => {
      this.messageListViewModel.setDeviceMessageRead();
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor('#F1F3F5');
  }
}