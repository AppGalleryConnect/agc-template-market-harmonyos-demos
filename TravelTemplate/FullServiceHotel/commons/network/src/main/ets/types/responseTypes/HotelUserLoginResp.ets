import { MemberInfo } from 'commonlib';

export interface HotelUserLoginResp {
  loginToken: string;
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
  memberMsg: MemberInfo;
}
