import { PairedDeviceModel } from '../viewmodel/ScannedDevice';

/**
 * @usage: 设备信息展示组件，用于显示设备的电量和充电次数信息。主要数据结构包括ScannedDevice（扫描设备模型），
 * 包含battery（电量百分比）、chargeCycles（充电次数）等关键数据。采用左右分栏布局展示两项设备信息。
 * @layout: 行布局（Row），包含左侧空白区域和主要内容Row。主要内容分为左右两部分：左侧显示电量信息Column，
 * 右侧显示充电次数信息Column，中间用分割线Blank分隔。整体采用水平布局，各信息项采用垂直居中对齐。
 * @constraints: ScannedDevice数据模型必须提供，组件尺寸固定，文本颜色和字体样式固定，分割线样式固定。
 * @isGen: true
 * @fileType: component
 * @zhName: 设备信息组件:
 */
@ComponentV2
export struct DeviceInfo {
  @Param @Require pairedDeviceVM: PairedDeviceModel;

  build() {
    Row() {
      Blank().width($r('app.float.vp_16'))

      Column() {
        Text() {
          Span(this.pairedDeviceVM.battery.toString())
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
          Span($r('app.string.device_info_current_battery_per'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }

        Text($r('app.string.device_info_current_battery'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Blank()
        .height($r('app.float.vp_36'))
        .width('1px')
        .color($r('sys.color.comp_divider'))

      Column() {
        Text() {
          Span(this.pairedDeviceVM.chargeCycles.toString())
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
          Span($r('app.string.device_info_charge_cycles'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }

        Text($r('app.string.device_info_charge_cycles_title'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Blank().width($r('app.float.vp_16'))
    }
    .height($r('app.float.vp_88'))
    .width('100%')
    .backgroundColor(Color.White)
    .clip(true)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .alignItems(VerticalAlign.Center)
  }
}