import { BasicUserInfo } from '../model/BasicUserInfo';
import { Comment, CreateFeedRequest, Feed, FollowType, LikeOperType, QueryFeedResponse } from '../model/Feed';
import {
  CreateUserRequest,
  GetUserResponse,
  QueryUserResponse,
  UserActionSummary,
  UserFullInfo,
  UserInfo
} from '../model/User';
import { CommonRsp } from '../model/CommonRsp';
import { Constants, QueryFeedType, QueryFollowUserType } from '../utils/Constants';
import { BaseService, getCurrentUid, getRawFile } from './BaseService';
import { Page } from '../model/Page';
import { CommonUtils } from '../utils/CommonUtils';
import Logger from '../utils/Logger';

const DEFAULT_COMMON_RSP = new CommonRsp(Constants.RET_SUCCESS_CODE, '');

export class MockService {
  static currentUserFullInfo: UserFullInfo;
  static currentUserLikeFeeds: number[] = [];
  static currentUserComments: Comment[] = [];
  static currentUserFollowUsers: BasicUserInfo[] = []
  static newFeeds: Feed[] = [];
  static feedMap: Map<number, Feed> = new Map();
  static userFeedIds: Map<number, number[]> = new Map();
  static recommendFeeds: Feed[] = [];
  static followedFeeds: Feed[] = [];
  static searchUsersMap: Map<number, UserFullInfo[]> = new Map();
  static recommendUsers: Map<number, UserFullInfo[]> = new Map();
  static allUser: Map<number, UserFullInfo> = new Map();
  static userUnionIdAndUid: Map<string, number> = new Map();

  static init() {
    getRawFile<QueryUserResponse>('query.user.1.json').then((rsp: QueryUserResponse) => {
      MockService.searchUsersMap.set(Constants.GENDER_MALE, rsp.users);
      MockService.addUserToMap(rsp.users);
    })
    getRawFile<QueryUserResponse>('query.user.json').then((rsp: QueryUserResponse) => {
      MockService.searchUsersMap.set(Constants.GENDER_FEMALE, rsp.users);
      MockService.addUserToMap(rsp.users);
    })
    getRawFile<QueryUserResponse>('get.recommend.user.1.json').then((rsp: QueryUserResponse) => {
      MockService.recommendUsers.set(Constants.GENDER_MALE, rsp.users);
      MockService.addUserToMap(rsp.users);
    })
    getRawFile<QueryUserResponse>('get.recommend.user.2.json').then((rsp: QueryUserResponse) => {
      MockService.recommendUsers.set(Constants.GENDER_FEMALE, rsp.users);
      MockService.addUserToMap(rsp.users);
    })
    getRawFile<QueryUserResponse>('get.recommend.user.2.json').then((rsp: QueryUserResponse) => {
      MockService.recommendUsers.set(Constants.GENDER_FEMALE, rsp.users);
      MockService.addUserToMap(rsp.users);
    })
    getRawFile<QueryUserResponse>('feed.users.json').then((rsp: QueryUserResponse) => {
      MockService.addUserToMap(rsp.users);
    })
    getRawFile<QueryFeedResponse>('query.recommend.feed.json').then((rsp: QueryFeedResponse) => {
      MockService.recommendFeeds = rsp.list;
      MockService.addFeed(rsp.list);
    })
    getRawFile<QueryFeedResponse>('query.feed.by.user.100001.json').then((rsp: QueryFeedResponse) => {
      MockService.addFeed(rsp.list);
    })
    getRawFile<QueryFeedResponse>('query.feed.by.user.100091.json').then((rsp: QueryFeedResponse) => {
      MockService.addFeed(rsp.list);
    })
    getRawFile<QueryFeedResponse>('query.feed.by.user.100204.json').then((rsp: QueryFeedResponse) => {
      MockService.addFeed(rsp.list);
    })
    getRawFile<QueryFeedResponse>('query.feed.by.user.100003.json').then((rsp: QueryFeedResponse) => {
      MockService.addFeed(rsp.list);
    })
  }

