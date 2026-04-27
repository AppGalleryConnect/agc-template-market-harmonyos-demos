import { emitter } from '@kit.BasicServicesKit';
import { connection } from '@kit.ConnectivityKit';
import { ScannedDevice } from '../viewmodel/ScannedDevice';
import { DeviceModel } from '../viewmodel/DeviceModel';
import { Constants } from 'common';

/**
 * @usage: 设备扫描列表行组件，用于显示扫描到的设备信息和提供连接操作。主要数据结构包括ScannedDevice（扫描设备模型）
 * 和DeviceModel（设备模型），包含deviceName（设备名称）、deviceId（设备ID）等关键数据。包含连接按钮点击事件处理逻辑。
 * @layout: 行布局（Row），包含左右空白区域和主要内容Row。主要内容从左到右依次为：设备名称Text、连接按钮Button。
 * 整体采用水平布局，设备名称占据剩余空间，连接按钮固定宽度。
 * @constraints: ScannedDevice和DeviceModel数据模型必须提供，连接按钮尺寸固定为64x36，组件高度固定为64，背景色和圆角半径固定。
 * @isGen: true
 * @fileType: component
 * @zhName: 设备扫描行组件
 */
@ComponentV2
export struct DeviceScanRow {
  @Param @Require scannedDeviceVM: ScannedDevice;
  @Param @Require deviceModelVM: DeviceModel;
  @Local pairState: connection.BondState = connection.BondState.BOND_STATE_INVALID;
  @Event onConnectClick: () => void = () => {
  };
  @Local onBluetoothScanningChange: () => void = () => {
    this.pairState = connection.getPairState(this.scannedDeviceVM.deviceId);
  };

  aboutToAppear(): void {
    try {
      this.pairState = this.scannedDeviceVM.pairState;
      emitter.on(Constants.onBluetoothScanningChange, this.onBluetoothScanningChange);
    } catch (err) {
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off(Constants.onBluetoothScanningChange.eventId, this.onBluetoothScanningChange);
    } catch (err) {
    }
  }

  build() {
    Row() {
      Blank().width($r('app.float.vp_16'))

      Text(this.scannedDeviceVM.deviceName)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.Black)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)

      Blank().width($r('app.float.vp_12'))

      Button(this.pairState === 0 ?
      $r('app.string.scanning_device_connect_btn') :
      $r('app.string.scanning_device_connecting_btn'))
        .type(ButtonType.Capsule)
        .width($r('app.float.vp_82'))
        .fontSize($r('sys.float.Body_M'))
        .onClick(() => {
          if (this.pairState === 0) {
            this.deviceModelVM.currentMainPage = false;
            this.deviceModelVM.pairDevice(this.scannedDeviceVM.deviceId);
          }
        })
      Blank().width($r('app.float.vp_16'))
    }
    .height($r('app.float.vp_64'))
    .width('100%')
    .backgroundColor($r('app.color.color_F1F3F5'))
    .clip(true)
    .borderRadius($r('sys.float.corner_radius_level6'))
    .alignItems(VerticalAlign.Center)
  }
}