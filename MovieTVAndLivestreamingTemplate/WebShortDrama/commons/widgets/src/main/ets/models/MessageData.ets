import { DramaInfo } from '@agctemplate/server'

@ObservedV2
export class CommentData {
  @Trace id: number; // 唯一编号
  @Trace drama: DramaInfo; // 评论对应剧集
  @Trace coverUrl: string; // 剧集封面
  @Trace avatar: string; // 头像
  @Trace name: string; // 昵称
  @Trace commentContent: string; // 评论内容
  @Trace timeAgo: number; // 评论时间（分钟）
  @Trace isLike: boolean; // 是否点赞
  @Trace likeCount: number; // 点赞数量
  @Trace likeList: LikeItem[]; // 点赞列表
  @Trace replyList: Reply[]; // 评论回复列表

  constructor(id: number, drama: DramaInfo, coverUrl: string, avatar: string, name: string, commentContent: string,
    timeAgo: number, isLike: boolean, likeCount: number, likeList: LikeItem[], replyList: Reply[]) {
    this.id = id;
    this.drama = drama;
    this.coverUrl = coverUrl;
    this.avatar = avatar;
    this.name = name;
    this.commentContent = commentContent;
    this.timeAgo = timeAgo;
    this.isLike = isLike;
    this.likeCount = likeCount;
    this.likeList = likeList;
    this.replyList = replyList;
  }
}

@ObservedV2
export class Reply {
  @Trace replyAvatar: string; // 头像
  @Trace replyName: string; // 昵称
  @Trace replyContent: string; // 内容
  @Trace replyTimeAgo: number; // 时间
  @Trace replyIsLike: boolean; // 是否点赞
  @Trace replyLikeCount: number; // 点赞数量
  @Trace replyLikeList: LikeItem[]; // 点赞列表
  @Trace replyPeople: string; // 回复对象昵称
  @Trace replyComment: string; // 回复对应的评论内容

  constructor(replyAvatar: string, replyName: string, replyContent: string, replyTimeAgo: number, replyIsLike: boolean,
    replyLikeCount: number, replyLikeList: LikeItem[], replyPeople: string, replyComment: string) {
    this.replyAvatar = replyAvatar;
    this.replyName = replyName;
    this.replyContent = replyContent;
    this.replyTimeAgo = replyTimeAgo;
    this.replyIsLike = replyIsLike;
    this.replyLikeCount = replyLikeCount;
    this.replyLikeList = replyLikeList;
    this.replyPeople = replyPeople;
    this.replyComment = replyComment;
  }
}

export class LikeItem {
  likeAvatar: string;
  likeName: string;
  likeTime: number;

  constructor(likeAvatar: string, likeName: string, likeTime: number) {
    this.likeAvatar = likeAvatar;
    this.likeName = likeName;
    this.likeTime = likeTime;
  }
}