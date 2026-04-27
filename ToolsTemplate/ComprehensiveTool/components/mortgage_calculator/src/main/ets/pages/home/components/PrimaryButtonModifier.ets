export class PrimaryButtonModifier implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.type(ButtonType.Normal)
      .borderRadius(20)
      .height(40)
      .backgroundColor($r('app.string.theme_color'))
      .width('100%')
  }
}