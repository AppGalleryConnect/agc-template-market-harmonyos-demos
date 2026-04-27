import { RequestUrlMap } from '../../constants/RequestUrlMap';
import {
  SeckillSessionReq,
  SeckillProductListReq,
  SeckillReserveReq,
} from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  SeckillSessionListResp,
  SeckillProductListResp,
  SeckillReserveStatusResp,
  BatchReserveStatusResp,
} from '../../types/responses/ProductResponse';
import request from '../Request';

class SeckillApis {
  // ==================== 秒杀场次相关 ====================

  /**
   * 获取秒杀场次列表(只返回当前时刻之后的)
   * @param params 请求参数
   */
  public getSeckillSessions(
    params?: SeckillSessionReq,
  ): Promise<SeckillSessionListResp> {
    return request.get(RequestUrlMap.SECKILL_SESSIONS, { params });
  }

  // ==================== 秒杀商品相关 ====================

  /**
   * 获取指定时段的秒杀商品列表
   * @param params 请求参数
   */
  public getSeckillProductList(
    params: SeckillProductListReq,
  ): Promise<SeckillProductListResp> {
    return request.get(RequestUrlMap.SECKILL_PRODUCT_LIST, { params });
  }

  // ==================== 预约相关 ====================

  /**
   * 预约秒杀商品
   * @param params 预约参数
   */
  public reserveSeckill(params: SeckillReserveReq): Promise<BaseResponse> {
    return request.post(RequestUrlMap.SECKILL_RESERVE, params);
  }

  /**
   * 取消预约
   * @param params 取消预约参数
   */
  public cancelReservation(eventId: number): Promise<BaseResponse> {
    return request.delete(RequestUrlMap.SECKILL_RESERVE, { params: { eventId } });
  }

  /**
   * 获取单个商品预约状态
   * @param productId 商品ID
   */
  public getReservationStatus(
    params: SeckillReserveReq,
  ): Promise<SeckillReserveStatusResp> {
    return request.get(RequestUrlMap.SECKILL_RESERVE_STATUS, {
      params,
    });
  }

  /**
   * 批量获取预约状态
   */
  public getBatchReservationStatus(): Promise<BatchReserveStatusResp> {
    return request.get(RequestUrlMap.SECKILL_BATCH_RESERVE_STATUS);
  }
}

const instance = new SeckillApis();

export { instance as SeckillApis };