  private static addFeed(rspFeeds: Feed[]) {
    rspFeeds.forEach((value, index, rspFeeds) => {
      if (value.feedId != null) {
        MockService.feedMap.set(value.feedId, value);
        if (value.uid != null) {
          let userFeedIdsTmp: number[] | undefined = MockService.userFeedIds.get(value.uid);
          if (userFeedIdsTmp == null || userFeedIdsTmp === undefined) {
            userFeedIdsTmp = [];
          }
          if (value.feedId != null) {
            userFeedIdsTmp.push(value.feedId);
          }
          MockService.userFeedIds.set(value.uid, userFeedIdsTmp)
        }
      }
    })
  }

  static getFeedList(queryType: string, uid?: number | null, curPage?: number,
    pageSize?: number): QueryFeedResponse | null {
    if (curPage === undefined) {
      curPage = BaseService.CUR_PAGE_DEFAULT;
    }
    if (pageSize === undefined) {
      pageSize = BaseService.PAGE_SIZE_DEFAULT;
    }
    switch (queryType) {
      case QueryFeedType.QUERY_BY_USER.toString():
        return MockService.queryFeedListByUser(uid, curPage, pageSize);
      case QueryFeedType.QUERY_MY_LIKE.toString():
        return new QueryFeedResponse(DEFAULT_COMMON_RSP,
          buildPage(curPage, pageSize, MockService.currentUserLikeFeeds),
          getFeeds(slice(MockService.currentUserLikeFeeds, curPage, pageSize)));
      case QueryFeedType.QUERY_LIKED_BY_OTHERS.toString():
        return MockService.queryLikedByOthersFeeds(curPage, pageSize);
      case QueryFeedType.QUERY_MY_COMMENTED.toString():
        return MockService.queryMyCommentedFeeds(curPage, pageSize);
      case QueryFeedType.QUERY_COMMENTED_BY_OTHERS.toString():
        return MockService.queryCommentedByFeeds(curPage, pageSize);
      case QueryFeedType.QUERY_RECOMMEND.toString():
        return MockService.queryRecommendedFeeds(curPage, pageSize);
      case QueryFeedType.QUERY_FOLLOWED.toString():
        return MockService.queryFollowedFeeds(curPage, pageSize);
      default:
        return new QueryFeedResponse(DEFAULT_COMMON_RSP, buildPage(curPage, pageSize, []), []);
    }
  }

  private static queryFollowedFeeds(curPage: number, pageSize: number) {
    let followUserFeeds: Feed[] = MockService.getFollowUserFeeds();
    followUserFeeds.forEach((value, index, tmp) => {
      setCurrentUserHasFollowed(value);
    })
    followUserFeeds.sort((a, b) => b.creationDate - a.creationDate);
    return new QueryFeedResponse(DEFAULT_COMMON_RSP,
      buildPage(curPage, pageSize, followUserFeeds), slice(followUserFeeds, curPage, pageSize));
  }

  private static queryRecommendedFeeds(curPage: number, pageSize: number) {
    let retFeeds = slice(MockService.recommendFeeds, curPage, pageSize);
    retFeeds.forEach((value, index, tmp) => {
      setCurrentUserHasFollowed(value);
    })
    return new QueryFeedResponse(DEFAULT_COMMON_RSP,
      buildPage(curPage, pageSize, MockService.recommendFeeds),
      retFeeds);
  }

  private static queryMyCommentedFeeds(curPage: number, pageSize: number) {
    let commentedFeedIds: number[] = getCommentFeedIds();
    return new QueryFeedResponse(DEFAULT_COMMON_RSP,
      buildPage(curPage, pageSize, commentedFeedIds), getFeeds(
        slice(commentedFeedIds, curPage, pageSize)));
  }

  private static queryLikedByOthersFeeds(curPage: number, pageSize: number) {
    let likedByOthersFeedIds: number[] = [];
    let tmp = MockService.newFeeds;
    tmp.forEach((value, index, tmp) => {
      // 只要我的feed有被点赞（不管点赞是自己点的还是别人点的）就查出来
      if (value.feedId != null && value.likes != null && value.likes.length > 0) {
        likedByOthersFeedIds.push(value.feedId)
      }
    })
    return new QueryFeedResponse(DEFAULT_COMMON_RSP,
      buildPage(curPage, pageSize, likedByOthersFeedIds), getFeeds(
        slice(likedByOthersFeedIds, curPage, pageSize)));
  }

