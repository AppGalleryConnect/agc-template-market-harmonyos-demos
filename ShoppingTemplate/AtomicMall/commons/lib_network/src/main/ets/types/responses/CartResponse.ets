import { BaseResponse } from './BaseResponse';
import { CartDto, CartPrice, CartProductInfo } from '../ProductTypes';

/** 购物车完整数据响应 */
export interface CartDataResp extends BaseResponse {
  data: CartDto;
}

/** 购物车列表数据响应 */
export interface CartListResp extends BaseResponse {
  data: CartProductInfo[];
}

/** 购物车操作响应（增删改） */
export interface CartUpdateResp extends BaseResponse {
  data: number;
}

/** 购物车价格计算响应 */
export interface CartPriceResp extends BaseResponse {
  data: CartPrice;
}
