import { CommonRsp, Page } from 'commons';
import { EnrolledActivity } from './EnrolledActivity';

export class QueryEnrolledActivitiesResponse {
  ret: CommonRsp;
  page: Page;
  list: EnrolledActivity[];

  constructor(ret: CommonRsp, page: Page, list: EnrolledActivity[]) {
    this.ret = ret;
    this.page = page;
    this.list = list;
  }
}