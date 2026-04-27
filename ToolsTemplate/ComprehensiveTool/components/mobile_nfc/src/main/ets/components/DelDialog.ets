export class DelDialogParams {
  cancel?: Function;
  confirm?: Function;
}

@Builder
export function delDialog(params: DelDialogParams) {
  Column() {
    Text('是否确认删除卡片？').width('100%').textAlign(TextAlign.Center);
    Row() {
      Text('取消').width('50%').fontColor($r('sys.color.font_primary')).textAlign(TextAlign.Center)
        .onClick(() => {
          params.cancel!();
        });
      Text('删除').width('50%').fontColor($r('sys.color.warning')).textAlign(TextAlign.Center)
        .onClick(() => {
          params.confirm!();
        });
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 32 });
  }.backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, {
    colorMode: ThemeColorMode.LIGHT,
    adaptiveColor: AdaptiveColor.DEFAULT,
    scale: 1.0,
  })
  .borderRadius(32)
  .width('90%')
  .padding(24);
}