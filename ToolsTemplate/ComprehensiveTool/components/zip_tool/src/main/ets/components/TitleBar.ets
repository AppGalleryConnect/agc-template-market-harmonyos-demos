import { getInstance } from '../common/CommonRoute'
import { ZipAvoidAreaUtil } from '../utils/ZipAvoidAreaUtil'

@ComponentV2
export struct TitleBar {
  @Param name: string = ''
  @Param isEdit: boolean = false
  @Event onEdit: (isClear: boolean) => void = () => {
  }
  @Event onSetting: () => void = () => {
  }

  build() {
    Row() {
      Row({ space: 8 }) {
        Row() {
          Image($r('app.media.zip_chevron_left'))
            .width(12)
            .height(24)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .margin({ right: 16 })
        .onClick(() => {
          getInstance().pop()
        })

        Text(this.name)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
      }

      if (this.isEdit) {
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.xmark_circle'))
              .fontSize(21)
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .justifyContent(FlexAlign.Center)
          .margin({ right: 16 })
          .onClick(() => {
            this.onEdit(true)
          })

          Row() {
            SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
              .fontSize(21)
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.onSetting()
          })
        }
      } else {
        Row() {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(21)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.onEdit(false)
        })
      }
    }
    .margin({ top: ZipAvoidAreaUtil.getZipTopHeight() })
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
    })
  }
}