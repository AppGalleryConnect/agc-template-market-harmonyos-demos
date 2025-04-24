import { CommonRsp, Page } from 'commons';
import { Feed } from './Feed';

export class GetFeedResponse {
  ret: CommonRsp;
  feed: Feed;

  constructor(ret: CommonRsp, feed: Feed) {
    this.ret = ret;
    this.feed = feed;
  }
}