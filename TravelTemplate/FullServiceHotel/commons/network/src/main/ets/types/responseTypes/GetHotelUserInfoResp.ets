import { MemberInfo } from 'commonlib';

export interface GetHotelUserInfoResp {
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
  memberMsg: MemberInfo;
}
