import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel } from '../model/BreakpointModel'

/**
 * @fileType: common
 * @zhName: 通用导航栏组件
 */
@ComponentV2
export struct CommonHeader {
  @Param @Require onReturnClick?: () => void
  @Param title: string = ''
  @Param avatarUrl: ResourceStr | undefined = undefined
  @Param rightImageRes: Resource | undefined = undefined
  @Param showBack: boolean = true
  @Param fontWightParam: FontWeight | number = 400
  @Param backgroundColorParam: ResourceStr | undefined | Color = $r('sys.color.background_secondary')
  @Param rowFlexAlign: FlexAlign | undefined = FlexAlign.Start
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      if(this.showBack){
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .fontWeight(FontWeight.Normal)
        }
        .width(40)
        .height(40)
        .padding({})
        .margin({ right: this.breakPointModel.pagePadding / 2 })
        .type(ButtonType.Circle)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          if (this.onReturnClick) {
            this.onReturnClick?.()
          }
        })
      }

      if (this.avatarUrl) {
        Image(this.avatarUrl).size({ width: 26, height: 26 })
          .margin({ right: 8 })
      }

      Text(this.title).size({ height: 27 })
        .fontSize(20)
        .fontWeight(this.fontWightParam)
        .fontColor($r('sys.color.font_primary'))

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