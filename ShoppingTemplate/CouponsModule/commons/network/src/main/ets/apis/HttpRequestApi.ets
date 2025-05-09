import axiosClient from '../models/AxiosRequest';
import { GetCouponsRequest } from '../types/AxiosRequestParam';
import { BaseSuccessResponse } from '../types/BaseSuccessResponse';
import { GetCouponsResp } from '../types/responseTypes/GetCouponsResp';

class HttpsApi {
  /** 获取优惠券 **/
  public getCoupons(params: GetCouponsRequest): Promise<BaseSuccessResponse<GetCouponsResp>> {
    return axiosClient.get({
      url: '/v1/coupons/coupons-list',
      showLoading: false,
      headers: {},
      params: params,
    });
  }
}

const https = new HttpsApi();

export { https as Https };
