export enum NewsEnum {
  /**
   * 文章
   */
  Article = 0,
  /**
   * 视频
   */
  Video,
  /**
   * 动态
   */
  Post,
  /**
   * 广播
   */
  Broadcast,
  /**
   * 电视
   */
  Television
}

@ObservedV2
export class AuthorInfo {
  // 作者id
  authorId: string = ''
  //作者昵称
  @Trace authorNickName: string = ''
  // 作者icon
  @Trace authorIcon: string = ''
  //作者简介
  @Trace authorDesc: string = ''
  // 作者ip
  authorIp: string = ''
  // 关注的人数
  watchersCount: number = 0
  // 粉丝数量
  followersCount: number = 0
  // 获赞数量
  likeNum: number = 0

  constructor(author?: AuthorInfo) {
    this.authorId = author?.authorId ?? ''
    this.authorNickName = author?.authorNickName ?? ''
    this.authorIcon = author?.authorIcon ?? ''
    this.authorDesc = author?.authorDesc ?? ''
    this.authorIp = author?.authorIp ?? ''
    this.watchersCount = author?.watchersCount ?? 0
    this.followersCount = author?.followersCount ?? 0
    this.likeNum = author?.likeNum ?? 0
  }
}

export interface CommentModel {
  // 评论id
  commentId: string
  // 从属新闻id
  newsId: string
  // 评论的作者
  author: AuthorInfo
  // 评论的内容
  commentBody: string
  replyAuthor?: AuthorInfo
  // 评论被点赞数量
  commentLikeNum: number
  // 评论时间
  createTime: number
  // 是否被我点赞
  isLiked: boolean
  // 被回复的评论列表
  replyComments: CommentModel[]
}

@ObservedV2
export class FeedCardInfoModel {
  id: string = ''
  type: NewsEnum = NewsEnum.Article
  title: string = ''
  author: AuthorInfo = new AuthorInfo()
  createTime: number = 0
  comments: CommentModel[] = []
  @Trace commentCount: number = 0
  @Trace markCount: number = 0
  @Trace likeCount: number = 0
  @Trace shareCount: number = 0
  @Trace isLiked: boolean = false
  @Trace isMarked: boolean = false
  @Trace relativeTime?:string = ''
  richContent?: string
  videoUrl?: string
  coverUrl?: string
  videoDuration?: number
  postBody?: string
  postImgList?: PostImgList[] = []
  totalCount?: number
  isWatch?: boolean = false
  city?: string = ''

  constructor(value?: FeedCardInfoModel) {
    this.id = value?.id ?? ''
    this.type = value?.type ?? 0
    this.author = new AuthorInfo(value?.author)
    this.createTime = value?.createTime ?? 0
    this.comments = value?.comments ?? []
    this.likeCount = value?.likeCount ?? 0
    this.commentCount = value?.commentCount ?? 0
    this.markCount = value?.markCount ?? 0
    this.shareCount = value?.shareCount ?? 0
    this.isLiked = value?.isLiked ?? false
    this.title = value?.title ?? ''
    this.isMarked = value?.isMarked ?? false
    this.postImgList = value?.postImgList ?? []
    this.isWatch = value?.isWatch ?? false
    this.relativeTime = value?.relativeTime ?? ''
    this.city = value?.city ?? ''
  }
}

export class PostImgList {
  picVideoUrl: string = ''
  movingVideoUrl?: string = ''
  id?: string = ''
  surfaceUrl: string = ''
  type?: number = 0
  essayId?: string = ''
}