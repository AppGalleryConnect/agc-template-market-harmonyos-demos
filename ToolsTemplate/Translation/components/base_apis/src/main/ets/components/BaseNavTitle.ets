import { BaseTextStyleModifier } from '../model/TextStyleModifier';

@ComponentV2
export struct BaseNavTitle {
  @Param title: ResourceStr = ''
  @Param bgImage: ResourceStr = ''
  @Param titleColor: ResourceStr = '#ffffff'
  @Param currentTheme: ResourceStr = '#c4272b'
  @Param routerModule:NavPathStack = new NavPathStack()

  build() {
    Row({ space: 8 }) {
      Row() {
        Image($r('app.media.left')).width(24).height(24)
      }
      .width(40)
      .justifyContent(FlexAlign.Center)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius('50%')

      Text(this.title)
        .attributeModifier(new BaseTextStyleModifier(`${this.titleColor}/Title_S/Bold`))
    }
    .height(102)
    .width('100%')
    .onClick(() => {
      this.routerModule.pop()
    })
    .padding({ top: Number(AppStorage.get('topRectHeight')), left: 16, right: 16 })
    .backgroundColor(this.currentTheme)
    .backgroundImage(this.bgImage)
    .backgroundImageSize(ImageSize.Cover)
  }
}