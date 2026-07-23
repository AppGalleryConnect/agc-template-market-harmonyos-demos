import { CircleShape } from '@kit.ArkUI';
import { CommonConstants, TimeUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AggregateNewsCommentModel } from '../common/ObservedModel';
import { UniformNewsCard } from '../components/UniformNewsCard';
import { MsgCommentViewModel } from '../viewmodels/MessageCommentVM';

@Builder
export function MsgCommentListPageBuilder() {
  MsgCommentReplyPage()
}

@ComponentV2
struct MsgCommentReplyPage {
  @Local vm: MsgCommentViewModel = new MsgCommentViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '评论与回复',
          onBack: () => {
            this.vm.onBackPressed();
          },
        })
        Refresh({ refreshing: $$this.vm.loading }) {
          List({ space: CommonConstants.SPACE_L }) {
            ForEach(this.vm.list, (v: AggregateNewsCommentModel) => {
              ListItem() {
                this.mainItemBuilder(v)
              }
            }, (v: AggregateNewsCommentModel) => v.commentId + v.newsId)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
            top: CommonConstants.SPACE_S,
            bottom: this.vm.windowModel.windowBottomPadding,
          })
        }
        .layoutWeight(1)
        .accessibilityLevel('no')
        .onRefreshing(() => {
          this.vm.onRefresh();
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  mainItemBuilder(v: AggregateNewsCommentModel) {
    Column({ space: CommonConstants.SPACE_S }) {
      this.topUserBuilder(v)
      this.middleCommentBuilder(v)
      this.referenceNewsBuilder(v)
      this.replyBtnBuilder(v)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  topUserBuilder(v: AggregateNewsCommentModel) {
    Row({ space: CommonConstants.SPACE_XS }) {
      Image(v.author.authorIcon)
        .width($r('app.float.medium_img_width'))
        .aspectRatio(1)
        .clipShape(new CircleShape({ width: 16, height: 16 }))
      Text(v.author.authorNickName)
        .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_secondary'))

      Blank()

      Text(TimeUtils.handleMsgTimeDiff(v.createTime))
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .onClick(() => {
      this.vm.jumpProfile(v);
    })
  }

  @Builder
  middleCommentBuilder(v: AggregateNewsCommentModel) {
    Column({ space: CommonConstants.SPACE_S }) {
      // 评论/回复内容
      Row() {
        Text() {
          Span(this.vm.isReply(v) ? '回复你: ' : '评论你: ')
          Span(v.commentBody)
        }
        .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
      }

      // 回复的评论引用
      Row() {
        Text(v.parentComment?.commentBody)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
      }
      .visibility(true ? Visibility.Visible : Visibility.None)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: CommonConstants.PADDING_XXL,
    })
    .onClick(() => {
      this.vm.jumpMoreComment(v);
    })
  }

  @Builder
  referenceNewsBuilder(v: AggregateNewsCommentModel) {
    Row() {
      Row() {
        UniformNewsCard({
          newsInfo: v.newsDetailInfo,
          customStyle: {
            bodyFg: $r('sys.float.Body_S'),
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
    .padding({
      left: CommonConstants.PADDING_XXL,
    })
  }

  @Builder
  replyBtnBuilder(v: AggregateNewsCommentModel) {
    Row() {
      Text('回复')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .onClick(() => {
          this.vm.replyComment(v);
        })
    }
    .padding({
      left: CommonConstants.PADDING_XXL,
    })
  }
}