  private static queryCommentedByFeeds(curPage: number, pageSize: number) {
    let myCommentedFeedIds: number[] = [];
    let tmp = MockService.newFeeds;
    tmp.forEach((value, index, tmp) => {
      if (value.feedId != null && value.comments != null && value.comments.length > 0) {
        let idx = value.comments.findIndex((comment: Comment) => comment != null &&
          comment.uid === value.uid)
        if (idx !== -1) {
          myCommentedFeedIds.push(value.feedId)
        }
      }
    })
    return new QueryFeedResponse(DEFAULT_COMMON_RSP,
      buildPage(curPage, pageSize, myCommentedFeedIds), getFeeds(
        slice(myCommentedFeedIds, curPage, pageSize)));
  }


  private static queryFeedListByUser(uid: number | null | undefined, curPage: number,
    pageSize: number): QueryFeedResponse | null {
    if (uid != null && uid !== undefined) {
      if (uid === getCurrentUid()) {
        let feeds = MockService.newFeeds;
        feeds.sort((a, b) => b.creationDate - a.creationDate);
        return new QueryFeedResponse(DEFAULT_COMMON_RSP,
          buildPage(curPage, pageSize, feeds),
          slice(feeds, curPage, pageSize));
      } else {
        let feedByUser: Feed[] = MockService.getFeedByUser(uid);
        return new QueryFeedResponse(DEFAULT_COMMON_RSP,
          buildPage(curPage, pageSize, feedByUser),
          slice(feedByUser, curPage, pageSize));
      }
    }
    return new QueryFeedResponse(DEFAULT_COMMON_RSP, buildPage(curPage, pageSize, []), []);
  }

  static getFeedDetail(feedId: number): Feed | null {
    let tmp: Feed | undefined = MockService.feedMap.get(feedId);
    if (tmp !== undefined) {
      return tmp;
    }
    return null;
  }

  static createFeed(createFeedReq: CreateFeedRequest): number {
    let newFeed = new Feed();
    newFeed.feedId = CommonUtils.generateNo();
    newFeed.feedMsg = createFeedReq.feedMsg;
    newFeed.uid = createFeedReq.uid;
    newFeed.resourceUrl = createFeedReq.resourceUrls;
    newFeed.creationDate = new Date().getTime();
    newFeed.lastUpdateDate = new Date().getTime();
    if (MockService.currentUserFullInfo != null && MockService.currentUserFullInfo.userInfo != null) {
      newFeed.userNo = MockService.currentUserFullInfo.userInfo.userNo;
      newFeed.nickName = MockService.currentUserFullInfo.userInfo.nickName;
      newFeed.realNameAuthFlag = MockService.currentUserFullInfo.userInfo.realNameAuthFlag;
      newFeed.profilePictureUrl = MockService.currentUserFullInfo.userInfo.profilePictureUrl;
    }
    MockService.newFeeds.push(newFeed)
    MockService.feedMap.set(newFeed.feedId, newFeed);
    return newFeed.feedId;
  }

  static followUser(followUid: number, currentUid: number, type: FollowType): CommonRsp {
    let followUser = MockService.allUser.get(followUid);
    if (followUser != null && followUser.userInfo != null) {
      let idx = MockService.currentUserFollowUsers.findIndex((value: BasicUserInfo) => value != null &&
        value.uid === followUid)
      if (type === FollowType.Follow) {
        followUser.userInfo.hasFollowed = Constants.YES;
        if (idx === -1) {
          MockService.currentUserFollowUsers.push(UserInfo.toBasicUserInfo(followUser.userInfo));
        }
      } else {
        followUser.userInfo.hasFollowed = Constants.NO;
        if (idx !== -1) {
          MockService.currentUserFollowUsers.splice(idx, 1);
        }
      }
    } else {
      Logger.error('followUser failed, followUid cannot find, followUid=' + followUid)
    }
    return DEFAULT_COMMON_RSP;
  }

