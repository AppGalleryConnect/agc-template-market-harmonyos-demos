import { UserInfoModel } from 'lib_common';

@ObservedV2
export class Tmp {
  @Trace paramA1?: ESObject[] = [];
  total?: number = 0;
}

export class AuthorInfo {
  authorId: string = ''
  authorNickName: string = ''
  authorIcon: string = ''
  authorDesc: string = ''
  authorIp: string = ''
  watchersCount: number = 0
  followersCount: number = 0
  likeNum: number = 0

  constructor(userInfo?: UserInfoModel) {
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

@ObservedV2
export class CommentInfo {
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


@ObservedV2
export class MakeObCommentServed extends CommentInfo {
  commentId: string = ''
  newsId: string = ''
  author: AuthorInfo = new AuthorInfo()
  commentBody: string = ''
  replyAuthor: AuthorInfo = new AuthorInfo()
  @Trace commentLikeNum: number = 0
  createTime: number = 0
  @Trace isLiked: boolean = false
  shareCount: number = 0
  @Trace likeCount: number = 0
  @Trace replyComments: CommentInfo[] = []
  isExpand: boolean = false
  parentComment?:CommentInfo

  constructor(value: CommentInfo) {
    super()
    this.commentId = value.commentId
    this.newsId = value.newsId
    this.author = value.author
    this.commentBody = value.commentBody
    this.commentLikeNum = value.commentLikeNum
    this.createTime = value.createTime
    this.isLiked = value.isLiked
    this.likeCount = value.likeCount
    this.replyComments = value.replyComments.map((item) => new MakeObCommentServed(item))
    this.replyAuthor = value?.parentComment?.author ?? new AuthorInfo()
    this.parentComment = value.parentComment ?? undefined
  }
}

export interface BuilderParams {
  reply: () => void
  copy: () => void
  report: () => void
  delete: () => void
  cancel: () => void
  isCommentOwner: boolean
  fontSizeRatio:number
}

export class CommentParams {
  reNickName: string = ''
  callback: (replyContent: string) => void

  constructor(replyAuthor: string | null, callback: (replyContent: string) => void) {
    this.reNickName = replyAuthor ?? ''
    this.callback = callback
  }
}