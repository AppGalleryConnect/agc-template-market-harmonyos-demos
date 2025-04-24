import { BasicUserInfo, QueryFeedType } from 'commons';
import { Feed } from './Feed';

export class FeedListPageRouteParam {
  currentUser: BasicUserInfo | null = null;
  theUserToQueryFeed: BasicUserInfo | null = null;
  queryFeedType: QueryFeedType;
  feedListPageTitle?: string;

  constructor(queryFeedType: QueryFeedType, currentUser: BasicUserInfo | null,
    theUserToQueryFeed: BasicUserInfo | null, feedListPageTitle?: string) {
    this.queryFeedType = queryFeedType;
    this.currentUser = currentUser;
    this.theUserToQueryFeed = theUserToQueryFeed;
    this.feedListPageTitle = feedListPageTitle;
  }
}