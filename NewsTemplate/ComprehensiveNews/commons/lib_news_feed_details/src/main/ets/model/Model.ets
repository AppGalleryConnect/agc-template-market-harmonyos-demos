import { UserInfoModel } from 'lib_common'
import { AuthorResponse, CommentResponse, NewsEnum, NewsResponse, PostImgList, VideoEnum } from 'lib_news_api'

export class AuthorInfo implements AuthorResponse {
  // 作者id
  authorId: string = ''
  //作者昵称
  authorNickName: string = ''
  // 作者icon
  authorIcon: string = ''
  //作者简介
  authorDesc: string = ''
  // 作者ip
  authorIp: string = ''
  // 关注的人数
  watchersCount: number = 0
  // 粉丝数量
  followersCount: number = 0
  // 获赞数量
  likeNum: number = 0
  constructor(userInfo?:UserInfoModel) {
    this.authorId = userInfo?.authorId ?? ''
    this.authorNickName = userInfo?.authorNickName ?? ''
    this.authorIcon = userInfo?.authorIcon ?? ''
    this.authorDesc = userInfo?.authorDesc ?? ''
    this.authorIp = userInfo?.authorIp ?? ''
    this.watchersCount = userInfo?.watchersCount ?? 0
    this.followersCount = userInfo?.followersCount ?? 0
    this.likeNum = userInfo?.likeNum ?? 0
  }
}

export class KeyWordPair {
  keyword: string = ''
  explain: string = ''
}

export class QuestionAndAnswer {
  question: string = ''
  answer: string = ''
}

@ObservedV2
export class NewsFeedInfo implements NewsResponse {
  // 内容id
  id: string = '';
  // 新闻类型
  type: NewsEnum = NewsEnum.Article;
  // 标题
  title: string = '';
  // 作者
  author: AuthorInfo = new AuthorInfo();
  // 创建时间
  createTime: number = 0;
  // 相对时间
  relativeTime: string = '';
  // 评论列表
  @Trace comments: CommentResponse[] = [];
  // 收藏数量
  markCount: number = 0;
  // 评论数量
  commentCount: number = 0;
  // 点赞数量
  likeCount: number = 0;
  // 分享数量
  shareCount: number = 0;
  // 是否被点赞
  isLiked: boolean = false;
  // 是否被收藏
  isMarked: boolean = false;
  // 富文本
  @Trace richContent?: string = '';
  // 相关推荐
  recommends?: NewsFeedInfo[] = [];
  // 视频url
  videoUrl: string = '';
  // 封面图
  coverImg: string = '';
  // 视频类型
  videoType: VideoEnum = VideoEnum.Portrait;
  // 正文
  postBody: string = '';
  // 图片链接
  postImgList: PostImgList[] = [];
  publishTime: string = '';
  questionAndAnswer: QuestionAndAnswer = new QuestionAndAnswer();
  keywordPairs: KeyWordPair[] = [];
}


@ObservedV2
export class CommentInfo implements CommentResponse {
  commentId: string = ''
  newsId: string = ''
  parentComment?: CommentInfo
  author: AuthorInfo = new AuthorInfo()
  commentBody: string = ''
  commentLikeNum: number = 0
  createTime: number = 0
  @Trace isLiked: boolean = false
  @Trace likeCount: number = 0
  @Trace replyComments: CommentInfo[] = []
}
