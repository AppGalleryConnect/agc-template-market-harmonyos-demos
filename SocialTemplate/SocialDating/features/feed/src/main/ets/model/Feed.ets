import { Comment } from './Comment';
import { BasicUserInfo } from 'commons';

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
  comments: Comment[] | null = null;
  likes: BasicUserInfo[] | null = null;
}