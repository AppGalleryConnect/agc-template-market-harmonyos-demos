import { AccessSettingBarView } from 'uicomponents';
import { Constants } from 'utils';
import { AccessControlViewModel } from '../viewmodel/AccessControlViewModel';

@Builder
export function AccessControlPageBuilder(name: string, param: Object) {
  AccessControlPage();
}

@ComponentV2
export struct AccessControlPage {
  pathStack: NavPathStack = new NavPathStack();
  accessControlViewModel: AccessControlViewModel = AccessControlViewModel.getInstance();

  @Builder
  BuildBarStartImage(nameImage: ResourceStr) {
    Image(nameImage)
      .size({ width: 18, height: 18 });
  }

  @Builder
  BuildBluetooth() {
    AccessSettingBarView({
      startImage: $r('app.media.bluetooth'),
      name: '蓝牙',
      value: this.accessControlViewModel.bluetoothAccess ? '已授权' : '未授权',
    });
  }

  @Builder
  BuildAccess() {
    List() {
      ListItem() {
        this.BuildBluetooth();
      }.margin({ left: 10, right: 10 }).height(50);
    }
    .alignListItem(ListItemAlign.Center)
    .divider({
      strokeWidth: 1,
      color: '#F1F3F5',
      startMargin: 10,
      endMargin: 10,
    })
    .width('90%')
    .borderRadius(16)
    .backgroundColor(Constants.COMMON_BAR_BACKGROUND_COLOR)
    .margin({ top: 10 });
  }

  build() {
    NavDestination() {
      Column() {
        this.BuildAccess();
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('权限管理')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR);
  }
}