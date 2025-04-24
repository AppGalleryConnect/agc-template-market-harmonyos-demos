import { BaseResponse, GetUserInfoResp } from '../types/ResponseTypes';

class HttpApiMock {
  private static _userInfoMock: GetUserInfoResp = {
    avatar: 'mockImage://ic_default_avatar',
    nickname: '',
    phone: '1XXXXXX',
  };

  public bindPhone(): Promise<BaseResponse<undefined>> {
    const resp: BaseResponse = { code: 0, data: undefined };
    return Promise.resolve(resp);
  }

  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    const resp: BaseResponse<GetUserInfoResp> = { code: 0, data: HttpApiMock._userInfoMock };
    return Promise.resolve(resp);
  }
}

const httpsMock = new HttpApiMock();

export { httpsMock };
