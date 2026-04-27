import { UserInfoModel } from 'lib_common';
import { CommentInfo, Tmp } from '../model/Model';
import { CommentCard } from '../components/CommentCard';
import { FeedCommentVM } from '../viewmodel/FeedCommentVM';
import { CommentEventDispatcher } from '../utils/EventDispatcher';
import { CommentUtils } from '../utils/CommentUtils';

@ComponentV2
export struct FeedComment {
  @Require @Param commentList: CommentInfo[]
  @Param navPathStack: NavPathStack = new NavPathStack()
  @Param fontSizeRatio: number = 1
  @Param isDark: boolean = false
  @Param userInfo: UserInfoModel = new UserInfoModel()
  @Param feedCommentScroller: Scroller = new Scroller()
  @Local feedCommentVM: FeedCommentVM = FeedCommentVM.instance;
  @Event addComment: (commentInfo: CommentInfo, parentCommentId: string) => void = () => {
  };
  @Event giveLike: (commentInfo: CommentInfo, isLike: boolean) => void = () => {
  };
  @Event onGoAuthorInfo: (authorId: string) => void = () => {
  };
  @Event onDeleteComment: (commentId: string) => void = () => {
  };
  @Event onFirstComment: (commentContent: string) => void = () => {
  }
  @BuilderParam commentTopViewBuilder: () => void = this.commentTopView;

  @Monitor('fontSizeRatio')
  fontSizeRatioChange() {
    this.setFontSizeRatio()
  }

  @Monitor('isDark')
  darkChange() {
    this.setDarkMode()
  }

  aboutToAppear(): void {
    this.initDispatch()
    this.feedCommentVM.setUserInfo(this.userInfo)
    this.setFontSizeRatio()
    this.setDarkMode()
  }

  initDispatch() {
    CommentEventDispatcher.addCommentCallback = (commentInfo: CommentInfo, parentCommentId: string) => {
      this.addComment(commentInfo, parentCommentId)
    }
    CommentEventDispatcher.giveLikeCallback = (commentInfo: CommentInfo, isLike: boolean) => {
      this.giveLike(commentInfo, isLike)
    }
    CommentEventDispatcher.goUserHome = (authorId: string) => {
      this.onGoAuthorInfo(authorId)
    }
    CommentEventDispatcher.deleteComment = (commentId: string) => {
      this.onDeleteComment(commentId)
    }
  }

  setFontSizeRatio() {
    this.feedCommentVM.setFontSizeRatio(this.fontSizeRatio)
  }

  setDarkMode() {
    this.feedCommentVM.setIsDark(this.isDark)
  }

  @Builder
  replyComponent(params: Tmp, replyComments: CommentInfo[]) {
    Column() {
      ForEach(params.paramA1?.slice(0, 3), (item: CommentInfo) => {
        ListItem() {
          Column() {
            Column() {
              Column({ space: 8 }) {
                Row() {
                  Text(item.author.authorNickName + ':')
                    .fontSize(12 * this.feedCommentVM.fontSizeRatio).fontColor($r('sys.color.font_primary'))
                    .fontColor($r('app.color.app_theme'))
                    .onClick(() => {
                      CommentEventDispatcher.dispatchToUserHome(item.author.authorId)
                    })
                  Text(item.commentBody)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize(12 * this.feedCommentVM.fontSizeRatio)
                }
              }.width('100%').alignItems(HorizontalAlign.Start)
            }.width('100%').alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 8 })
        }
      }, (item: CommentInfo) => JSON.stringify(item))
      Column() {
        Text() {
          Span('共')
          Span(replyComments.length.toString())
          Span('条回复 >')
        }
        .fontSize(12 * this.feedCommentVM.fontSizeRatio)
        .fontColor($r('app.color.app_theme'))
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .margin({ top: 8 })
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(8)
    .padding(8)
  }

  @Builder
  commentComponent(params: Tmp) {
    ForEach(params.paramA1, (item: CommentInfo) => {
      CommentCard({
        commentInfo: item,
        isDark: this.isDark,
        navPathStack: this.navPathStack,
        replyComponentBuilder: () => {
          this.replyComponent({ paramA1: item.replyComments }, item.replyComments)
        },
      })
    }, (item: CommentInfo) => JSON.stringify(item))
  }

  @Builder
  commentTopView() {
    Text() {
      Span('评论·')
      Span(JSON.stringify(this.commentList?.length))
    }
    .fontSize(18 * this.fontSizeRatio)
    .fontWeight(FontWeight.Bold)
    .fontColor($r('sys.color.font_primary'))
    .width('100%')
    .margin({ top: 16, bottom: 16 })
    .textAlign(TextAlign.Start)
  }

  build() {
    Column() {
      this.commentTopViewBuilder()
      List({ scroller: this.feedCommentScroller }) {
        if (!this.commentList.length) {
          ListItem() {
            Column({ space: 16 }) {
              Text('暂无评论，点击抢首评')
                .fontWeight(FontWeight.Medium)
                .fontSize(16 * this.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
              Button('写评论')
                .fontColor($r('sys.color.font_on_primary'))
                .backgroundColor($r('app.color.app_theme'))
                .padding({
                  top: 6,
                  bottom: 6,
                  left: 16,
                  right: 16,
                })
                .fontSize(16 * this.fontSizeRatio)
                .onClick(() => {
                  CommentUtils.commentSheetOpen(null, (commentContent: string) => {
                    this.onFirstComment(commentContent)
                  })
                })
            }
          }
          .width('100%')
          .height('100%')
        } else {
          this.commentComponent({
            paramA1: this.commentList,
          })
        }
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .padding({ bottom: 16 })
  }
}