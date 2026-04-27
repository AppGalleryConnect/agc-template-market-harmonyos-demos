import { AppStorageV2 } from '@kit.ArkUI'
import { CMChatGroupInfo } from 'instant_messaging'
import { BreakpointModel } from '../model/BreakpointModel'

@ComponentV2
export struct GroupProfileButton {
  @Param @Require onReturnClick?: () => void
  @Param @Require memberInfoList: CMChatGroupInfo
  @Param @Require onCompleteClick?: () => void
  @Param titles: string = ''
  @Param rightImageRes: Resource | undefined = undefined
  @Param rightTitle: ResourceStr | undefined = undefined
  @Param fontWightParam: FontWeight | number = 700
  @Param backgroundColorParam: ResourceStr | undefined = $r('sys.color.background_secondary')
  @Param rowFlexAlign: FlexAlign | undefined = FlexAlign.Start
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize($r('app.float.vp_24'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ right: this.breakPointModel.pagePadding / 2 })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.onReturnClick) {
          this.onReturnClick?.()
        }
      })

      Text(this.titles)
        .size({ height: 27 })
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(this.fontWightParam)
        .fontColor($r('sys.color.font_primary'))
      Blank().layoutWeight(1)
      if (this.memberInfoList.role === 400) {
        Button($r('app.string.complete'))
          .width(68)
          .height(26)
          .margin({ left: 10, right: 16 ,top : 20 , bottom : 10})
          .backgroundColor('#0A59F7')
          .onClick(() => {
            if (this.onCompleteClick) {
              this.onCompleteClick?.()
            }
          })
      }
    }
    .height(40)
    .width('100%')
    .margin({ top: 8, bottom: 8 })
    .justifyContent(this.rowFlexAlign)
    .backgroundColor(this.backgroundColorParam)
  }
}