  static likeFeed(currentUid: number, feedId: number,
    likeOperType: LikeOperType): CommonRsp {
    let tmp = MockService.feedMap.get(feedId);
    let currentUser = MockService.getCurrentUserBasic();
    if (likeOperType === LikeOperType.DoLike) {
      MockService.currentUserLikeFeeds.push(feedId);
      if (tmp != null && currentUser != null) {
        if (tmp.likes != null) {
          tmp.likes.push(currentUser)
        } else {
          tmp.likes = [currentUser]
        }
      }
    } else {
      let idx = MockService.currentUserLikeFeeds.indexOf(feedId);
      if (idx !== -1) {
        MockService.currentUserLikeFeeds.splice(idx, 1);
      }
      if (tmp != null && tmp.likes != null && currentUser != null) {
        let idx2 = tmp.likes.findIndex((value: BasicUserInfo) => value != null && currentUser != null &&
          value.uid === currentUser.uid)
        if (idx2 !== -1) {
          tmp.likes.splice(idx2, 1);
        }
      }
    }
    return DEFAULT_COMMON_RSP;
  }

  static createComment(currentUid: number, feedId: number, commentTxt: string, theCommentToReply?: Comment | null):
    CommonRsp {
    let newComment = new Comment();
    newComment.commentId = CommonUtils.generateNo();
    newComment.uid = currentUid;
    newComment.feedId = feedId;
    let currentUserFullInfo = MockService.currentUserFullInfo;
    if (currentUserFullInfo != null && currentUserFullInfo.userInfo != null &&
      currentUserFullInfo.userInfo.nickName != null) {
      newComment.nickName = currentUserFullInfo.userInfo.nickName;
    }
    if (theCommentToReply === undefined || theCommentToReply == null) {
      newComment.commentType = Constants.COMMENT_TYPE_NORMAL;
    } else {
      newComment.commentType = Constants.COMMENT_TYPE_REPLY;
      newComment.recipientUid = theCommentToReply.uid;
      newComment.recipientNickName = theCommentToReply.nickName;
    }
    newComment.content = commentTxt;
    newComment.createTime = new Date().getTime();
    MockService.currentUserComments.push(newComment)

    let feed = MockService.feedMap.get(feedId);
    if (feed != null) {
      if (feed.comments != null) {
        feed.comments.push(newComment);
      } else {
        feed.comments = [newComment]
      }
    }
    return DEFAULT_COMMON_RSP;
  }

  private static getFeedByUser(uid: number): Feed[] {
    let tmp: number[] | undefined = MockService.userFeedIds.get(uid);
    if (tmp !== undefined) {
      let userFeeds: Feed[] = getFeeds(tmp);
      return userFeeds.sort((a, b) => b.creationDate - a.creationDate);
    }
    return [];
  }

  private static getCurrentUserBasic(): BasicUserInfo | null {
    if (MockService.currentUserFullInfo != null && MockService.currentUserFullInfo.userInfo != null) {
      return UserInfo.toBasicUserInfo(MockService.currentUserFullInfo.userInfo);
    }
    return null;
  }

  private static getFollowUserFeeds(): Feed[] {
    let followUserFeeds: Feed[] = [];
    let followUsers = MockService.currentUserFollowUsers;
    followUsers.forEach((value, index, rspFeeds) => {
      if (value != null && value.uid != null) {
        followUserFeeds = followUserFeeds.concat(MockService.getFeedByUser(value.uid))
      }
    })
    return followUserFeeds;
  }

  static getUserFullInfoByUnionId(hwUnionId: string | undefined | null): GetUserResponse {
    if (hwUnionId == null || hwUnionId === undefined) {
      MockService.fillUserActionSummary(MockService.currentUserFullInfo);
      return new GetUserResponse(DEFAULT_COMMON_RSP, clone(MockService.currentUserFullInfo));
    }
    let uid = MockService.userUnionIdAndUid.get(hwUnionId);
    if (uid == null) {
      return new GetUserResponse(DEFAULT_COMMON_RSP, null);
    }
    let userFullInfo: UserFullInfo | undefined = MockService.allUser.get(uid);
    MockService.fillUserActionSummary(userFullInfo);

    return new GetUserResponse(DEFAULT_COMMON_RSP, userFullInfo === undefined ? null : clone(userFullInfo));
  }

  private static fillUserActionSummary(userFullInfo: UserFullInfo | undefined) {
    if (userFullInfo != null && userFullInfo !== undefined && userFullInfo.userInfo != null) {
      if (userFullInfo.userInfo.uid === getCurrentUid()) {
        let userActionSummary: UserActionSummary = new UserActionSummary();
        userActionSummary.followUserCount = MockService.currentUserFollowUsers.length;
        userActionSummary.likedCount = MockService.currentUserLikeFeeds.length;
        userActionSummary.commentCount = MockService.currentUserComments.length;
        userFullInfo.userActionSummary = userActionSummary;
      }
    }
  }

