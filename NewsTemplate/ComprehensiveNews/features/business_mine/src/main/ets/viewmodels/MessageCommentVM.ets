import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { MessageServiceApi, MineServiceApi, PublishCommentRequest } from 'lib_news_api';
import { CommentUtils } from 'module_feedcomment';
import { AggregateNewsCommentModel } from '../common/ObservedModel';

@ObservedV2
export class MsgCommentViewModel extends BaseViewModel {
  @Trace list: AggregateNewsCommentModel[] = [];
  @Trace loading: boolean = false;

  constructor() {
    super();
    this.queryList();
    this.setAllRead();
  }

  queryList() {
    MessageServiceApi.queryCommentReplyList().then((resp) => {
      this.list = resp.map(v => new AggregateNewsCommentModel(v));
      this.loading = false;
    })
  }

  replyComment(v: AggregateNewsCommentModel) {
    CommentUtils.commentSheetOpen(v.author.authorNickName, (content: string) => {
      this.publishReply(v, content);
    })
  }

  jumpProfile(v: AggregateNewsCommentModel) {
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, v.author.authorId);
  }

  jumpMoreComment(v: AggregateNewsCommentModel) {
    RouterUtils.pushPathByName(RouterMap.MINE_MSG_COMMENT_DETAIL, v.commentId);
  }

  publishReply(data: AggregateNewsCommentModel, content: string) {
    const params: PublishCommentRequest = {
      newsId: data.newsId,
      content: content,
      parentCommentId: data.commentId,
    };
    MineServiceApi.publishComment(params).then(() => {
      this.contextModel.showToast({ message: '评论成功' });
    })
  }

  // 区分评论/回复
  isReply(v: AggregateNewsCommentModel) {
    return v.parentCommentId;
  }

  onRefresh() {
    this.queryList();
  }

  setAllRead() {
    MessageServiceApi.setReplyRead();
  }

  onBackPressed() {
    RouterUtils.pop('1');
    return true;
  }
}