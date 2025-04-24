import { Constants } from 'utils';
import { BaseSettingViewModel } from '../viewmodel/BaseSettingViewModel';
import { TextSettingBarView } from 'uicomponents';

@Builder
export function BaseSettingPageBuilder(name: string, param: Object) {
  BaseSettingPage({ deviceId: param as string });
}

@ComponentV2
export struct BaseSettingPage {
  pathStack: NavPathStack = new NavPathStack();
  @Require @Param deviceId: string = '';
  baseSettingViewModel: BaseSettingViewModel = new BaseSettingViewModel(this.deviceId);

  @Builder
  BuildDeviceNameSetting() {
    TextSettingBarView({
      // nameImage: '',
      name: '设备名称',
      value: this.baseSettingViewModel.deviceName,
      valueChangeCb: (value: string) => {
        this.baseSettingViewModel.setDeviceName(value);
      },
    });
  }

  @Builder
  BuildSetting() {
    List() {
      ListItem() {
        this.BuildDeviceNameSetting();
      }
      .margin({ left: 10, right: 10 })
      .height(50);
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
        this.BuildSetting();
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('基本设置')
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