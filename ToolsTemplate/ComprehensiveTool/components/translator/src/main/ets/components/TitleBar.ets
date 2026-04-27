import { getInstance } from '../common/CommonRoute'

@ComponentV2
export struct TitleBar {
  @Param name: string = ''
  @Require @Param img: Resource
  @Event onClear: () => void = () => {
  }

  build() {
    Row() {
      Row({ space: 8 }) {
        Row() {
          Image($r('app.media.tran_chevron_left'))
            .width(12)
            .height(24)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          getInstance().pop()
        })

        Text(this.name)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
      }

      Row() {
        SymbolGlyph(this.img)
          .fontSize(21)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.onClear()
      })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
    })
  }
}