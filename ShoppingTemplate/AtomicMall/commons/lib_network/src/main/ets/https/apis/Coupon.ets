import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { GetCouponListReq, ClaimCouponReq, UpdateCouponReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import { CouponListResp } from '../../types/responses/CouponResponse';
import request from '../Request';

class CouponApis {
  /**
   * 查询优惠券列表
   * status: '2'-生效; '3'-失效
   * couponStatus: '1'-已核销（配合 status='3' 查询已使用优惠券）
   */
  public async getCoupons(params: GetCouponListReq): Promise<CouponListResp> {
    return request.get(RequestUrlMap.COUPON_LIST, { params });
  }

  /**
   * 领取优惠券
   */
  public async claimCoupon(data: ClaimCouponReq): Promise<BaseResponse> {
    return request.post(RequestUrlMap.COUPON_CLAIM, data);
  }

  /**
   * 更新优惠券状态（核销/失效）
   */
  public async updateCoupon(data: UpdateCouponReq): Promise<BaseResponse> {
    return request.put(RequestUrlMap.COUPON_UPDATE, data);
  }
}

const instance = new CouponApis();

export { instance as CouponApis };
