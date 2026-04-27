import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { SkuReview } from '../../types/OrderTypes';
import { ProductCollectionReq, ProductListReq, ProductViewReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  ProductCollectStatusResp,
  ProductListResp,
  ProductDetailResp,
  ProductStockResp,
  ProductReviewResp,
} from '../../types/responses/ProductResponse';
import request from '../Request';

class ProductApis {
  // ==================== 商品列表相关 ====================

  /**
   * 获取商品列表
   * @param params 查询参数
   */
  public getProductList(params: ProductListReq): Promise<ProductListResp> {
    return request.get(RequestUrlMap.PRODUCT_LIST, { params });
  }

  // ==================== 商品详情相关 ====================

  /**
   * 获取商品详情
   * @param id 商品ID
   */
  public getProductDetail(productId: string, slotId?: string): Promise<ProductDetailResp> {
    return request.get(RequestUrlMap.PRODUCT_DETAIL, {
      params: { productId,
slotId },
    });
  }

  /**
   * 获取商品库存和规格信息
   * @param id 商品ID
   */
  public getProductStockInfo(id: string): Promise<ProductStockResp> {
    return request.get(RequestUrlMap.PRODUCT_STOCK, { params: { id } });
  }

  // ==================== 商品评价相关 ====================

  /**
   * 获取商品评价列表
   * @param id 商品ID
   * @param curPage 当前页码
   */
  public getProductReviewList(
    id: string,
    curPage: number = 1,
  ): Promise<ProductReviewResp> {
    return request.get(RequestUrlMap.PRODUCT_REVIEW, {
      params: { id,
curPage },
    });
  }

  /**
   * 创建商品评价
   * @param data 商品评价信息
   * @returns
   */
  public createProductReview(data:SkuReview[]): Promise<BaseResponse>{
    return request.post(RequestUrlMap.PRODUCT_REVIEW, data);
  }

  // ==================== 商品收藏相关 ====================

  /**
   * 收藏商品
   * @param productId 商品ID
   */
  public collectProduct(params: ProductCollectionReq): Promise<BaseResponse> {
    return request.get(RequestUrlMap.PRODUCT_COLLECT, {params});
  }

  /**
   * 取消收藏商品
   * @param productIds 商品ID列表
   */
  public cancelCollectProduct(productIds: string[]): Promise<BaseResponse> {
    return request.delete(RequestUrlMap.PRODUCT_COLLECT, {
      params: { productIds: productIds.join(',') },
    });
  }

  /**
   * 获取收藏商品列表
   * @param params 查询参数
   */
  public getCollectedProductList(
    params: ProductListReq,
  ): Promise<ProductListResp> {
    return request.get(RequestUrlMap.PRODUCT_COLLECTED_LIST, { params });
  }

  /**
   * 获取指定商品的收藏状态
   * @param productId 商品ID
   */
  public getProductCollectStatus(
    productId: string,
  ): Promise<ProductCollectStatusResp> {
    return request.get(RequestUrlMap.PRODUCT_COLLECT_STATUS, {
      params: { productId },
    });
  }

  // ==================== 浏览记录相关 ====================

  /**
   * 添加浏览记录
   * @param productId 商品ID
   */
  public addProductViewHistory(data: ProductViewReq): Promise<BaseResponse> {
    return request.post(RequestUrlMap.PRODUCT_VIEW_HISTORY, data);
  }

  /**
   * 删除浏览记录
   * @param productIds 商品ID列表
   */
  public deleteProductViewHistory(productIds: string[]): Promise<BaseResponse> {
    return request.delete(RequestUrlMap.PRODUCT_VIEW_HISTORY, {
      params: { productIds: productIds.join(',') },
    });
  }

  /**
   * 获取浏览记录列表
   * @param params 查询参数
   */
  public getProductViewHistory(
    params: ProductListReq,
  ): Promise<ProductListResp> {
    return request.get(RequestUrlMap.PRODUCT_VIEW_HISTORY_LIST, { params });
  }
}

const instance = new ProductApis();

export { instance as ProductApis };
