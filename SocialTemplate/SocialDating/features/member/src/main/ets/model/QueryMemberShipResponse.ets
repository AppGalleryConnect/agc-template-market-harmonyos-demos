import { CommonRsp } from 'commons';

export interface MemberShip {
  id:number,
  name: string,
  days: number,
  fee: number,
  desc: string
}

export class QueryMemberShipResponse {
  ret: CommonRsp;
  list: MemberShip[];

  constructor(ret: CommonRsp, list: MemberShip[]) {
    this.ret = ret;
    this.list = list;
  }
}