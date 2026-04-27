import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { ClaimCouponReq, GetCouponListReq, UpdateCouponReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import { CouponItem, CouponListResp } from '../../types/responses/CouponResponse';
import { MockCouponData } from '../mockdata/MockCouponData';

export class CouponMockApis {
  /** 用深拷贝初始化，支持 claim/update 操作后列表状态变化 */
  private _coupons: CouponItem[] = JSON.parse(
    JSON.stringify(MockCouponData.COUPON_LIST),
  );

  public start(adapter: AxiosMockAdapter) {
    /** 查询优惠券列表 */
    adapter.onGet(RequestUrlMap.COUPON_LIST).reply((config: AxiosRequestConfig) => {
      const params = config.params as GetCouponListReq;
      const res = this._queryList(params);
      return [HttpStatusCode.Ok, res];
    });

    /** 领取优惠券 */
    adapter.onPost(RequestUrlMap.COUPON_CLAIM).reply((config: AxiosRequestConfig) => {
      const body = JSON.parse(config.data) as ClaimCouponReq;
      const existed = this._coupons.find((c) => c.couponID === body.couponId);
      if (!existed) {
        this._coupons.unshift(MockCouponData.newClaimableCoupon(body.couponId));
      }
      const res: BaseResponse = { code: 0, msg: '领取成功' };
      return [HttpStatusCode.Ok, res];
    });

    /** 更新优惠券状态（已使用/已过期） */
    adapter.onPut(RequestUrlMap.COUPON_UPDATE).reply((config: AxiosRequestConfig) => {
      const body = JSON.parse(config.data) as UpdateCouponReq;
      const target = this._coupons.find((c) => c.couponID === body.couponId);
      if (target) {
        target.couponStatus = body.couponStatus;
      }
      const res: BaseResponse = { code: 0, msg: '更新成功' };
      return [HttpStatusCode.Ok, res];
    });
  }

  private _queryList(params: GetCouponListReq): CouponListResp {
    let list = this._coupons.filter((c) => {
      if (params.couponStatus && c.couponStatus !== params.couponStatus) {
        return false;
      }
      return true;
    });

    const page = params.page ?? 1;
    const limit = params.limit ?? 50;
    const startIndex = (page - 1) * limit;
    const pageList = list.slice(startIndex, startIndex + limit);

    const res: CouponListResp = {
      code: 0,
      total: list.length,
      couponsList: pageList,
    };
    return res;
  }
}
