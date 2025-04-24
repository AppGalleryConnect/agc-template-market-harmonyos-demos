import { CommonRsp, Page } from 'commons';
import { Matchmaker } from './Matchmaker';

export class QueryMatchMakerResponse {
  ret: CommonRsp;
  page: Page;
  list: Matchmaker[];

  constructor(ret: CommonRsp, page: Page, list: Matchmaker[]) {
    this.ret = ret;
    this.page = page;
    this.list = list;
  }
}