import { CommonUtils } from '../common/Utils'
import { SimpleGoodInfo } from '../model/Model'

@ComponentV2
export struct UIOrderPart {
  @Param goodInfo: SimpleGoodInfo = new SimpleGoodInfo();

  build() {
    Row({ space: 8 }) {
      Image(CommonUtils.handleImgUrl(this.goodInfo.image)).width(86).aspectRatio(1).borderRadius(8)
      Column() {
        Text(this.goodInfo.title)
          .fontSize(14)
          .fontWeight(500)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.goodInfo.subTitle ?? '随时退·过期自动退')
          .fontSize(12)
          .fontWeight(400)
          .margin({ top: 8 })
        Blank()
        Row() {
          Text('￥' + CommonUtils.handleCash(this.goodInfo.vipPrice)).fontColor('#E84026').fontSize(14).fontWeight(500)
          Blank()
          Text('实付款 ￥' + CommonUtils.handleCash(this.goodInfo.vipPrice)).fontSize(12)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .height(86)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
