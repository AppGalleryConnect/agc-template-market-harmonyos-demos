import { TextEditDialogParams } from '../model/Index';

@Builder
export function textEditDialog(textEditDialogParams: TextEditDialogParams) {
  Column({ space: 24 }) {
    TextInput({
      placeholder: textEditDialogParams.canvasItemStack.text ? '' : '点击输入文字',
      text: textEditDialogParams.canvasItemStack.text,
    })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .layoutWeight(1)
      .borderRadius(20)
      .onChange((value: string) => {
        textEditDialogParams.cloneText = value;
      });

    Row({ space: 24 }) {
      Button('取消')
        .layoutWeight(1)
        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          textEditDialogParams.close();
        });
      Button('确认')
        .layoutWeight(1)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .onClick(() => {
          textEditDialogParams.canvasItemStack.text = textEditDialogParams.cloneText;
          textEditDialogParams.close();
        });
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }
  .width('90%')
  .height(152)
  .borderRadius($r('sys.float.corner_radius_level8'))
  .backgroundColor($r('sys.color.comp_background_primary'))
  .padding({
    left: 12,
    right: 12,
    top: 24,
    bottom: 24,
  })
  .justifyContent(FlexAlign.SpaceBetween);
}