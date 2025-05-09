import { AxiosInstance, AxiosResponse } from '@ohos/axios';
import util from '@ohos.util';
import authentication from '@hms.core.authentication';

import { ApiResponse, UserDto } from '@common/customtypes';

export class User {

  private axios: AxiosInstance;

  public huaweiLogin = async (): Promise<authentication.AuthenticationResponse> => {
    const huaweiIDProvider: authentication.HuaweiIDProvider = new authentication.HuaweiIDProvider();
    const uuidForState = util.generateRandomUUID(false);
    const req: authentication.LoginWithHuaweiIDRequest = huaweiIDProvider.createLoginWithHuaweiIDRequest();
    req.forceLogin = true;
    req.state = uuidForState;
    req.nonce = util.generateRandomUUID(false);
    req.idTokenSignAlgorithm = authentication.IdTokenSignAlgorithm.PS256;
    return new authentication.AuthenticationController(getContext(this))
      .executeRequest(req);
  }

  public loginByCode = async (code: string): Promise<UserDto> => {
    try {
      const res: AxiosResponse<ApiResponse<UserDto>> =
        await this.axios.post<ApiResponse<UserDto>>('/api/v1/user/login', {
          code: code,
          token: ''
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public loginByToken = async (token: string): Promise<UserDto> => {
    try {
      const res: AxiosResponse<ApiResponse<UserDto>> =
        await this.axios.post<ApiResponse<UserDto>>('/api/v1/user/login', {
          code: '',
          token: token
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public logout = (token: string): void => {
    try {
      this.axios.post<ApiResponse<void>>('/api/v1/user/logout', {
        token: token
      });
    } catch (error) {
    }
  }

  constructor(axiosInstance: AxiosInstance) {
    this.axios = axiosInstance;
  }
}
