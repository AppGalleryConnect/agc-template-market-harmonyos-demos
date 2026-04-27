import { PriceType } from './EnumTypes';
import { AddressInfo, SkuReview, OrderSkuItem } from './OrderTypes';
import { BaseID, CartProductInfo, DiscountItem, PreOrderItem } from './ProductTypes';

export interface OrderUpdateReq {
  status?: number;
  addressInfo?: AddressInfo;
}

export interface OrderReviewReq {
  reviews: SkuReview[];
}

export interface PreOrderInfoReq {
  items: PreOrderItem[];
}

export interface OrderCreateReq {
  skuList: OrderSkuItem[];
  orderInfo: OrderCreateInfo;
}

export interface OrderCreateInfo {
  addressInfo: AddressInfo;
  remark?: string;
  originalPrice: number;
  finalPrice: number;
  discounts: DiscountItem[];
  couponId?: string;
  receivingMethod: number; //1: 快递物流  2: 到店自提
}

export interface ProductListReq {
  curPage: number;
  targetId?: string;
  sortType?: number;
  filterList?: FilterSelectionItem[];
  categoryId?: string;
  keyword?: string;
  slotId?: string;
}

export interface FilterSelectionItem {
  id: string;
  value: string[];
}

export interface UpdateUserPointsReq {
  newPoints: number
  type: number
  label: string
}

export interface UpdateUserInfoReq {
  type: string // avatar nickname phone
  value: string
}

export interface UserLoginReq {
  phoneNumbers?: string
  verifyCode?: string
  unionID?: string
  authorizationCode?: string
}

export interface GetCouponListReq {
  // 用户ID
  userId: string;
  // 优惠券状态: '0'-待使用; '1'-已使用; '2'-已过期
  couponStatus?: number;
  // 分页
  page?: number;
  limit?: number;
}

export interface ClaimCouponReq {
  // 用户ID
  userId: string;
  // 要领取的优惠券ID
  couponId: string;
}

export interface UpdateCouponReq {
  // 用户ID
  userId: string;
  // 优惠券ID
  couponId: string;
  // 更新后的状态: '0'-待使用; '1'-已使用; '2'-已过期
  couponStatus: number;
}

/** 秒杀场次列表请求 */
export interface SeckillSessionReq {
  /** 日期 格式: YYYY-MM-DD，默认今天 */
  date?: string;
}

/** 秒杀商品列表请求 */
export interface SeckillProductListReq {
  /** 时段ID */
  slotId: string;

  /** 当前页码 */
  curPage?: number;

  /** 每页数量 */
  pageSize?: number;
}

/** 商品详情请求 */
export interface ProductDetailReq extends BaseID {
}

/** 预约/取消预约请求 */
export interface SeckillReserveReq {
  /** 商品ID */
  productId: string;

  /** 秒杀ID */
  slotId: string;

  /** 日程ID */
  eventId?: number;
}

/** 购物车操作的最小单元 Key */
export interface CartItemKey {
  skuCode: string;
  priceType: PriceType;
}

/** 更新购物车请求 */
export interface UpdateCartReq extends PreOrderItem {}

/** 删除购物车商品请求 */
export interface DeleteCartReq {
  skuList: CartItemKey[];
  isRemain: boolean;
}

/** 计算购物车价格请求 */
export interface CalcCartPriceReq {
  isMember: boolean;
  skuList: CartProductInfo[];
  extraDiscount?: DiscountItem[];
}

/** 商品收藏请求 */
export interface ProductCollectionReq extends BaseID{
}

/** 商品浏览请求 */
export interface ProductViewReq extends BaseID{
}