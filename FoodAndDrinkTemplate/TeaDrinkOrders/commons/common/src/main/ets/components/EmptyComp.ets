import { Constants } from '../constants/Common'

@ComponentV2
export struct EmptyComp {
  @Param text: ResourceStr = $r('app.string.empty_data')

  build() {
    Column() {
      Image($r('app.media.empty_data')).width(160)
      Text(this.text).fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ top: 12 })
    }.width(Constants.FULL_SIZE)
  }
}