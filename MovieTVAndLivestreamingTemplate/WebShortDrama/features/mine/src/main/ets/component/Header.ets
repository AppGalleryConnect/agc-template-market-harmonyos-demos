import { appRouter } from '@agctemplate/utils';
import { fp2pxUtil } from '@agctemplate/widgets';

@ComponentV2
export struct Header {
  @Param title: ResourceStr = ''
  @Param rightImageRes: Resource | undefined = undefined
  @Param fontWightParam: FontWeight | number = 700
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .accessibilityText('返回')
          .fontSize(fp2pxUtil(24))
          .fontColor([$r('sys.color.icon_primary')])
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .margin({ left: 16, right: '8vp' })
      .onClick(() => {
        appRouter.back(true)
      })

      Text(this.title).size({ width: 136, height: 27 })
        .fontSize(fp2pxUtil(20))
        .fontWeight(this.fontWightParam)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      if (this.rightImageRes) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph(this.rightImageRes)
            .fontSize(fp2pxUtil(24))
            .fontColor([$r('sys.color.icon_primary')])
        }
        .accessibilityText('全部删除')
        .width(40)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin({ right: 16 })
        .onClick(this.rightOnClick)
      }
    }
    .height(40)
    .width('100%')
    .margin({ top: 8, bottom: 8 })
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}