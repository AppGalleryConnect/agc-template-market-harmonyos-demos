import { CommonRsp, Page } from 'commons';
import { ActivityInfo } from './ActivityInfo';

export class GetActivityResponse {
  ret: CommonRsp;
  activity: ActivityInfo;

  constructor(ret: CommonRsp, activity: ActivityInfo) {
    this.ret = ret;
    this.activity = activity;
  }
}