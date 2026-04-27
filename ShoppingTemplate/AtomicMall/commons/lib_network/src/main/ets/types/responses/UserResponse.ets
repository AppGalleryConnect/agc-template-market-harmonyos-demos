import { BaseResponse } from './BaseResponse';

export interface MembershipInfo {
  startDate: string // YYYY-MM-DD
  expireDate: string // YYYY-MM-DD
  isSubscribed: boolean
}

export interface MembershipInfoResp extends BaseResponse {
  data:MembershipInfo
}