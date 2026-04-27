import { PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { CommonHeader, Constants } from 'common';
import { DeviceConnect } from '../comp/DeviceConnect';
import { DeviceModel } from '../viewmodel/DeviceModel';
import { PairedDeviceMacList, PairedDeviceModel } from '../viewmodel/ScannedDevice';
import { DeviceRow } from '../comp/DeviceRow';
import { OHPage } from 'oh_router';

@Builder
export function DevicePageBuilder() {
  DevicePage()
}

/**
 * @usage: 设备模块主页面，提供智能设备连接和管理功能。支持蓝牙设备扫描、配对、连接和设备信息管理。
 * 主要数据结构包括DeviceModel（设备数据模型）。包含if逻辑用于设备状态判断和事件处理。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，下方为设备列表区域。
 * 设备列表使用ForEach循环渲染已配对设备，底部为设备连接组件。所有元素居中对齐。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 设备主页面
 * @fileType: page
 * @isGen: true
 * @subPage:
 * @component: CommonHeader,DeviceRow,DeviceConnect,OHPage
 * @image: screenshot/device.jpg
 */
@ComponentV2
export struct DevicePage {
  deviceModelVM: DeviceModel = DeviceModel.instance;
  @Local macList: PairedDeviceMacList = PersistenceV2.connect(PairedDeviceMacList, () => new PairedDeviceMacList())!;
  @Local onReturnClick: () => void = () => {

  }
  @Local onForegroundChange: () => void = () => {
    this.deviceModelVM.getPairDeviceInfo();
  }
  @Local onPairDeviceChange: () => void = () => {
    this.deviceModelVM.getPairDeviceInfo();
  }

  aboutToAppear(): void {
    try {
      this.deviceModelVM.uiContext = this.getUIContext();
      emitter.on(Constants.onForegroundChange, this.onForegroundChange);
      emitter.on(Constants.onPairDeviceChange, this.onPairDeviceChange);
    } catch (err) {
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off(Constants.onForegroundChange.eventId, this.onForegroundChange);
      emitter.off(Constants.onPairDeviceChange.eventId, this.onPairDeviceChange);
    } catch (err) {
    }
  }

  // 页面内容渲染
  @Builder
  render() {
    CommonHeader({
      title: $r('app.string.module_name'),
      onReturnClick: this.onReturnClick,
      backgroundColorParam: $r('app.color.color_F1F3F5')
    })

    Column() {
      ForEach(this.macList.pairedList, (item: PairedDeviceModel, _index: number) => {
        DeviceRow({
          pairedDeviceVM: item,
          onAgainConnectClick: () => {
            this.deviceModelVM.currentMainPage = true;
            this.deviceModelVM.pairDevice(item.deviceId);
          }
        });
        Blank().height($r('app.float.vp_12'))
      }, (item: PairedDeviceModel) => item.keyId)

      DeviceConnect({
        deviceModelVM: this.deviceModelVM,
        onConnectClick: () => {
          this.deviceModelVM.startScan();
        }
      })
    }
    .layoutWeight(1)
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }
}

