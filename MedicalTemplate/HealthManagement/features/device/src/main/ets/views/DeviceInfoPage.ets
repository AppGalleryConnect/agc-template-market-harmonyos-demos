import { emitter } from '@kit.BasicServicesKit';
import { CommonHeader, Constants, TCLogger, TValueType } from 'common';
import { DeviceInfo } from '../comp/DeviceInfo';
import { PairedDeviceModel } from '../viewmodel/ScannedDevice';
import { DeviceRow } from '../comp/DeviceRow';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UnbindDeviceDialog } from '../comp/UnbindDeviceDialog';
import { DeviceModel } from '../viewmodel/DeviceModel';

const TAG = 'DeviceInfoPage';

@Builder
export function DeviceInfoPageBuilder(deviceVM: TValueType) {
  DeviceInfoPage({
    deviceVM: deviceVM
  })
}

/**
 * @usage: 设备详情页面，用于显示已配对设备的详细信息和管理功能。主要数据结构为ScannedDevice（扫描设备模型），
 * 支持设备信息查看、解绑操作和状态监控。包含前后台切换监听和设备状态检查逻辑。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏显示设备名称，
 * 中间为设备图标和设备信息展示区域（DeviceRow和DeviceInfo组件），底部为解绑按钮。所有元素垂直居中排列。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 设备详情页面
 * @fileType: page
 * @isGen: true
 * @subPage:
 * @component: CommonHeader,DeviceInfo,UnbindDeviceDialog,OHPage
 * @image: screenshot/device/DeviceInfo.jpg
 */
@ComponentV2
export struct DeviceInfoPage {
  @Param @Require deviceVM: TValueType;
  @Local pairedDeviceVM?: PairedDeviceModel;
  @Local onForegroundChange: () => void = () => {
    DeviceModel.instance.checkPairState(this.pairedDeviceVM?.deviceId ?? '');
  }

  aboutToAppear(): void {
    try {
      emitter.on(Constants.onForegroundChange, this.onForegroundChange);
      this.pairedDeviceVM = this.deviceVM as PairedDeviceModel;
    } catch (err) {
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off(Constants.onForegroundChange.eventId, this.onForegroundChange);
    } catch (err) {
    }
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: this.pairedDeviceVM?.deviceName,
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
        leftImageRes: $r('app.media.ic_backward2')
      })

      Column() {
        Blank().height($r('app.float.vp_16'))
        Image($r('app.media.device_add'))
          .size({ width: $r('app.float.vp_220'), height: $r('app.float.vp_220') })

        Blank().height($r('app.float.vp_16'))

        DeviceRow({ pairedDeviceVM: this.pairedDeviceVM, isMainPage: false });

        Blank().height($r('app.float.vp_12'))
        DeviceInfo({
          pairedDeviceVM: this.pairedDeviceVM
        })

        Blank().height($r('app.float.vp_30'))

        Button($r('app.string.device_info_unbind_btn'))
          .width('100%')
          .height($r('app.float.vp_40'))
          .fontColor($r('sys.color.warning'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.color_1AE84026'))
          .onClick(() => {
            TCLogger.info(TAG, `on confirm`);
            UnbindDeviceDialog.ShowUnbindPopup();
          })
      }
      .height($r('app.float.vp_264'))
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('app.color.color_F1F3F5'))
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


