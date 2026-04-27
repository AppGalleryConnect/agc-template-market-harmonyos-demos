import { PairedDeviceModel } from '../viewmodel/ScannedDevice';
import { DeviceModel } from '../viewmodel/DeviceModel';
import { phoneRouterControl } from 'oh_router';
import { RouterMap } from 'common';
import { DeviceInfoPageBuilder } from '../views/DeviceInfoPage';

/**
 * @usage: 设备列表行组件，用于显示单个设备的信息和连接状态。主要数据结构包括ScannedDevice（扫描设备模型），
 * 包含deviceName（设备名称）、pairState（配对状态）等关键数据。包含重新连接点击事件处理逻辑和条件显示逻辑。
 * @layout: 行布局（Row），包含左侧空白区域和主要内容Row。主要内容从左到右依次为：设备图标Image、
 * 设备信息Column（包含设备名称和状态信息Row）。设备信息采用垂直布局，状态信息采用水平布局。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 设备行组件
 * @isGen: true
 * @fileType: component
 * @subPage: DeviceInfoPage
 * @image: screenshot/device/DeviceRow.jpg
 */
@ComponentV2
export struct DeviceRow {
  @Param @Require pairedDeviceVM: PairedDeviceModel;
  @Param isMainPage: boolean = true;
  @Event onAgainConnectClick: () => void = () => {
  };

  build() {
    Row() {
      Blank().width($r('app.float.vp_16'))

      Image($r('app.media.device_add'))
        .width($r('app.float.vp_60'))
        .height($r('app.float.vp_60'))
        .objectFit(ImageFit.Contain)

      Blank().width($r('app.float.vp_16'))

      Column() {
        Text(this.pairedDeviceVM.deviceName)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)

        Blank().height($r('app.float.vp_6'))

        Row() {
          Text(this.pairedDeviceVM.pairState === 2
            ? $r('app.string.device_pair_status_connected')
            : $r('app.string.device_pair_status_not_connected'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.color_66000000'))

          if (this.isMainPage) {
            Blank().width($r('app.float.vp_20'))

            Text($r('app.string.device_pair_status_reconnect'))
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.color_0A59F7'))
              .visibility(this.pairedDeviceVM.pairState === 2 ? Visibility.None : Visibility.Visible)
              .onClick(this.onAgainConnectClick)

            Text() {
              Span($r('app.string.device_info_current_battery'))
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('app.color.color_66000000'))
              Span(this.pairedDeviceVM.battery + '%')
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.Black)
            }
            .visibility(this.pairedDeviceVM.pairState === 2 ? Visibility.Visible : Visibility.None)
          }
        }
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Blank().width($r('app.float.vp_16'))
    }
    .height($r('app.float.vp_88'))
    .width('100%')
    .backgroundColor(Color.White)
    .clip(true)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.isMainPage && this.pairedDeviceVM.pairState === 2) {
        if (!DeviceModel.instance.isBluetoothEnabled()) {
          DeviceModel.instance.enableBluetooth()
          return
        }

        phoneRouterControl.jumpPage({
          pageName: RouterMap.DEVICE_INFO_PAGE,
          builder: wrapBuilder(DeviceInfoPageBuilder),
          param: this.pairedDeviceVM
        })
      }
    })
  }
}