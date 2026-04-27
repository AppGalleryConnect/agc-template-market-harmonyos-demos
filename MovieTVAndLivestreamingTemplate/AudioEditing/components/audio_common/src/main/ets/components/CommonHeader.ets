import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel } from '../model/BreakpointModel'

@ComponentV2
export struct CommonHeader {
  @Param @Require onReturnClick?: () => void
  @Param title: string = ''
  @Param rightImageRes: Resource | undefined = undefined
  @Param fontWightParam: FontWeight | number = 700
  @Param backgroundColorParam: ResourceStr | undefined = $r('sys.color.background_secondary')
  @Param iconBackgroundColorParam: ResourceStr | undefined = $r('sys.color.comp_background_tertiary')
  @Param fontColorParam: ResourceStr | undefined = $r('sys.color.font_primary')
  @Param iconColorParam: ResourceStr | undefined = $r('sys.color.icon_primary')
  @Param rowFlexAlign: FlexAlign | undefined = FlexAlign.Start
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([this.iconColorParam])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ right: this.breakPointModel.pagePadding / 2 })
      .type(ButtonType.Circle)
      .backgroundColor(this.iconBackgroundColorParam)
      .onClick(() => {
        if (this.onReturnClick) {
          this.onReturnClick?.()
        }
      })

      Text(this.title).size({ height: 27 })
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(this.fontWightParam)
        .fontColor(this.fontColorParam)
      if (this.rightImageRes) {
        Image(this.rightImageRes).size({ width: 40, height: 40 })
          .margin({ right: 16 })
          .onClick(this.rightOnClick)
      } else {
        Row().size({ width: 40, height: 40 }).margin({ right: 16, left: '8vp' })
      }
    }
    .height(40)
    .width('100%')
    .margin({ top: 8, bottom: 8 })
    .justifyContent(this.rowFlexAlign)
    .backgroundColor(this.backgroundColorParam)
  }
}