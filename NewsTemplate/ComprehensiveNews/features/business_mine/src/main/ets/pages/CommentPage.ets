import { CircleShape } from '@kit.ArkUI';
import { CommonConstants, loadingPage, TimeUtils } from 'lib_common';
import { emptyBuilder, NavHeaderBar } from 'lib_widget';
import { UniformNewsCard } from '../components/UniformNewsCard';
import { CommentViewModel } from '../viewmodels/CommentVM';
import { AggregateNewsCommentModel } from '../common/ObservedModel';
import { EditCheckbox, HeaderRightPart, ToolBarBottom } from '../components/BaseHistoryComment';

@Builder
export function CommentPageBuilder() {
  CommentPage()
}

@ComponentV2
struct CommentPage {
  @Local vm: CommentViewModel = new CommentViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的评论',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })
        if (this.vm.loadingModel.loading) {
          loadingPage()
        } else if (this.vm.list.length <= 0) {
          Column() {
            emptyBuilder({
              fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            })
          }
          .layoutWeight(1)
        } else {
          Column() {
            List({ space: CommonConstants.SPACE_M }) {
              ForEach(this.vm.list, (v: AggregateNewsCommentModel) => {
                ListItem() {
                  Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                    if (this.vm.isEditMode) {
                      EditCheckbox({
                        onChange: (value) => {
                          this.vm.onChange(value, v);
                        },
                      })
                    }

                    this.contentItemBuilder(v)
                  }
                }
              }, (v: AggregateNewsCommentModel) => v.commentId)
            }
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding,
              top: CommonConstants.SPACE_M,
              bottom: CommonConstants.SPACE_M,
            })

            if (this.vm.isEditMode) {
              this.toolBarBuilder()
            }
          }
          .layoutWeight(1)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  contentItemBuilder(v: AggregateNewsCommentModel) {
    Column({ space: CommonConstants.SPACE_S }) {
      this.commentBuilder(v)
      this.referenceNewsBuilder(v)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .flexShrink(1)
  }

  @Builder
  commentBuilder(v: AggregateNewsCommentModel) {
    Column({ space: CommonConstants.SPACE_S }) {
      Row({ space: CommonConstants.SPACE_S }) {
        Image(v.author.authorIcon)
          .width($r('app.float.medium_img_width'))
          .aspectRatio(1)
          .clipShape(new CircleShape({ width: 16, height: 16 }))
        Text(v.author.authorNickName)
          .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
      }

      Row() {
        Text(v.commentBody)
          .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
      }
      .margin({ left: CommonConstants.PADDING_XXL })

      Row({ space: CommonConstants.SPACE_S }) {
        Text(TimeUtils.getDateDiff(v.createTime))
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
        Text('评论')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
      }
      .margin({ left: CommonConstants.PADDING_XXL })
    }
    .alignItems(HorizontalAlign.Start)
    .accessibilityGroup(true)
  }

  @Builder
  referenceNewsBuilder(v: AggregateNewsCommentModel) {
    Row() {
      Row() {
        UniformNewsCard({
          newsInfo: v.newsDetailInfo,
          customStyle: {
            bodyFg: $r('sys.float.Body_M'),
            bodyFgColor: $r('sys.color.font_secondary'),
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
  }

  @Builder
  rightPartBuilder() {
    HeaderRightPart({ vm: this.vm })
  }

  @Builder
  toolBarBuilder() {
    ToolBarBottom({ vm: this.vm })
  }
}
