import { UIUtils } from '@kit.ArkUI';
import { CommentUtils, FeedComment } from 'module_feedcomment';
import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { CommentResponse, CommentServiceApi, NewsResponse } from 'lib_news_api';
import { MakeObCommentServed, CommentInfo } from 'lib_news_feed_details';
import { CommentViewPageVM } from '../viewmodels/CommentViewPageVM';

@Builder
export function CommentViewPageBuilder() {
  CommentViewPage()
}

@ComponentV2
export struct CommentViewPage {
  @Consumer() navPathStack: NavPathStack = new NavPathStack()
  @Consumer() showKeyboard: boolean = false;
  vm: CommentViewPageVM = new CommentViewPageVM()

  build() {
    NavDestination() {
      Column() {
        Column() {
          FeedComment({
            commentList: this.vm.commentList,
            userInfo: this.vm.getUserInfo(),
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            isDark: this.vm.settingInfo.darkSwitch,
            navPathStack: this.navPathStack,
            commentTopViewBuilder: () => {
              this.commentTopView()
            },
            addComment: (comment: CommentResponse, parentCommentId: string) => {
              this.vm.addSingleComment(comment, parentCommentId)
            },
            onFirstComment: (commentContent: string) => {
              this.vm.addNewsComment(commentContent)
            },
            giveLike: (comment: CommentResponse, isLike: boolean) => {
              this.vm.addLike(comment, isLike)
            },
            onGoAuthorInfo: (authorId: string) => {
              RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
            },
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.PADDING_L,
          right: CommonConstants.PADDING_L,
        })
        .layoutWeight(1)

        Row() {
          Text('发表评论')
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .height(40)
            .borderRadius(24)
            .padding({
              left: CommonConstants.PADDING_M,
              top: CommonConstants.PADDING_S,
              right: CommonConstants.PADDING_M,
              bottom: CommonConstants.PADDING_S,
            })
            .backgroundColor($r('app.color.comment_input_bg'))
            .onClick(() => {
              CommentUtils.commentSheetOpen(null, (commentContent: string) => {
                this.vm.addNewsComment(commentContent)
              })
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          top: CommonConstants.PADDING_S,
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        top: CommonConstants.PADDING_L,
        bottom: this.vm.windowModel.windowBottomPadding,
      })
      .alignItems(HorizontalAlign.Start)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onReady(async (cxt) => {
      const param = cxt.pathInfo.param as NewsResponse;
      this.vm.videoInfo = UIUtils.makeObserved(param);
      let commentInfo = await CommentServiceApi.queryCommentList(this.vm.videoInfo.id) as CommentInfo[]
      this.vm.commentList = commentInfo?.map((value: CommentInfo) => {
        return new MakeObCommentServed(value)
      }) ?? [];
    })
    .onShown(() => {
      if (this.showKeyboard) {
        setTimeout(() => {
          CommentUtils.commentSheetOpen(null, (commentContent: string) => {
            this.vm.addNewsComment(commentContent)
          })
        }, 100)
      }
    })
  }

  @Builder
  commentTopView() {
    Row() {
      Text(this.vm.videoInfo.commentCount + '条评论')
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(700)
        .lineHeight(26)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
    })
  }
}