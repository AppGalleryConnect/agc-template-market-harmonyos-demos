import { Constants } from 'common'

@ComponentV2
export struct BaseTip {
  @Param text: ResourceStr = ''
  @Param icon: ResourceStr = $r('app.media.ic_tips')
  @Event onClickTip?: () => void

  build() {
    Row({space:4}) {
      Image(this.icon).width(15).height(15)

      Text(this.text).fontSize(10).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .maxLines(1)
        .textOverflow({overflow: TextOverflow.Ellipsis})
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding({right: 10})
    .onClick(() => {
      this.onClickTip && this.onClickTip()
    })
  }
}