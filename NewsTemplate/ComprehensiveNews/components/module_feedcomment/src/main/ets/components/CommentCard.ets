import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { CommonConstants, CommonSelectDialog, GlobalContextUtils, Logger, PopViewUtils, TimeUtils } from 'lib_common'
import { BuilderParams, CommentInfo } from '../model/Model'
import { CommentUtils } from '../utils/CommentUtils'
import { CommentEventDispatcher } from '../utils/EventDispatcher'
import { FeedCommentVM } from '../viewmodel/FeedCommentVM'
import { confirmDialogView } from './PressAction'

const TAG = '[CommentCard]';

@ComponentV2
export struct CommentCard {
  @Require @Param commentInfo: CommentInfo
  @Param articleInfo: CommentInfo = new CommentInfo()
  @Param navPathStack: NavPathStack = new NavPathStack()
  @Param isDark: boolean = false
  @Param isNeedReply: boolean = false
  @BuilderParam replyComponentBuilder: () => void;
  @BuilderParam totalCommentBuilder: () => void;
  @Event onDeleteComment: (commentId: string) => void = () => {
  }
  @Local feedCommentVM: FeedCommentVM = FeedCommentVM.instance;
  private customDialogComponentId: number = 0

  @Computed
  get getDarkLike() {
    return this.isDark ? $r('app.media.give_like_dark') : $r('app.media.give_like')
  }

  @Builder
  customDialogComponent() {
    Column() {
      Text('确定删除此评论？')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Row() {
        Button('取消')
          .width(CommonConstants.HALF_PERCENT)
          .height(40)
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              Logger.error(TAG, 'closeCustomDialog fail, error: ' + JSON.stringify(error));
            }
          })
        Button('删除')
          .width(CommonConstants.HALF_PERCENT)
          .height(40)
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .fontColor($r('sys.color.warning'))
          .onClick(() => {
            this.onDeleteComment(this.commentInfo.commentId)
            CommentEventDispatcher.dispatchToDeleteComment(this.commentInfo.commentId)
            PopViewUtils.closePopView()
            try {
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              Logger.error(TAG, 'closeCustomDialog fail, error: ' + JSON.stringify(error));
            }
          })
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(120)
    .padding({
      top: 24,
      bottom: 16,
      left: 24,
      right: 24,
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Computed
  get isReplyShow() {
    return this.commentInfo.parentComment?.author?.authorNickName && this.isNeedReply &&
      this.commentInfo.parentComment.author.authorNickName !== this.articleInfo.author.authorNickName
  }

  pressReply = () => {
    PopViewUtils.closePopView()
    CommentUtils.commentSheetOpen(this.commentInfo.author.authorNickName, (replyContent: string) => {
      this.feedCommentVM.addComment(this.commentInfo, replyContent)
    })
  }
  pressCopy = () => {
    PopViewUtils.closePopView()
    try {
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.commentInfo.commentBody);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setDataSync(pasteboardData);
      GlobalContextUtils.showToast({ message: '已复制评论' });
    } catch (e) {
      Logger.error(TAG, 'Fail to copy to pasteboard, error: ' + JSON.stringify(e));
    }
  }
  pressReport = () => {
    PopViewUtils.closePopView()
    CommonSelectDialog.show({
      list: ['淫秽色情', '营销广告', '网络暴力', '违法信息', '虚假谣言', '养老诈骗'],
      submit: () => {
        PopViewUtils.closePopView()
        GlobalContextUtils.showToast({ message: '已举报该评论' });
      },
      cancel: () => {
        PopViewUtils.closePopView()
      },
    })
  }
  pressDelete = () => {
    PopViewUtils.closePopView()
    this.getUIContext()
      .getPromptAction()
      .openCustomDialog({
        builder: () => {
          this.customDialogComponent()
        },
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          if (dismissDialogAction.reason !== DismissReason.TOUCH_OUTSIDE) {
            dismissDialogAction.dismiss()
          }
        },
      })
      .then((dialogId: number) => {
        this.customDialogComponentId = dialogId
      })
      .catch((e: BusinessError) => {
        Logger.error(TAG, 'openCustomDialog fail, error: ' + JSON.stringify(e))
      })
  }

  pressCancel() {
    PopViewUtils.closePopView()
  }

