import { RequestUrl } from '../constants/NetworkEnums';
import request from '../models/AxiosRequest';
import { BaseResponse, GetUserInfoResp } from '../types/ResponseTypes';

class HttpApi {
  public bindPhone(authCode: string): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.USER_BIND_PHONE,
      data: { authCode },
    });
  }

  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    return request.get({ url: RequestUrl.USER_GET_INFO });
  }
}

const https = new HttpApi();

export { https };