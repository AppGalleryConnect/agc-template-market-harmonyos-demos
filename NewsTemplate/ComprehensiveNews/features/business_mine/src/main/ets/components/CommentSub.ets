import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { BreakpointModel, CommonConstants, RouterMap, RouterUtils, TimeUtils } from 'lib_common'
import { CommentModel } from 'lib_news_api';

@ComponentV2
export struct CommentSub {
  @Require @Param data: CommentModel;
  @Once @Param bgColor: ResourceColor = Color.Transparent;
  @Param fontSizeRatio: number = 1;
  @Event onReply: () => void = () => {};
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.resetBg();
  }

  resetBg() {
    setTimeout(() => {
      this.bgColor = Color.Transparent;
    }, 1500)
  }

  build() {
    Column({ space: CommonConstants.PADDING_S }) {
      Row() {
        // 评论人
        Row({ space: CommonConstants.SPACE_S }) {
          Image(this.data.author.authorIcon)
            .width($r('app.float.medium_img_width'))
            .aspectRatio(1)
            .clipShape(new CircleShape({ width: 16, height: 16 }))
          Text(this.data.author.authorNickName)
            .fontSize(12 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.data.author.authorId);
        })

        Blank()
        // 评论时间
        Text(TimeUtils.getDateDiff(this.data.createTime))
          .fontSize(10 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width(CommonConstants.FULL_PERCENT)

      // 评论内容
      Row() {
        Text(this.data.commentBody)
          .fontSize(14 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.PADDING_XXL })

      // 引用评论
      Row() {
        Row() {
          Text('@')
            .fontSize(10 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
          Text(this.data.parentComment?.author?.authorNickName)
            .fontSize(10 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
          Text(': ')
            .fontSize(10 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
          Text(this.data.parentComment?.commentBody)
            .fontSize(10 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('app.float.small_radius'))
        .padding(CommonConstants.PADDING_S)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.PADDING_XXL })

      Row({ space: CommonConstants.SPACE_S }) {
        Text('回复')
          .fontSize(10 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_tertiary'))
          .onClick(() => {
            this.onReply();
          })

      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.PADDING_XXL })
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.bgColor)
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
    })
  }
}