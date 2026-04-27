import { RequestUrlMap } from '../../constants/RequestUrlMap';
import {
  PreOrderInfoReq, OrderCreateReq, OrderUpdateReq, OrderReviewReq,
} from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  PreOrderResp,
  OrderListResp,
  OrderDetailResp,
  OrderCreateResp,
  OrderExpressResp,
  DefaultPickupStoreResp,
} from '../../types/responses/OrderResponse';
import request from '../Request';

class OrderApis {
  /**
   * 获取预支付商品信息
   */
  public async getPreOrderInfo(params: PreOrderInfoReq): Promise<PreOrderResp> {
    return request.get(RequestUrlMap.ORDER_PRE_INFO, { params });
  }

  /**
   * 获取默认自提地址（门店）
   */
  public async getDefaultPickupStore(): Promise<DefaultPickupStoreResp> {
    return request.get(RequestUrlMap.ORDER_DEFAULT_PICKUP);
  }

  /**
   * 获取订单列表
   */
  public async getList(
    curPage: number,
    status: number[],
    keywords?: string,
  ): Promise<OrderListResp> {
    return request.get(RequestUrlMap.ORDER_LIST, {
      params: {
        curPage,
        status,
        keywords,
      },
    });
  }

  /**
   * 获取订单详情
   */
  public async getDetail(orderId: string): Promise<OrderDetailResp> {
    return request.get(RequestUrlMap.ORDER_DETAIL, {
      params: {
        orderId,
      },
    });
  }

  /**
   * 获取订单物流信息
   */
  public async getExpressInfo(orderId: string): Promise<OrderExpressResp> {
    return request.get(RequestUrlMap.ORDER_EXPRESS, {
      params: { orderId },
    });
  }

  /**
   * 创建订单
   */
  public async createOrder(data: OrderCreateReq): Promise<OrderCreateResp> {
    return request.post(RequestUrlMap.ORDER_CREATE, data);
  }

  /**
   * 更新订单
   */
  public async updateDetail(
    orderId: string,
    data: OrderUpdateReq,
  ): Promise<BaseResponse> {
    return request.put(RequestUrlMap.ORDER_UPDATE, data, {
      params: { orderId },
    });
  }

  /**
   * 删除订单
   */
  public async deleteDetail(orderId: string): Promise<BaseResponse> {
    return request.delete(RequestUrlMap.ORDER_DELETE, {
      params: {
        orderId,
      },
    });
  }

  /**
   * 添加订单评论
   */
  public async addComment(
    orderId: string,
    data: OrderReviewReq,
  ): Promise<BaseResponse> {
    return request.post(RequestUrlMap.ORDER_ADD_COMMENT, data, {
      params: {
        orderId,
      },
    });
  }
}

const instance = new OrderApis();

export { instance as OrderApis };
