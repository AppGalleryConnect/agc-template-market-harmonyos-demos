import { CommonConstants, CommonDataSource, FormatCount, NewsEnum } from 'lib_common';
import { MineServiceApi, NewsResponse, PublishCommentRequest } from 'lib_news_api';
import { MakeObCommentServed, CommentInfo } from 'lib_news_feed_details';
import { Share } from 'lib_widget';
import { CommentUtils } from 'module_feedcomment';
import { LivestreamFooterViewVM } from '../viewmodels/LivestreamFooterViewVM';
import { LivestreamCommentListScroller } from '../views/LiveCommentView';

@ComponentV2
export struct LivestreamFooterView {
  @Param livestreamInfo: NewsResponse = {} as NewsResponse;
  @Param commentListScroller: LivestreamCommentListScroller = new LivestreamCommentListScroller();
  @Consumer() commentListDataSource: CommonDataSource<CommentInfo> = new CommonDataSource<CommentInfo>();
  vm: LivestreamFooterViewVM = new LivestreamFooterViewVM();

  aboutToAppear(): void {
    this.vm.livestreamInfo = this.livestreamInfo;
    this.vm.commentListScroller = this.commentListScroller
  }

  async addNewsComment(commentContent: string) {
    this.livestreamInfo.commentCount++
    const params: PublishCommentRequest = {
      newsId: this.livestreamInfo.id,
      content: commentContent,
      parentCommentId: '',
    };
    let addComment = await MineServiceApi.publishComment(params) as CommentInfo

    this.commentListDataSource.pushData(new MakeObCommentServed(addComment))
    if (this.commentListScroller.scroller) {
      let index = this.commentListDataSource.totalCount() - 1
      this.commentListScroller.scroller.scrollToIndex(index, true)
    }
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text('发表评论')
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .width('60%')
        .flexGrow(1)
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
            this.addNewsComment(commentContent)
          })
        })

      Row() {
        Share({
          shareData: {
            recordId: this.vm.livestreamInfo.id,
            title: this.vm.livestreamInfo.title,
            subTitle: this.vm.livestreamInfo.author?.authorNickName,
            createTime: this.vm.livestreamInfo.createTime,
            coverUrl: this.vm.handlerCoverImage(this.vm.livestreamInfo),
            type: NewsEnum.Video,
          },
          shareRenderBuilder: () => {
            this.shareBuilder()
          },
        })

        Column({ space: 5 }) {
          Image(this.vm.livestreamInfo.isLiked ? $r('app.media.ic_like') : $r('app.media.ic_unlike'))
            .width(22)
            .height(20)
            .fillColor(
              this.vm.livestreamInfo.isLiked ? $r('sys.color.warning') : $r('sys.color.font_primary'),
            )

          Text(FormatCount.formatNumberToW(this.vm.livestreamInfo.likeCount))
            .fontSize(10)
            .fontColor(this.vm.livestreamInfo.isLiked ? $r('sys.color.warning') : $r('sys.color.font_primary'))
        }
        .onClick(() => {
          this.vm.likeAction()
        })
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: CommonConstants.PADDING_S,
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
      bottom: this.vm.windowModel.windowBottomPadding,
    })
  }

  @Builder
  shareBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.share_active'))
        .width(21)
        .height(21)
        .fillColor($r('sys.color.font_primary'))
      Text(FormatCount.formatToK(this.vm.livestreamInfo.shareCount))
        .fontSize(10 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
    }
  }
}