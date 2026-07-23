import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { BreakpointModel, CommonConstants, RouterMap, RouterUtils, TimeUtils } from 'lib_common'
import { AggregateNewsCommentModel } from '../common/ObservedModel'
import { UniformNewsCard } from './UniformNewsCard'

@ComponentV2
export struct CommentRoot {
  @Require @Param data: AggregateNewsCommentModel;
  @Param fontSizeRatio: number = 1;
  @Event onReply: () => void = () => {};
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column({ space: CommonConstants.PADDING_S }) {
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

      // 评论内容
      Row() {
        Text(this.data.commentBody)
          .fontSize(14 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.PADDING_XXL })

      // 评论时间
      Row({ space: CommonConstants.SPACE_S }) {
        Text(TimeUtils.getDateDiff(this.data.createTime))
          .fontSize(10 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.PADDING_XXL })

      // 引用新闻
      Row() {
        Row() {
          UniformNewsCard({
            newsInfo: this.data.newsDetailInfo,
            customStyle: {
              bodyFg: 12 * this.fontSizeRatio,
              bodyFgColor: $r('sys.color.font_secondary'),
              imgRatio: 2,
            },
            showAuthorInfoBottom: false,
          })
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
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
    })
  }
}