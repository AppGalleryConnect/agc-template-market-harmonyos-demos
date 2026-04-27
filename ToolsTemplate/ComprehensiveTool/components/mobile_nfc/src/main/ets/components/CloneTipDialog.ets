import { CloneTipDialogParams } from '../model/Index';

@Builder
export function cloneTipDialog(params: CloneTipDialogParams) {
  Column() {
    Text('温馨提示').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'));
    Text('1.本软件仅支持门禁卡的克隆\n' +
      '2.如需克隆卡片请先读取卡片信息并添加到我的卡包\n' +
      '3.成功添加到卡包的卡片即可进行克隆')
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .margin({ top: 28, bottom: 20 });
    Text('我知道了').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_emphasize')).onClick(() => {
      params.confirm!();
    });
  }
  .alignItems(HorizontalAlign.Center)
  .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, {
    colorMode: ThemeColorMode.LIGHT,
    adaptiveColor: AdaptiveColor.DEFAULT,
    scale: 1.0,
  })
  .borderRadius(32)
  .width('90%')
  .padding(16)
  .height(240)
  .justifyContent(FlexAlign.Center);
}