  build() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image(this.commentInfo.author.authorIcon || $r('app.media.icon_default'))
              .width(32)
              .height(32)
              .borderRadius('50%')
              .clip(true)
              .accessibilityText(this.commentInfo.author.authorNickName + '头像')
              .onClick(() => {
                CommentEventDispatcher.dispatchToUserHome(this.commentInfo.author.authorId)
              })
          }

          Text(this.commentInfo.author.authorNickName)
            .fontColor($r('sys.color.font_secondary')).fontSize(12 * this.feedCommentVM.fontSizeRatio)
        }.width('100%').justifyContent(FlexAlign.Start)
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Column({ space: 8 }) {
          Row() {
            Row() {
              Text() {
                Span('回复').fontColor($r('sys.color.font_secondary'))
                Span(`@${this.commentInfo.parentComment?.author?.authorNickName}:`)
                  .fontColor($r('app.color.app_theme'))
                  .onClick(() => {
                    const authorId: string = this.commentInfo.parentComment?.author?.authorId as string
                    CommentEventDispatcher.dispatchToUserHome(authorId);
                  })
              }
              .fontSize(14 * this.feedCommentVM.fontSizeRatio)
              .visibility(this.isReplyShow ? Visibility.Visible : Visibility.None)

              Text(this.commentInfo.commentBody).fontColor($r('app.color.common_title_font'))
                .fontColor($r('sys.color.font_primary')).fontSize(14 * this.feedCommentVM.fontSizeRatio)
            }
            .accessibilityGroup(true)
          }
          .onClick(() => {
            CommentUtils.commentSheetOpen(this.commentInfo.author.authorNickName, (replyContent: string) => {
              this.feedCommentVM.addComment(this.commentInfo, replyContent)
            })
          })


          Row() {
            Row({ space: 16 }) {
              Text(TimeUtils.formatDate(this.commentInfo.createTime))
                .fontSize(10 * this.feedCommentVM.fontSizeRatio)
                .fontColor($r('sys.color.font_secondary'))
              Text('回复')
                .fontSize(10 * this.feedCommentVM.fontSizeRatio)
                .fontColor($r('app.color.app_theme'))
                .onClick(() => {
                  CommentUtils.commentSheetOpen(this.commentInfo.author.authorNickName, (replyContent: string) => {
                    this.feedCommentVM.addComment(this.commentInfo, replyContent)
                  })
                })
            }

            Row({ space: 5 }) {
              Image(this.commentInfo.isLiked ? $r('app.media.give_like_active') : this.getDarkLike)
                .width(16)
                .height(14)
              Text(`${this.commentInfo.commentLikeNum}`)
                .fontSize(10 * this.feedCommentVM.fontSizeRatio)
                .fontColor($r('sys.color.font_secondary'))
            }
            .accessibilityText('点赞' + this.commentInfo.commentLikeNum)
            .onClick(() => {
              this.feedCommentVM.giveLike(this.commentInfo, !this.commentInfo.isLiked)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 9 })

          if (this.replyComponentBuilder) {
            Column() {
              this.replyComponentBuilder()
            }
            .onClick(() => {
              this.navPathStack.pushPathByName('TotalComment', this.commentInfo)
            })
            .visibility(this.commentInfo.replyComments?.length ?
              Visibility.Visible :
              Visibility.None)
          }
        }.width('100%').alignItems(HorizontalAlign.Start)
        .gesture(
          // 评论长按拉起交互面板
          LongPressGesture({ repeat: false })
            .onAction(() => {
              const builderParams: BuilderParams = {
                reply: this.pressReply,
                copy: this.pressCopy,
                report: this.pressReport,
                delete: this.pressDelete,
                cancel: this.pressCancel,
                isCommentOwner: this.commentInfo.author.authorId === this.feedCommentVM.userInfo.authorId,
                fontSizeRatio: this.feedCommentVM.fontSizeRatio,
              }
              PopViewUtils.showPopView<BuilderParams>(wrapBuilder(confirmDialogView), {
                alignment: DialogAlignment.Center,
              }, builderParams)
            }),
        )
      }.width('100%').alignItems(HorizontalAlign.Start).padding({ left: 42 })

      if (this.totalCommentBuilder) {
        Column() {
          this.totalCommentBuilder()
        }
        .visibility(this.commentInfo.replyComments?.length ?
          Visibility.Visible :
          Visibility.None)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 8 })
  }
}