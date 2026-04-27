import { PriceType } from './EnumTypes';
import { DiscountItem, ReviewMediaItem } from './ProductTypes';

export interface OrderItem {
  orderInfo: OrderInfo;
  logisticInfo: LogisticsItem[];
  skuInfo: OrderSkuItem[];
}

/** 自提门店信息（用于订单详情展示与导航） */
export interface PickupStoreInfo {
  storeName: string;
  address: string;
  cellphone: string;
  businessHour: string;
  latitude?: number;
  longitude?: number;
}

export interface OrderInfo {
  status: number; // 0: 待付款, 1: 已取消, 2: 待发货, 3: 待收货, 4: 待评价, 5:已评价（已完成）, 6: 退款/售后, 7:已退款, 8: 待取件
  orderNo: string;
  addressInfo: AddressInfo;
  orderTime: number; // 时间戳
  remark?: string;
  originalPrice: number;
  finalPrice: number;
  discounts: DiscountItem[];
  couponId?: string;
  remainingTime?: number;
  refundTime?: string;
  receivingMethod: number; //1: 快递物流  2: 到店自提
  /** 取件码（到店自提订单） */
  pickupCode?: string;

  /** 自提门店（到店自提订单） */
  pickupStoreInfo?: PickupStoreInfo;
}

export interface AddressInfo {
  name: string;
  cellphone: string;
  address: string;
  city?: string;
  latitude?: number,
  longitude?: number
}

export interface OrderSkuItem {
  productId: string;
  skuCode: string;
  skuDesc: string;
  count: number;
  stock: number;
  banner: string;
  title: string;
  serviceDesc: string;
  dashPrice: number;
  price: number;
  priceType: PriceType;
  skuReview?: SkuReview;
  slotId?: string
}

export interface LogisticsItem {
  icon: ResourceStr;
  status: number; //101: 待确认  102:待发货  201: 已发货  202: 已揽收  203:运输中  204:派件中  205:待取件  301:已签收
  details: LogisticsItemDetail[];
  courier?: string
  contactPhone?: string
}

export interface LogisticsItemDetail {
  time: string
  desc: string
}

export interface SkuReview {
  productId: string;
  date: number;
  skuCode: string;
  skuDesc: string;
  rating: number;
  content: string;
  mediaList: ReviewMediaItem[];
}

export interface OrderExpressInfo {
  orderId: string
  expressNo: string
  expressName: string
  courier?: string
  contactPhone?: string
  origins: OrderPosition,
  destination: OrderPosition,
  waypoints: OrderPosition[],
  sendPosition: string,
  getPosition: string,
}

export interface OrderPosition {
  latitude: number,
  longitude: number
}
