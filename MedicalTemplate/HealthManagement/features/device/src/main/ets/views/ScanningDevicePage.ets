import { CommonHeader, Constants, BarVM } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { DeviceScanRow } from '../comp/DeviceScanRow';
import { deviceScanAngle } from '../constants/Constants';
import { deviceScanDelay } from '../constants/Constants';
import { DeviceModel } from '../viewmodel/DeviceModel';
import { ScannedDevice } from '../viewmodel/ScannedDevice';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function ScanningDevicePageBuilder() {
  ScanningDevicePage()
}

/**
 * @usage: 设备扫描页面，用于扫描和发现附近的蓝牙设备。主要数据结构为DeviceModel（设备数据模型）和
 * ScannedDevice数组（扫描到的设备列表），支持蓝牙设备扫描、设备列表展示和设备选择功能。包含扫描动画和设备状态提示。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，中间为扫描动画图标和提示文本，
 * 底部为扫描到的设备列表（List和Repeat组件）。扫描图标带有旋转动画效果。
 * @constraints:
 * @isGen: true
 * @fileType: page
 * @zhName: 设备扫描页面
 * @subPage: DevicePairHelpPage
 * @component: CommonHeader,DeviceScanRow
 * @image: screenshot/device/ScanningDevice.jpg
 */
@ComponentV2
export struct ScanningDevicePage {
  deviceModelVM: DeviceModel = DeviceModel.instance;
  @Local angle: number = 0;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local onEnableBluetoothChange: () => void = () => {
    this.deviceModelVM.scannedDevices = [];
    this.deviceModelVM.startBleScanInner();
  }
  @Local onForegroundChange: () => void = () => {
    this.deviceModelVM.scannedDevices = [];
    if (this.deviceModelVM.isBluetoothEnabled()) {
      this.deviceModelVM.startBleScanInner();
    } else {
      this.deviceModelVM.startBleScan();
    }
  }

  aboutToAppear(): void {
    try {
      this.deviceModelVM.scannedDevices = [];
      this.deviceModelVM.startBleScan();
      setTimeout(() => {
        this.angle = deviceScanAngle;
      }, deviceScanDelay)
      emitter.on(Constants.onEnableBluetoothChange, this.onEnableBluetoothChange);
      emitter.on(Constants.onForegroundChange, this.onForegroundChange);
    } catch (err) {
    }
  }

  aboutToDisappear(): void {
    try {
      this.deviceModelVM.stopBleScan();
      emitter.off(Constants.onEnableBluetoothChange.eventId, this.onEnableBluetoothChange);
      emitter.off(Constants.onForegroundChange.eventId, this.onForegroundChange);
    } catch (err) {
    }
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.scanning_device_title'),
        onReturnClick: this.onReturnClick,
        backgroundColorParam: Color.Transparent,
        leftImageRes: $r('app.media.ic_backward2')
      })

      Blank().height($r('app.float.vp_30'))

      Image($r('app.media.device_scanning'))
        .width($r('app.float.vp_270'))
        .height($r('app.float.vp_270'))
        .objectFit(ImageFit.Contain)
        .rotate({ angle: this.angle })
        .animation({
          duration: 3000,
          curve: Curve.Linear,
          iterations: -1,
          playMode: PlayMode.Normal
        })

      Blank().height($r('app.float.vp_54'))

      Text(this.deviceModelVM.scannedDevices.length === 0 ?
      $r('app.string.scanning_device_scan_tip') :
      $r('app.string.scanning_device_find_tip'))
        .fontSize($r('sys.float.Title_S'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)

      Blank().height($r('app.float.vp_4'))

      Text($r('app.string.scanning_device_tip'))
        .fontSize($r('sys.float.Body_S'))
        .fontColor('#999999')

      Blank().height($r('app.float.vp_40'))

      Column() {
        List({ space: 12 }) {
          Repeat<ScannedDevice>(this.deviceModelVM.scannedDevices)
            .each((ri: RepeatItem<ScannedDevice>) => {
              ListItem() {
                DeviceScanRow({
                  scannedDeviceVM: ri.item,
                  deviceModelVM: this.deviceModelVM
                })
              }
            })
            .key((item: ScannedDevice): string => item.deviceId)

            .virtualScroll({
              totalCount: this.deviceModelVM.scannedDevices.length
            })
            .templateId((_item: ScannedDevice, _index: number): string => {
              return '';
            })

          ListItem().height(px2vp(BarVM.instance.aiBarH))
        }
        .cachedCount(2)
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(Color.White)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      pageBackgroundColor: Color.White
    })
  }
}

