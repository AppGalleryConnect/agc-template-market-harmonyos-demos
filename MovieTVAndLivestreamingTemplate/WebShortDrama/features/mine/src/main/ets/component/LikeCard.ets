import { FontModel, CommentData, LikeItem } from '@agctemplate/widgets'
import { AppStorageV2 } from '@kit.ArkUI'

@Preview
@ComponentV2
export struct LikeCard {

  @Param @Require myMessage: CommentData
  @Param @Require likeItem: LikeItem
  @Local cardHeight: string | number = 0
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Row() {
      Row() {
        Column() {
          Image(this.likeItem.likeAvatar)
            .width(this.fontModel.getDesFg(16))
            .aspectRatio(1)
            .borderRadius(8)
        }
        .justifyContent(FlexAlign.Start)
        .height('100%')
        .margin({ right: 8 })

        Column({ space: 8 }) {
          Row() {
            Text(this.likeItem.likeName)
              .fontSize(this.fontModel.getFg(12))
              .lineHeight(this.fontModel.getDesFg(16))
              .fontColor($r('sys.color.font_secondary'))
            Blank()
            Text(this.likeItem.likeTime < 1 ? '刚刚' : (this.likeItem.likeTime >= 60 ?
              `${Math.floor(this.likeItem.likeTime / 60)}小时前` : `${this.likeItem.likeTime}分钟前`))
              .fontSize(this.fontModel.getFg(10))
              .lineHeight(this.fontModel.getDesFg(13))
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width('100%')

          Text('赞了你的评论')
            .fontSize(this.fontModel.getFg(14))
            .lineHeight(this.fontModel.getDesFg(19))
            .fontColor($r('sys.color.font_primary'))
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.cardHeight = this.fontModel.getDesFg((Math.ceil(Number(newValue.height) / 19) - 1) * 19 + 115)
            })

          Row({ space: 8 }) {
            Image(this.myMessage.coverUrl)
              .width(36)
              .height(48)

            Text(this.myMessage.commentContent)
              .fontSize(this.fontModel.getFg(12))
              .lineHeight(this.fontModel.getDesFg(16))
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .borderRadius(8)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .alignItems(VerticalAlign.Top)
          .padding(8)
        }
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .layoutWeight(1)
      }
    }
    .height(this.cardHeight)
    .width('100%')
  }
}