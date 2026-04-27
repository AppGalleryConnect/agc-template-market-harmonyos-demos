export class NfcOpenDialogParams {
  confirm?: Function;
  cancel?: Function;
}

@Builder
export function nfcOpenDialog(params: NfcOpenDialogParams) {
  Column() {
    Image($r('app.media.ic_nfc_able'))
      .fitOriginalSize(true);
    Row() {
      Text('提示').fontSize(19).fontColor('#333333');
      Image($r('app.media.ic_detail_memory'))
        .fitOriginalSize(true);
    }.alignItems(VerticalAlign.Top)
    .margin({ top: 30 });

    Text('请先开启NFC').fontSize(14).fontColor('#333333')
      .margin({ top: 10 });

    Row() {
      Button('取消').onClick(() => {
        params.cancel!();
      });

      Button('去开启').onClick(() => {
        params.confirm!();
      });
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 20 });
  }.backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, {
    colorMode: ThemeColorMode.LIGHT,
    adaptiveColor: AdaptiveColor.DEFAULT,
    scale: 1.0,
  })
  .borderRadius(13)
  .width('80%')
  .padding(30);
}