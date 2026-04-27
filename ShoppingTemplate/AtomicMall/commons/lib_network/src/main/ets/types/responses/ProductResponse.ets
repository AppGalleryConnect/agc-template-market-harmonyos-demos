import { BaseResponse } from './BaseResponse';
import {
  ProductSelectionInfo,
  ProductReviewItem,
  ProductCardItem,
  SeckillProductInfo,
  SeckillSession,
  ProductInfo,
  ReservedProductInfo,
} from '../ProductTypes';


/** 商品列表响应 */
export interface ProductListResp extends BaseResponse {
  list: ProductCardItem[];
  curPage: number;
  isFinal: boolean;
  total: number;
}

/** 商品详情响应 */
export interface ProductDetailResp extends BaseResponse {
  data: ProductInfo;
}

/** 商品库存响应 */
export interface ProductStockResp extends BaseResponse {
  data: ProductSelectionInfo;
}

/** 商品收藏状态响应 */
export interface ProductCollectStatusResp extends BaseResponse {
  status: number; // 0:未收藏 1:已收藏
}

/** 商品评价响应 */
export interface ProductReviewResp extends BaseResponse {
  list: ProductReviewItem[];
  curPage: number;
  isFinal: boolean;
  total: number;
  avgRating: number; // 平均评分
}

export interface SeckillSessionListResp extends BaseResponse {
  /** 场次列表(只返回当前时刻之后的) */
  sessions: SeckillSession[];
  /** 当前进行中的时段ID，如果没有则为空 */
  currentSlotId?: string;
}

/** 秒杀商品列表响应 */
export interface SeckillProductListResp extends BaseResponse {
  /** 秒杀商品列表 */
  list: SeckillProductInfo[];
  /** 当前页码 */
  curPage: number;
  /** 是否最后一页 */
  isFinal: boolean;
  /** 总数 */
  total: number;
}

/** 预约状态响应 */
export interface SeckillReserveStatusResp extends BaseResponse {
  /** 是否已预约 */
  isReserved: boolean;
  /** 日程ID */
  eventId?: number;
}

/** 批量预约状态响应 */
export interface BatchReserveStatusResp extends BaseResponse {
  /** 已预约的商品ID集合 */
  reservedProducts: ReservedProductInfo[];
}
