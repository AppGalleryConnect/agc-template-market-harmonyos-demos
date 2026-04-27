import { AVCastPicker } from '@kit.AVSessionKit';

@ComponentV2
export struct CastPicker {
  @Param text: string = '';

  build() {
    AVCastPicker({
      normalColor: Color.Red,
      customPicker: () => this.customPickerBuilder(),
    })
      .width('100%')
      .height(72);
  }

  @Builder
  customPickerBuilder(): void {
    Row({ space: 12 }) {
      Image($r('app.media.ic_device')).width(40);
      Text(this.text)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
    }
    .width('100%')
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(10, 89, 247, 0.1)')
    .borderRadius(16);
  }
}
