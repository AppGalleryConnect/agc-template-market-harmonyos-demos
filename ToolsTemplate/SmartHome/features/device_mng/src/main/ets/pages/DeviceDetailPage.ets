import { Constants } from 'utils';
import { DeviceDetailViewModel } from '../viewmodel/DeviceDetailViewModel';
import { DeviceCommonInfoView } from '../view/DeviceCommonInfoView';
import { DevicePrivateInfoView } from '../view/DevicePrivateInfoView';
import { CustomContentDialog } from '@kit.ArkUI';

@Builder
export function DeviceDetailPageBuilder(name: string, param: Object) {
  DeviceDetailPage({ deviceId: param as string });
}

@ComponentV2
export struct DeviceDetailPage {
  pathStack: NavPathStack = new NavPathStack();
  @Require @Param deviceId: string = '';
  deviceDetailViewModel: DeviceDetailViewModel = new DeviceDetailViewModel(this.deviceId);
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '确定删除？',
      contentBuilder: () => {
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info('Callback when the button is clicked');
          },
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info('Callback when the button is clicked');
            this.deviceDetailViewModel.deleteDevice();
            this.pathStack.pop();
          },
        },
      ],
    }),
    backgroundColor: Constants.CUSTOM_DIALOG_BACKGROUND_COLOR,
  });

  @Builder
  DeviceMenu() {
    Column() {
      Text('基本设置')
        .height(40)
        .onClick(() => {
          this.pathStack.pushPathByName('BaseSettingPage', this.deviceDetailViewModel.deviceId);
        })
      Divider().height(10).width('80%').color('#ccc')
      Text('删除设备')
        .height(40)
        .onClick(() => {
          this.dialogController.open();
        })
    }
    .width(100)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BuildDeviceAction() {
    Row() {
      Image($r('app.media.dot_grid_1x2'))
        .size({ width: 30, height: 30 })
        .bindMenu(this.DeviceMenu);
    }
    .width('10%')
    .height('100%');
  }

  build() {
    NavDestination() {
      Column() {
        DeviceCommonInfoView({ pathStack: this.pathStack, deviceDetailViewModel: this.deviceDetailViewModel });
        DevicePrivateInfoView({ deviceDetailViewModel: this.deviceDetailViewModel })
          .margin({ top: 20 });
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .menus(this.BuildDeviceAction)
    .title(this.deviceDetailViewModel.deviceName)
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
