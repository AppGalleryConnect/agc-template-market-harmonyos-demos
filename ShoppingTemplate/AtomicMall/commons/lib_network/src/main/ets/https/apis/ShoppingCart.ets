import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { UpdateCartReq, DeleteCartReq, CalcCartPriceReq } from '../../types/RequestTypes';
import { CartDataResp, CartListResp, CartPriceResp, CartUpdateResp } from '../../types/responses/CartResponse';
import request from '../Request';

class ShoppingCartApis {
  /**
   * 获取购物车信息
   */
  public getCartData(): Promise<CartDataResp> {
    return request.get(RequestUrlMap.CART_INFO);
  }

  /**
   * 获取购物车列表数据
   */
  public getCartList(): Promise<CartListResp> {
    return request.get(RequestUrlMap.CART_LIST);
  }

  /**
   * 新增购物车商品
   */
  public addSkuToCart(data: UpdateCartReq): Promise<CartUpdateResp> {
    return request.post(RequestUrlMap.CART_PRODUCT, data);
  }

  /**
   * 更新购物车商品数量
   */
  public updateProductSkuCount(data: UpdateCartReq): Promise<CartUpdateResp> {
    return request.put(RequestUrlMap.CART_PRODUCT, data);
  }

  /**
   * 删除购物车商品
   */
  public deleteSkuFromCart(data: DeleteCartReq): Promise<CartUpdateResp> {
    return request.delete(RequestUrlMap.CART_PRODUCT, { data });
  }

  /**
   * 计算购物车金额
   */
  public calcCartPrice(params: CalcCartPriceReq): Promise<CartPriceResp> {
    return request.get(RequestUrlMap.CART_PRICE, { params });
  }
}

const apis = new ShoppingCartApis();

export { apis as ShoppingCartApis };
