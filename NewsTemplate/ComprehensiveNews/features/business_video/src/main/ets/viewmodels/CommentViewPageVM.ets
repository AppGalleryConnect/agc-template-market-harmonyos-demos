import { LoginSheetUtils } from 'lib_account';
import { BaseViewModel } from 'lib_common';
import { CommentResponse, CommentServiceApi, MineServiceApi, NewsResponse, PublishCommentRequest } from 'lib_news_api';
import { MakeObCommentServed, CommentInfo } from 'lib_news_feed_details';

@ObservedV2
export class CommentViewPageVM extends BaseViewModel {
  // 当前视频信息
  @Trace videoInfo: NewsResponse = {} as NewsResponse;
  // 评论
  @Trace commentList: CommentInfo[] = [];

  getUserInfo() {
    return this.userInfoModel
  }

  public addSingleComment(comment: CommentResponse, parentCommentId: string) {
    const params: PublishCommentRequest = {
      newsId: comment.newsId,
      content: comment.commentBody,
      parentCommentId: parentCommentId,
    };
    MineServiceApi.publishComment(params)
  }

  public async addNewsComment(commentContent: string) {
    this.videoInfo.commentCount++
    const params: PublishCommentRequest = {
      newsId: this.videoInfo.id,
      content: commentContent,
      parentCommentId: '',
    };
    let addComment = await MineServiceApi.publishComment(params) as CommentInfo
    this.commentList.unshift(new MakeObCommentServed(addComment))
  }

  // 点赞评论
  public addLike(comment: CommentResponse, isLike: boolean) {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    this.setCommentInfo(this.commentList, comment, isLike)
    if (comment.isLiked) {
      CommentServiceApi.addCommentLike(comment.commentId)
      return
    }
    CommentServiceApi.cancelCommentLike(comment.commentId)
  }

  public setCommentInfo(commentInfoList: CommentInfo[], comment: CommentResponse, isLike: boolean) {
    if (commentInfoList.length) {
      commentInfoList.forEach(item => {
        if (item.commentId === comment.commentId) {
          item.isLiked = isLike
          item.commentLikeNum = isLike ? item.commentLikeNum + 1 : item.commentLikeNum - 1
        }
        this.setCommentInfo(item.replyComments, comment, isLike)
      })
    }
  }
}