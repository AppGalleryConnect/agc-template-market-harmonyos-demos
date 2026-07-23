export interface BaseResponse<T = ESObject> {
  code: number;

  msg?: string;

  data: T;
}

export interface GetUserInfoResp {
  nickname: string;

  avatar: string;

  phone: string;
}