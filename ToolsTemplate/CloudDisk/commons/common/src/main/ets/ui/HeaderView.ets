/**
 * @fileType: common
 * @zhName: 头部视图组件
 */
import { Constants } from '../constant/Constants'

@ComponentV2
export struct HeaderView {
  @Param title: string | Resource = ''
  @Event clickBackBtn: () => void
  @Event clickRightBtn: () => void

  build() {
    Row() {
      Image($r('app.media.goback'))
        .width(40)
        .height(40)
        .onClick(() => {
          if (this.clickBackBtn) {
            this.clickBackBtn()
          }
        })

      Text(this.title)
        .margin({left: 8, right: 8})
        .layoutWeight(1)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Image('')
        .width(28)
        .height(28)
        .onClick(() => {
          if (this.clickRightBtn) {
            this.clickRightBtn()
          }
        })
    }
    .width(Constants.FULL_SIZE)
    .height(58)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}
