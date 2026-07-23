import {
  AggregateNewsComment,
  AuthorModel,
  AuthorResponse,
  BriefIMResponse,
  ChatInfoDetailResponse,
  CommentDetailResponse,
  CommentModel,
  CommentResponse,
  NewsModel,
  SystemDetailInfo,
} from 'lib_news_api';

@ObservedV2
export class AggregateNewsCommentModel {
  @Trace commentId: string
  @Trace parentCommentId?: string
  @Trace parentComment?: CommentResponse
  @Trace newsId: string
  @Trace newsDetailInfo: NewsModel
  @Trace author: AuthorResponse
  @Trace commentBody: string
  @Trace commentLikeNum: number
  @Trace createTime: number
  @Trace isLiked: boolean
  @Trace replyComments: CommentResponse[]

  constructor(v: AggregateNewsComment) {
    this.commentId = v.commentId;
    this.parentCommentId = v.parentCommentId;
    this.parentComment = v.parentComment;
    this.newsId = v.newsId;
    this.newsDetailInfo = new NewsModel(v.newsDetailInfo);
    this.author = v.author;
    this.commentBody = v.commentBody;
    this.commentLikeNum = v.commentLikeNum;
    this.createTime = v.createTime;
    this.isLiked = v.isLiked;
    this.replyComments = v.replyComments;
  }
}

@ObservedV2
export class CommentDetailModel implements CommentDetailResponse {
  @Trace root: AggregateNewsCommentModel
  @Trace current: CommentModel | undefined
  @Trace list: CommentModel[]

  constructor(v: CommentDetailResponse) {
    this.root = new AggregateNewsCommentModel(v.root);
    if (v.current) {
      this.current = new CommentModel(v.current);
    }
    this.list = v.list;
  }
}

@ObservedV2
export class BriefIMModel implements BriefIMResponse {
  @Trace chatAuthor: AuthorModel
  @Trace allUnreadCount: number
  @Trace receiveTime: number
  @Trace latestNews: string
  @Trace chatList: ChatInfoDetailModel[]

  constructor(v: BriefIMResponse) {
    this.chatAuthor = new AuthorModel(v.chatAuthor);
    this.allUnreadCount = v.allUnreadCount;
    this.receiveTime = v.receiveTime;
    this.latestNews = v.latestNews;
    this.chatList = [];
  }
}

@ObservedV2
export class SystemMessageInfo implements SystemDetailInfo {
  @Trace content: string
  @Trace createTime: number

  constructor(v: SystemDetailInfo) {
    this.content = v.content;
    this.createTime = v.createTime;
  }
}

@ObservedV2
export class ChatInfoDetailModel implements ChatInfoDetailResponse {
  @Trace type: string;
  @Trace content: string;
  @Trace isMyself?: boolean;
  @Trace createTime?: number

  constructor(v: ChatInfoDetailResponse) {
    this.type = v.type;
    this.content = v.content;
    this.isMyself = v.isMyself;
    this.createTime = v.createTime
  }
}