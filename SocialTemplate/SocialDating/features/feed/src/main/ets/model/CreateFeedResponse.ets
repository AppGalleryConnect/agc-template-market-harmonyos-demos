import { CommonRsp } from 'commons';

export class CreateFeedResponse {
  ret: CommonRsp;
  feedId: number | null;

  constructor(ret: CommonRsp, feedId: number | null) {
    this.ret = ret;
    this.feedId = feedId;
  }

}