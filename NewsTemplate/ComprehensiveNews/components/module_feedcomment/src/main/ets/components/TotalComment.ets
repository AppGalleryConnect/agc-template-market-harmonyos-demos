import { NavHeaderBar } from 'lib_widget';
import { CommentInfo } from '../model/Model';
import { CommentUtils } from '../utils/CommentUtils';
import { FeedCommentVM } from '../viewmodel/FeedCommentVM';
import { CommentCard } from './CommentCard';

@Builder
export function totalCommentBuilder() {
  TotalComment()
}

@ComponentV2
export struct TotalComment {
  @Local commentInfo: CommentInfo = new CommentInfo()
  @Local feedCommentVM: FeedCommentVM = FeedCommentVM.instance;
  @Local navPathStack: NavPathStack = new NavPathStack()

  @Builder
  commentBuilder(item: CommentInfo, needPadding = true) {
    ForEach(item.replyComments, (value: CommentInfo) => {
      ListItem() {
        CommentCard({
          commentInfo: value,
          isNeedReply: true,
          isDark:this.feedCommentVM.isDark,
          articleInfo: this.commentInfo,
          totalCommentBuilder: () => {
            this.commentBuilder(value, false)
          },
          onDeleteComment:(commentId:string) => {
            let commentIndex =  item.replyComments.findIndex(v => v.commentId === commentId)
            if(commentIndex !== -1) {
              item.replyComments.splice(commentIndex,1)
            }
          }
        })
      }
      .padding({ left: needPadding ? 16 : 0, right: needPadding ? 16 : 0 })
    }, (item: CommentInfo) => JSON.stringify(item))
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: `共${this.commentInfo.replyComments.length}条回复`,
        onBack: () => {
          this.navPathStack.pop()
        },
      })
      Row().backgroundColor($r('sys.color.background_secondary')).width('100%').height(8)
      Column() {
        List() {
          ListItem() {
            CommentCard({
              isDark:this.feedCommentVM.isDark,
              commentInfo: this.commentInfo,
            })
          }
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8,
          })

          ListItem() {
            Row().backgroundColor($r('sys.color.background_secondary')).width('100%').height(8)
          }

          ListItem() {
            Text('全部回复')
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8,
          })

          this.commentBuilder(this.commentInfo)
        }
        .scrollBar(BarState.Off)
        .padding({
          top: 8,
          bottom: 8,
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Row() {
          Text('回复')
            .fontColor($r('sys.color.font_secondary'))
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .height(40)
        .justifyContent(FlexAlign.Start)
        .borderRadius(24)
        .padding({ left: 16 })
        .margin({ bottom: 32 })
        .width('100%')
      }
      .onClick(() => {
        CommentUtils.commentSheetOpen(this.commentInfo.author.authorNickName, (replyContent: string) => {
          this.feedCommentVM.addComment(this.commentInfo, replyContent)
        })
      })
      .backgroundColor($r('sys.color.background_primary'))
      .padding({ left: 16, right: 16, top: 16 })
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.navPathStack = ctx.pathStack
      this.commentInfo = ctx.pathStack.getParamByName('TotalComment')[0] as CommentInfo
    })
  }
}