  static getRecommendUsers(unionId: string | undefined, curPage: number): UserFullInfo[] | null {
    let currentUser = MockService.getCurrentUserBasic();
    let gender =
      currentUser == null ? Constants.GENDER_MALE :
        (currentUser.gender == null ? Constants.GENDER_MALE : currentUser.gender);
    let allRecommend: UserFullInfo[] | undefined = MockService.recommendUsers.get(gender);
    if (allRecommend !== undefined && curPage >= 1 && curPage <= allRecommend.length) {
      return [allRecommend[curPage-1]]
    }
    return null;
  }

  /**
   * 打桩情况下，search接口不做搜索条件过滤，返回固定的搜索结果
   * @returns
   */
  static searchUsers(): UserFullInfo[] {
    let currentUser = MockService.getCurrentUserBasic();
    let gender = currentUser == null ? Constants.GENDER_MALE :
      (currentUser.gender == null ? Constants.GENDER_MALE : currentUser.gender);
    let users: UserFullInfo[] | undefined = MockService.searchUsersMap.get(gender);
    if (users !== undefined && users.length > 0) {
      users.forEach((value, index, tmp) => {
        if (value.userInfo != null && value.userInfo.uid != null) {
          let idx =
            MockService.currentUserFollowUsers.findIndex((followedUser: BasicUserInfo) => followedUser != null &&
              followedUser.uid != null && value.userInfo != null &&
              followedUser.uid === value.userInfo.uid)
          if (idx !== -1) {
            value.userInfo.hasFollowed = Constants.YES
          }
        }
      });
      return users;
    }
    return [];
  }

  static queryFollowedUser(uid: number, queryType: number, curPage ?: number, pageSize?: number): UserFullInfo[] {
    if (curPage === undefined) {
      curPage = BaseService.CUR_PAGE_DEFAULT;
    }
    if (pageSize === undefined) {
      pageSize = BaseService.PAGE_SIZE_DEFAULT;
    }
    if (queryType === QueryFollowUserType.QUERY_FOLLOWED_BY_ME) {
      let followUserBasic = MockService.currentUserFollowUsers;
      if (followUserBasic != null && followUserBasic.length > 0) {
        let sliced = slice(followUserBasic, curPage, pageSize);
        if (null != sliced && sliced.length > 0) {
          let ret: UserFullInfo[] = [];
          sliced.forEach((value, index, sliced) => {
            if (value.uid != null) {
              let tmp: UserFullInfo | undefined = MockService.allUser.get(value.uid);
              if (tmp != null) {
                if (tmp.userInfo != null) {
                  tmp.userInfo.hasFollowed = Constants.YES;
                }
                ret.push(tmp)
              }
            }
          });
          return ret;
        }
      }
    }
    return [];
  }

  static deleteCurrentUser(): CommonRsp {
    AppStorage.delete(Constants.CURRENT_USER_FULL)
    MockService.currentUserLikeFeeds = [];
    MockService.currentUserComments = [];
    MockService.currentUserFollowUsers = [];
    MockService.newFeeds=[];
    MockService.feedMap = new Map();
    MockService.userFeedIds = new Map();
    MockService.recommendFeeds= [];
    MockService.followedFeeds= [];
    MockService.searchUsersMap = new Map();
    MockService.recommendUsers = new Map();
    MockService.allUser = new Map();
    MockService.userUnionIdAndUid = new Map();
    MockService.currentUserFullInfo = new UserFullInfo();
    MockService.init();
    return DEFAULT_COMMON_RSP
  }

