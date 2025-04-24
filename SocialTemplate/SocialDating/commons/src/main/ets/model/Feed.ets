import { BasicUserInfo } from './BasicUserInfo';
import { CommonRsp } from './CommonRsp';
import { Page } from './Page';

export class Comment {
  commentId: number | null = null;
  commentType: number | null = null;
  feedId: number | null = null;
  uid: number | null = null;
  nickName: string | null = null;
  content: string | null = null;
  createTime: number | null = null;
  recipientUid: number | null = null;
  recipientNickName: string | null = null;
}


export class CreateFeedRequest {
  uid: number;
  feedMsg: string | null;
  resourceUrls: string[];

  constructor(uid: number, feedMsg: string | null, resourceUrls: string[]) {
    this.uid = uid;
    this.feedMsg = feedMsg;
    this.resourceUrls = resourceUrls;
  }
}

export class CreateFeedResponse {
  ret: CommonRsp;
  feedId: number | null;

  constructor(ret: CommonRsp, feedId: number | null) {
    this.ret = ret;
    this.feedId = feedId;
  }
}

export class Feed {
  feedId: number | null = null;
  uid: number | null = null;
  feedMsg: string | null = null;
  userNo: string | null = null;
  nickName: string | null = null;
  realNameAuthFlag: number | null = null;
  profilePictureUrl: string | null = null;
  resourceUrl: string[] | null = null;
  creationDate: number = 0;
  lastUpdateDate: number = 0;
  currentUserHasFollowed: number = 0;
  comments: Comment[] | null = null;
  likes: BasicUserInfo[] | null = null;
}

export class GetFeedResponse {
  ret: CommonRsp;
  feed: Feed;

  constructor(ret: CommonRsp, feed: Feed) {
    this.ret = ret;
    this.feed = feed;
  }
}

export class QueryFeedResponse {
  ret: CommonRsp;
  page: Page;
  list: Feed[];

  constructor(ret: CommonRsp, page: Page, list: Feed[]) {
    this.ret = ret;
    this.page = page;
    this.list = list;
  }
}

export enum FollowType {
  Follow,
  UnFollow
}

export class FollowUserRequest {
  uid: number;
  followUid: number;
  type: number;

  constructor(uid: number, followUid: number, type: number) {
    this.uid = uid;
    this.followUid = followUid;
    this.type = type;
  }
}

export class CreateLikeReq {
  uid: number;
  feedId: number;
  likeOperType: LikeOperType;

  constructor(uid: number, feedId: number, likeOperType: LikeOperType) {
    this.uid = uid;
    this.feedId = feedId;
    this.likeOperType = likeOperType;
  }
}

export enum LikeOperType {
  DoLike,
  CancelLike
}