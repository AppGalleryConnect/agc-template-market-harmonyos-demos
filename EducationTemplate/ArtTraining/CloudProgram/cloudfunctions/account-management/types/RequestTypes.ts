export interface BaseReq {
  userId: string;
}

export interface BindPhoneReq extends BaseReq {
  authCode: string;
  createMock?: boolean;
}

export interface UpdateUserInfoReq extends BaseReq {
  avatar?: string;
  nickname?: string;
  wechat?: string;
  birthday?: string;
}