  static createUser(createUserRequest: CreateUserRequest): CommonRsp {
    let userInfo: UserInfo = new UserInfo();
    userInfo.uid = CommonUtils.generateNo();
    userInfo.userNo = userInfo.uid.toString();
    userInfo.nickName = '华为用户';
    userInfo.birth = createUserRequest.birth;
    userInfo.hwUnionId = createUserRequest.hwUnionId;
    userInfo.gender = createUserRequest.gender;
    userInfo.marriageStatus = createUserRequest.maritalStatus;
    userInfo.currentResidence = createUserRequest.currentResidence;
    userInfo.monthlyIncome = createUserRequest.monthlyIncome;
    userInfo.education = createUserRequest.education;
    userInfo.originFrom = createUserRequest.originFrom;
    let userFullInfo = new UserFullInfo();
    userFullInfo.userInfo = userInfo;
    MockService.currentUserFullInfo = userFullInfo;
    AppStorage.setOrCreate(Constants.CURRENT_USER_BASIC, UserInfo.toBasicUserInfo(userInfo));
    AppStorage.setOrCreate(Constants.CURRENT_USER_FULL, userFullInfo);
    if (createUserRequest.hwUnionId != null) {
      MockService.userUnionIdAndUid.set(createUserRequest.hwUnionId, userInfo.uid);
      MockService.allUser.set(userInfo.uid, userFullInfo);
    }

    return DEFAULT_COMMON_RSP;
  }

  static updateUser(userFullInfo: UserFullInfo): CommonRsp {
    if (userFullInfo == null || userFullInfo.userInfo == null) {
      return new CommonRsp(-1, 'updateUser failed, input userInfo is null');
    }
    MockService.currentUserFullInfo = JSON.parse(JSON.stringify(userFullInfo));
    AppStorage.setOrCreate(Constants.CURRENT_USER_FULL, userFullInfo);
    if (userFullInfo.userInfo.uid != null) {
      MockService.allUser.set(userFullInfo.userInfo.uid, userFullInfo);
    }
    return DEFAULT_COMMON_RSP;
  }

  private static addUserToMap(users: UserFullInfo[]) {
    users.forEach((value, index, tmp) => {
      if (value != null && value.userInfo != null && value.userInfo.uid != null) {
        MockService.allUser.set(value.userInfo.uid, value);
        if (value.userInfo.hwUnionId != null) {
          MockService.userUnionIdAndUid.set(value.userInfo.hwUnionId, value.userInfo.uid)
        }
      }
    });
  }

  static subscribeMember(uid: number, fee: number, membershipStartTime: number): CommonRsp {
    if (MockService.currentUserFullInfo != null && MockService.currentUserFullInfo.userInfo != null) {
      MockService.currentUserFullInfo.userInfo.isVip = Constants.YES;
    }
    return DEFAULT_COMMON_RSP;
  }
}

function buildPage<T>(curPage: number, pageSize: number, newFeeds: T[]): Page {
  return new Page(newFeeds.length, (newFeeds.length / pageSize) + 1, curPage, pageSize);
}

function getCommentFeedIds(): number[] {
  let feedIds: number[] = [];
  let tmp = MockService.currentUserComments;
  tmp.forEach((value, index, tmp) => {
    if (value.feedId != null && feedIds.indexOf(value.feedId) === -1) {
      feedIds.push(value.feedId)
    }
  })
  return feedIds;
}

function getFeeds(feedIds: number[]): Feed[] {
  let feeds: Feed[] = [];
  feedIds.forEach((value, index, feedIds) => {
    let feedTmp: Feed | undefined = MockService.feedMap.get(value);
    if (feedTmp !== undefined) {
      setCurrentUserHasFollowed(feedTmp);
      feeds.push(feedTmp)
    }
  })
  return feeds;
}

function setCurrentUserHasFollowed(feedTmp: Feed) {
  let feedUid = feedTmp.uid;
  let idx2 = MockService.currentUserFollowUsers.findIndex((value: BasicUserInfo) => value != null &&
    value.uid === feedUid);
  if (idx2 !== -1) {
    feedTmp.currentUserHasFollowed = Constants.YES;
  } else {
    feedTmp.currentUserHasFollowed = Constants.NO;
  }
}

function slice<T>(allData: T[], curPage: number, pageSize: number): T[] {
  let reqStart: number = (curPage - 1) * pageSize;
  let reqEnd: number = curPage * pageSize;
  if (reqStart < 0) {
    reqStart = 0;
  }
  if (reqEnd < 0) {
    reqEnd = 0;
  }
  if (reqStart >= 0 && reqEnd < allData.length) {
    return allData.slice(reqStart, reqEnd)
  } else if (reqStart < allData.length && reqEnd > allData.length) {
    return allData.slice(reqStart, allData.length)
  } else {
    return [];
  }
}

function clone<T>(obj: T | undefined): T | null {
  if (obj === undefined) {
    return null;
  }
  return JSON.parse(JSON.stringify(obj)) as T
}
