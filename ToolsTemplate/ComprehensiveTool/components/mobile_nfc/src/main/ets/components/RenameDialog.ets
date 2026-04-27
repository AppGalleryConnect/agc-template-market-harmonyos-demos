import { RenameDialogParams } from '../model/Index';

@Builder
export function renameDialog(params: RenameDialogParams) {
  Column() {
    TextInput({ placeholder: '填写卡片名称（10个字以内）', text: params.name })
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .onChange((value) => {
        params.name = value;
      })
      .maxLength(10);
    Row() {
      Button('取消')
        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 140, height: 40 })
        .onClick(() => {
          params.cancel!();
        });
      Button('确定')
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .fontColor($r('sys.color.font_on_primary'))
        .size({ width: 140, height: 40 })
        .onClick(() => {
          params.confirm!(params.name);
        });
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 24 });
  }.backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, {
    colorMode: ThemeColorMode.LIGHT,
    adaptiveColor: AdaptiveColor.DEFAULT,
    scale: 1.0
  })
  .borderRadius(32)
  .width('90%')
  .padding({
    left: 12,
    right: 12,
    top: 24,
    bottom: 24,
  });
}