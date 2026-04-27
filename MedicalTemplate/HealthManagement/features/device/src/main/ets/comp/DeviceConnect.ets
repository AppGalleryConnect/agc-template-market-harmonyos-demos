import { DeviceModel } from '../viewmodel/DeviceModel';

/**
 * @usage: 用于显示设备连接状态和提供连接操作入口。展示连接状态文本、连接提示信息和连接图标按钮。
 * 主要数据结构为DeviceModel（设备数据模型）。包含点击事件处理逻辑。
 * @layout: 组件采用横向布局（Row），左右两侧为空白间距，中间为设备连接信息卡片。卡片内部采用横向布局，
 * 左侧为连接状态和提示文本的垂直布局（Column），右侧为连接图标按钮。
 * @constraints: 用户需要修改提示文本，可以在DeviceModel文件中修改connectStatus和connectTip的值
 * @domain: 健康医疗
 * @zhName: 设备连接状态组件
 * @isGen: true
 * @fileType: component
 * @subPage: DeviceScanningPage
 * @image: screenshot/device/DeviceConnect.jpg
 */
@ComponentV2
export struct DeviceConnect {
  @Param @Require deviceModelVM: DeviceModel;
  @Event onConnectClick: () => void = () => {
  };

  build() {
    Row() {
      Blank().width($r('app.float.vp_16'))

      Column() {
        Text(this.deviceModelVM.connectStatus)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)

        Blank().height($r('app.float.vp_6'))
        Text(this.deviceModelVM.connectTip)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.color_999'))
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Image(this.deviceModelVM.icon)
        .width($r('app.float.vp_48'))
        .height($r('app.float.vp_48'))
        .objectFit(ImageFit.Contain)
      Blank().width($r('app.float.vp_16'))
    }
    .height($r('app.float.vp_88'))
    .width('100%')
    .backgroundColor(Color.White)
    .clip(true)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .alignItems(VerticalAlign.Center)
    .onClick(this.onConnectClick)
  }
}