import { BleScanViewModel } from '../viewmodel/BleScanViewModel';
import { ScannedDeviceViewModel } from '../viewmodel/BleScanViewModel';

@ComponentV2
export struct BleScannedDevicesView {
  @Require @Param pathStack: NavPathStack;
  @Require @Param bleClientViewModel: BleScanViewModel;
  private listScroller: Scroller = new Scroller();

  @Builder BuildBleScannedNum() {
      Column() {
        Text('已搜索到设备')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .height('15%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
  }

  @Builder BuildBleScannedDevices() {
    List({ space: 20, scroller: this.listScroller }) {
      ForEach(this.bleClientViewModel.devices, (item: ScannedDeviceViewModel, index: number) => {
        ListItem() {
          BleScannedDeviceView({scannedDeviceViewModel: item, pathStack: this.pathStack,
            bleClientViewModel: this.bleClientViewModel})
        }
      }, (item: ScannedDeviceViewModel, index: number) => item.deviceId)
    }
    .scrollBar(BarState.Off)
    .margin({top: '15%', bottom: '10%'})
    .alignListItem(ListItemAlign.Center)
  }

  build() {
    Column() {
      Column() {
        Stack() {
          if (this.bleClientViewModel.devices.length !== 0) {
            this.BuildBleScannedNum()
            this.BuildBleScannedDevices()
          }
        }
        .alignContent(Alignment.Top)
        .width('90%');
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .width('100%');
    }
    .height('45%')
    .width('90%')
  }
}

@ComponentV2
export struct BleScannedDeviceView {
  @Require @Param pathStack: NavPathStack
  @Require @Param scannedDeviceViewModel: ScannedDeviceViewModel
  @Require @Param bleClientViewModel: BleScanViewModel

  @Builder BuildDeviceText() {

    Text(this.scannedDeviceViewModel.deviceName)
      .textOverflow({ overflow: TextOverflow.MARQUEE  })
      .maxLines(1)
      .fontSize(14)
      .margin({left: 10})
      .width('40%')
  }

  @Builder BuildDeviceImage() {
    Image(this.scannedDeviceViewModel.deviceImage)
      .size({ width: 45})
      .margin({left: 10})
  }

  @Builder BuildDeviceConnect() {
    Stack() {
      Button('连接')
        .onClick(() => {
          this.bleClientViewModel.connect(this.scannedDeviceViewModel.deviceId)
        })
        .backgroundColor('#0A59F7')
        .fontSize(14)
        .height(30)
        .visibility(this.scannedDeviceViewModel.isConnectVisible ? Visibility.Visible :  Visibility.Hidden)

      Text('连接中...')
        .fontSize(14)
        .visibility(this.scannedDeviceViewModel.isConnectingVisible ? Visibility.Visible :  Visibility.Hidden)

      Row() {
        Text('已连接')
          .fontSize(14)
          .margin({right: 10})
        Image($r('app.media.right'))
          .size({ width: 14, height: 14 })
          .opacity(0.6)

      }
      .visibility(this.scannedDeviceViewModel.isConnectedVisible ? Visibility.Visible :  Visibility.Hidden)
      .onClick(() => {
        this.pathStack.pushPathByName('SelectWifiPage', this.scannedDeviceViewModel.deviceId)
      })
    }
    .margin({right: 10})
  }

  build() {
    Row() {
      Row() {
        this.BuildDeviceImage()
        this.BuildDeviceText()
        Blank()
        this.BuildDeviceConnect()
      }
      .width('95%')
    }
    .justifyContent(FlexAlign.Center)
    .height(65)
    .width('100%')
    .backgroundColor('#F1F3F5')
    .borderRadius(8)
  }
}