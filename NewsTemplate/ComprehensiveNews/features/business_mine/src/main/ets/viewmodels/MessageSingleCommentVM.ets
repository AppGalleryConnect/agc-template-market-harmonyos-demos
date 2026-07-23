import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { CommentModel, MessageServiceApi, MineServiceApi, PublishCommentRequest } from 'lib_news_api';
import { CommentUtils } from 'module_feedcomment';
import { CommentDetailModel } from '../common/ObservedModel';

@ObservedV2
export class MsgSingleCommentListViewModel extends BaseViewModel {
  @Trace replyContent: string = '';
  @Trace currentCommentId: string = '';
  @Trace data: CommentDetailModel | undefined = undefined;
  @Trace publishList: CommentModel[] = [];

  init() {
    this.getParams();
    this.queryList();
  }

  getParams() {
    this.currentCommentId = RouterUtils.getParamByName(RouterMap.MINE_MSG_COMMENT_DETAIL) as string
  }

  queryList() {
    MessageServiceApi.querySingleCommentList(this.currentCommentId).then((resp) => {
      this.data = new CommentDetailModel(resp)
    })
  }

  getRootComment() {
    return this.data?.root;
  }

  getCurrentComment() {
    return this.data?.current;
  }

  getLeftList() {
    return this.data?.list || [];
  }

  publishReply(data: CommentModel, content: string) {
    const params: PublishCommentRequest = {
      newsId: data.newsId,
      content: content,
      parentCommentId: data.commentId,
    };
    MineServiceApi.publishComment(params).then((resp) => {
      this.publishList.push(new CommentModel(resp));
      this.contextModel.showToast({ message: '评论成功' });
    })
  }

  showCommentSheet(data?: CommentModel) {
    if (data) {
      CommentUtils.commentSheetOpen(data.author.authorNickName, (content: string) => {
        this.publishReply(data, content);
      })
    }
  }

  @Computed
  get showAllReply() {
    return this.getLeftList().length > 0;
  }

  @Computed
  get showMyInstantReply() {
    return this.publishList.length > 0;
  }
}