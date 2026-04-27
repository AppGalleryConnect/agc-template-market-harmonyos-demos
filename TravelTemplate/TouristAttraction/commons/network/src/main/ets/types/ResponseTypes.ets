export interface BaseResponse<T = ESObject> {
  code: number;

  msg?: string;

  data: T;
}

export interface GetUserInfoResp {
  avatar: string;

  nickname: string;

  phone: string;
}