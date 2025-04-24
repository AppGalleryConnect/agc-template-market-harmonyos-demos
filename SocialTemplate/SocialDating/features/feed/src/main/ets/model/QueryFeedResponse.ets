import { CommonRsp, Page } from 'commons';
import { Feed } from './Feed';

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