import { RequestUrl } from '../constants/NetworkEnums';
import request from '../models/AxiosRequest';
import { GetUserInfoResp } from '../models/response/GetUserInfoResp';
import { BaseResponse } from '../types/ResponseTypes';

class UserApi {
  public bindPhone(authCode: string): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.USER_BIND_PHONE,
      data: { authCode },
    });
  }

  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    return request.get({ url: RequestUrl.USER_GET_INFO });
  }

  public updateUserNickname(nickname: string): Promise<BaseResponse<string>> {
    return request.get({
      url: RequestUrl.USER_UPDATE_NICKNAME,
      data: { nickname },
    });
  }
}

const userApi = new UserApi();

export { userApi as UserApi };