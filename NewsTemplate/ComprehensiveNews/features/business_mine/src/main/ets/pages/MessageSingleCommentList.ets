import { CommonConstants } from 'lib_common';
import { CommentModel } from 'lib_news_api';
import { NavHeaderBar } from 'lib_widget';
import { CommentRoot } from '../components/CommentRoot';
import { CommentSub } from '../components/CommentSub';
import { MsgSingleCommentListViewModel } from '../viewmodels/MessageSingleCommentVM';

@Builder
export function MsgSingleCommentListBuilder() {
  MsgSingleCommentList()
}

@ComponentV2
struct MsgSingleCommentList {
  @Local vm: MsgSingleCommentListViewModel = new MsgSingleCommentListViewModel();

  aboutToAppear(): void {
    this.vm.init();
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '全部回复',
      })
      Scroll() {
        Column() {
          Column() {
            if (this.vm.getRootComment()) {
              CommentRoot({
                data: this.vm.getRootComment(),
                fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                onReply: () => {
                  this.vm.showCommentSheet(this.vm.getRootComment() as CommentModel);
                },
              })
            }

            if (this.vm.getCurrentComment()) {
              CommentSub({
                data: this.vm.getCurrentComment(),
                fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                onReply: () => {
                  this.vm.showCommentSheet(this.vm.getCurrentComment());
                },
              })
            }

            if (this.vm.showMyInstantReply) {
              Column() {
                ForEach(this.vm.publishList, (v: CommentModel) => {
                  CommentSub({
                    data: v,
                    bgColor: $r('app.color.my_instant_reply_bg'),
                    fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                    onReply: () => {
                      this.vm.showCommentSheet(v);
                    },
                  })
                }, (v: CommentModel) => v.commentId)
              }
            }
          }
          .alignItems(HorizontalAlign.Start)
          .padding({
            top: CommonConstants.PADDING_S,
            bottom: CommonConstants.PADDING_M,
          })

          Column() {
            this.subAreaStartBuilder()
            Column() {
              ForEach(this.vm.getLeftList(), (v: CommentModel) => {
                CommentSub({
                  data: v,
                  fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                  onReply: () => {
                    this.vm.showCommentSheet(v);
                  },
                })
              }, (v: CommentModel) => v.commentId)
            }
          }
          .alignItems(HorizontalAlign.Start)
          .visibility(this.vm.showAllReply ? Visibility.Visible : Visibility.None)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .padding({
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  subAreaStartBuilder() {
    Divider()
      .strokeWidth(8)
      .width(CommonConstants.FULL_PERCENT)
      .color($r('sys.color.comp_background_tertiary'))
    Text('全部回复')
      .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .height(48)
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
      })
  }
}