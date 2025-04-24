import { DeviceDetailViewModel } from '../viewmodel/DeviceDetailViewModel';

@ComponentV2
export struct DeviceCommonInfoView {
  @Require @Param pathStack: NavPathStack;
  @Require @Param deviceDetailViewModel: DeviceDetailViewModel;

  @Builder
  BuildDeviceImage() {
    Image(this.deviceDetailViewModel.deviceImage)
      .size({ width: 120 });
  }

  @Builder
  BuildConnectState() {
    Row() {
      Text('连接状态')
        .margin({ left: '4%' });
      Blank();
      if (this.deviceDetailViewModel.isDeviceE2EConnected) {
        Text('已连接')
          .fontColor('#64BB5C')
          .margin({ right: '4%' });
      } else {
        Text('未连接')
          .fontColor(Color.Gray)
          .margin({ right: '4%' });
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('90%')
    .height(50)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 20 });
  }

  build() {
    Row() {
      Column() {
        this.BuildDeviceImage();
        this.BuildConnectState();
      }
      .justifyContent(FlexAlign.Center)
      .width('100%');
    }
    .justifyContent(FlexAlign.Center)
    .height(150)
    .borderRadius(16);
  }
}