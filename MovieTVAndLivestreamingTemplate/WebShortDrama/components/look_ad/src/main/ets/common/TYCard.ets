import { FontModel } from '../model/FontModel'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct TYCard {
  @Param topPadding: number = 16
  @Param bottomPadding: number = 16
  @Param leftPadding: number = 12
  @Param rightPadding: number = 12
  @Param bottomMargin: number = 0
  @BuilderParam content: () => void
  @Consumer('leftCount') leftCount:number = 0
  @Param award:string = '领看点'
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  @Builder
  renderLeftText() {
      Text() {
        Span('看广告'+this.award+'(')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(this.fontModel.getFg(16))
        Span(this.leftCount + '')
          .fontWeight(FontWeight.Bold)
          .fontSize(this.fontModel.getFg(16))
          .fontColor('#EC6E45')
        Span('/3)')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(this.fontModel.getFg(16))
      }
  }

  build() {
    Column() {
      Row() {
        this.renderLeftText()
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      if (this.content) {
        this.content()
      }

    }
    .width('100%')
    .margin({ top: 12, bottom: this.bottomMargin })
    .padding({
      top: this.topPadding,
      bottom: this.bottomPadding,
      left: this.leftPadding,
      right: this.rightPadding
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}