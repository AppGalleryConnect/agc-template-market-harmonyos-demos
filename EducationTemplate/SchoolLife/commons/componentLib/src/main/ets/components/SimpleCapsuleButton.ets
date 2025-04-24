import { ComponentConst } from '../constant/ComponentConst';

@ComponentV2
export struct SimpleCapsuleButton {
  @Param @Require buttonBgColor: ResourceColor;
  @Param @Require iconSrc: PixelMap | ResourceStr | DrawableDescriptor;
  @Param @Require textContent: string | Resource;
  @Param @Require textColor: ResourceColor;
  @Local buttonHeight: number = 28;

  build() {
    Button({ type: ButtonType.Capsule, stateEffect: true }) {
      Row() {
        Image(this.iconSrc)
          .objectFit(ImageFit.Fill)
          .size(ComponentConst.ICON_SIZE_S)

        Text(this.textContent)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.textColor)
          .margin({ left: $r('app.string.margin_s') })
      }
      .padding({
        top: 5,
        bottom: 5,
        left: $r('app.string.padding_m'),
        right: $r('app.string.padding_m'),
      })
      .alignItems(VerticalAlign.Center)
    }
    .height(this.buttonHeight)
    .backgroundColor(this.buttonBgColor)
  }
}