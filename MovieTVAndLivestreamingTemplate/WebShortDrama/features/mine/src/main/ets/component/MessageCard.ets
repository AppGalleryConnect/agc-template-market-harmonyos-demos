import { FontModel, CommentData, Reply } from '@agctemplate/widgets'
import { AppStorageV2 } from '@kit.ArkUI'

@Preview
@ComponentV2
export struct MessageCard {

  @Param @Require myMessage: CommentData
  @Param @Require reply: Reply
  @Local cardHeight: string | number = 0
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Row() {
      Row() {
        Column() {
          Image(this.reply.replyAvatar)
            .width(this.fontModel.getDesFg(16))
            .aspectRatio(1)
            .borderRadius(8)
        }
        .justifyContent(FlexAlign.Start)
        .height('100%')
        .margin({ right: 8 })

        Column({ space: 8 }) {
          Row() {
            Text(this.reply.replyName)
              .fontSize(this.fontModel.getFg(12))
              .lineHeight(this.fontModel.getDesFg(16))
              .fontColor($r('sys.color.font_secondary'))
            Blank()
            Text(this.reply.replyTimeAgo < 1 ? '刚刚' : (this.reply.replyTimeAgo >= 60 ?
              `${Math.floor(this.reply.replyTimeAgo / 60)}小时前` : `${this.reply.replyTimeAgo}分钟前`))
              .fontSize(this.fontModel.getFg(10))
              .lineHeight(this.fontModel.getDesFg(13))
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width('100%')

          Text('回复你：' + this.reply.replyContent)
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