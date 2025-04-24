import { UserFullInfo, Feed } from 'commons';

export class ActionSummaryPageParam {
  emptyTab1Info: string[] = [];
  emptyTab2Info: string[] = [];
  userInfos: UserFullInfo[] | null = null;
  feeds: Feed[] | null = null;
  pageType: ActionSummaryPageType = ActionSummaryPageType.FollowUser

  constructor(emptyTab1Info: string[], emptyTab2Info: string[], pageType: ActionSummaryPageType,
    userInfos: UserFullInfo[] | null, feeds: Feed[] | null) {
    this.emptyTab1Info = emptyTab1Info;
    this.emptyTab2Info = emptyTab2Info;
    this.userInfos = userInfos;
    this.feeds = feeds;
    this.pageType = pageType
  }
}

export enum ActionSummaryPageType {
  FollowUser,
  Like,
  Comment
}