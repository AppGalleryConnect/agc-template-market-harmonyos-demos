import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { UpdateUserInfoReq, UserLoginReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import { MembershipInfoResp } from '../../types/responses/UserResponse';
import request from '../Request';

class UserApis {
  /**
   * 用户登录
   */
  public login(params?: UserLoginReq): Promise<BaseResponse> {
    return request.get(RequestUrlMap.USER_LOGIN, { params });
  }

  /**
   * 用户登出
   */
  public logout(): Promise<BaseResponse> {
    return request.get(RequestUrlMap.USER_LOGOUT);
  }

  /**
   * 修改用户信息
   */
  public updateUserInfo(data: UpdateUserInfoReq): Promise<BaseResponse> {
    return request.put(RequestUrlMap.USER_INFO, data);
  }

  /**
   * 开通/续费年卡会员
   */
  public subscribeMembership(): Promise<BaseResponse> {
    return request.post(RequestUrlMap.USER_MEMBERSHIP);
  }

  /**
   * 查询会员信息
   */
  public getMembershipInfo(): Promise<MembershipInfoResp> {
    return request.get(RequestUrlMap.USER_MEMBERSHIP);
  }
}

const instance = new UserApis();

export { instance as UserApis };
