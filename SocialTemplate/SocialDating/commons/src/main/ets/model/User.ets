import { BasicUserInfo } from './BasicUserInfo';
import { CommonRsp } from './CommonRsp';
import { Page } from './Page';

export class CreateUserRequest {
  hwUnionId: string | null = null;
  gender: number | null = null;
  birth: string | null = null;
  maritalStatus: number | null = null;
  currentResidence: string | null = null;
  monthlyIncome: number | null = null;
  education: number | null = null;
  originFrom: string | null = null;
}

export class UserFullInfo {
  userInfo: UserInfo | null = null;
  mateSelectionCriteria: MateSelectionCriteria | null = null;
  recentFeedImages: string[] | null = null;
  userActionSummary: UserActionSummary | null = null;
}

export class UserActionSummary{
  followUserCount:number  = 0;
  likedCount:number = 0;
  commentCount:number =0;
}

export class MateSelectionCriteria{
  ageStart: number | null = null;
  ageEnd: number | null = null;
  gender: number | null = null;
  heightStart: number | null = null;
  heightEnd: number | null = null;
  currentResidence: string | null = '';
  monthlyIncome: string | null = null;
  education: string | null = null;
  originFrom: string | null = '';
  ethnicGroup: string | null = '';
  job: string | null = null;
  hasChildren: string | null = null;
  expectationOfChildren: string | null = null;
  smoking: string | null = null;
  drinking: string | null = null;
  marriageStatus: string | null = null;
}

export class UserInfo {
  uid: number | null = null;
  hwUnionId: string | null = null;
  userNo: string | null = null;
  nickName: string | null = null;
  realNameAuthFlag: number = 0;
  gender: number | null = null;
  birth: string | null = null;
  currentResidence: string | null = null;
  monthlyIncome: number | null = null;
  education: number | null = null;
  originFrom: string | null = null;
  ethnicGroup: string | null = null;
  job: string | null = null;
  hasChildren: number | null = null;
  expectationOfChildren: number | null = null;
  smoking: number | null = null;
  drinking: number | null = null;
  house: number | null = null;
  hasBuyCar: number | null = null;
  weight: number | null = null;
  whenToMarry: number | null = null;
  weixinNo: string | null = null;
  hobbies: string | null = null;
  selfIntroduction: string | null = null;
  profilePictureUrl: string | null = null;
  isVip: number | null = null;
  isPublic: number = 1;
  album: Array<string> | null = null;
  marriageStatus: number | null = null;
   height: number | null = null;
   hasFollowed: number | null = null;

  public static toBasicUserInfo(userInfo: UserInfo): BasicUserInfo {
    let basicUserInfo: BasicUserInfo = new BasicUserInfo();
    basicUserInfo.uid = userInfo.uid;
    basicUserInfo.userNo = userInfo.userNo;
    basicUserInfo.nickName = userInfo.nickName;
    basicUserInfo.profileUrl = userInfo.profilePictureUrl;
    basicUserInfo.isVip = userInfo.isVip;
    basicUserInfo.realNameAuthFlag = userInfo.realNameAuthFlag;
    basicUserInfo.gender = userInfo.gender;
    return basicUserInfo;
  }
}

export class GetUserResponse {
  ret: CommonRsp;
  userFullInfo: UserFullInfo | null;

  constructor(ret: CommonRsp, userFullInfo: UserFullInfo | null) {
    this.ret = ret;
    this.userFullInfo = userFullInfo;
  }
}

export class QueryUserResponse {
  ret: CommonRsp;
  page: Page;
  users: UserFullInfo[];

  constructor(ret: CommonRsp, page:Page, users: UserFullInfo[]) {
    this.ret = ret;
    this.page = page;
    this.users = users;
  }
}