import { CommonRsp, Page } from 'commons';
import { ActivityInfo } from './ActivityInfo';

export class QueryActivityResponse {
  ret: CommonRsp;
  page: Page;
  list: ActivityInfo[];

  constructor(ret: CommonRsp, page: Page, list: ActivityInfo[]) {
    this.ret = ret;
    this.page = page;
    this.list = list;
  }
}