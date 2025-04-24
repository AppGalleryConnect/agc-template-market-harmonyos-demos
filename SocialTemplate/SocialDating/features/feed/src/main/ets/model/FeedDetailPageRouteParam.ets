import { BasicUserInfo } from 'commons';
import { Feed} from 'commons/src/main/ets/model/Feed';

export class FeedDetailPageRouteParam {
  feed: Feed | null = null;
  needShowFollowButton: boolean = false;
  commentPlaceHolder: string = '';
  currentUser:BasicUserInfo|null = null;

  constructor(feed: Feed, needShowFollowButton: boolean, commentPlaceHolder?: string, currentUser?:BasicUserInfo) {
    this.feed = feed;
    this.needShowFollowButton = needShowFollowButton;
    if (commentPlaceHolder != null) {
      this.commentPlaceHolder = commentPlaceHolder;
    }
    if(currentUser!= null) {
      this.currentUser = currentUser;
    }
  }
}