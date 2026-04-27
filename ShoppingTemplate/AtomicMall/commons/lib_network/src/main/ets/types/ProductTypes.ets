import { PriceType, ReviewMediaType, SeckillStatus } from './EnumTypes';

/** 商品 SKU 基础信息 */
export interface BaseSku {
  skuCode: string;
  stock: number;
  price: number;
  dashPrice: number;
}

/** 商品ID 基础信息 */
export interface BaseID {
  productId: string
  slotId?: string
}

/** 购物车/列表展示用的 SKU */
export interface ProductSku extends BaseSku, BaseID {
  skuDesc: string;
  banner: string;
  title: string;
  serviceDesc: string;
  priceType: PriceType;
}

/** 存储在本地的购物车项结构（包含选中状态等本地状态） */
export interface CartSkuItem extends BaseSku, BaseID {
  skuDesc: string;
  count: number;
  banner: string;
  title: string;
  serviceDesc: string;
  isSelected: boolean;
  priceType: PriceType;
}

export interface CartProductInfo extends ProductSku {
  count: number
}

/** 详情页规格选择用的 SKU */
export interface SpecSku extends BaseSku {
  specs: Record<string, string>;
}

/** 商品标签 */
export interface ProductCardLabel {
  preset: number;
  data: string;
}

/** 商品概况 */
export interface ProductSummary {
  size: string[];
  minPrice: number;
  maxPrice: number;
  place: string;
}

/** 商品卡片基础信息 */
export interface BaseProductCard extends BaseID {
  title: string;
  banner: string;
  price: number;
  dashPrice: number;
}

/** 规格选项值 */
export interface SpecValue {
  id: string;
  text: string;
  image?: ResourceStr;
}

/** 规格选项 */
export interface SpecOption {
  key: string;
  label: string;
  values: SpecValue[];
}

/** 商品详情信息（扩展类型） */
export interface ProductDetailLabel {
  icon: ResourceStr;
  content: string;
}

/** 商品卡片（包含额外展示信息） */
export interface ProductCardItem extends BaseProductCard {
  categoryId: string;
  promotion: string[];
  label: ProductCardLabel[];
  summary: ProductSummary;
  sales: number;
}

/** 商品详情信息 */
export interface ProductDetailInfo extends BaseProductCard {
  sales: number;
  tags: string[];
  logistics: Array<ProductDetailLabel>;
  service: Array<ProductDetailLabel>;
  pictures: ResourceStr[];
  banners: string[];
  selectionInfo: ProductSelectionInfo;
}

/** 商品规格选择信息 */
export interface ProductSelectionInfo {
  defaultBanner: ResourceStr;
  basicPrice: number;
  priceRange: string;
  priceRemark: string;
  totalPriceRemark: string;
  services: string[];
  skuItems: SpecSku[];
  specOptions?: SpecOption[];
  specOptionWithImage?: SpecOption;
}

/** 商品评价条目 */
export interface ProductReviewItem {
  productId: string;
  userAvatar: ResourceStr;
  userName: string;
  skuCode: string;
  skuDesc: string[];
  rating: number;
  date: number;
  content: string;
  mediaList: Array<ReviewMediaItem>;
}

export interface MovingPhotoUri {
  imageUri: string
  videoUri: string
}

/** 商品评价媒体资源 */
export interface ReviewMediaItem {
  uri: ResourceStr;
  movingPhotoUri?: MovingPhotoUri
  type: ReviewMediaType;
}


export interface BaseSeckillTimeInfo {
  /** 时段ID */
  slotId: string;

  /** 开始时间(时:分) 如: "10:00" */
  startTime: string;

  /** 结束时间(时:分) 如: "12:00" */
  endTime: string;
}

/** 秒杀时段 */
export interface SeckillTimeSlot extends BaseSeckillTimeInfo {
  /** 开始时间戳 */
  startTimestamp: number;

  /** 结束时间戳 */
  endTimestamp: number;

  /** 时段状态 */
  status: SeckillStatus;
}

/** 秒杀商品信息 */
export interface SeckillProductInfo extends BaseProductCard {
  /** 秒杀活动ID */
  seckillId: string;

  /** 时段ID */
  slotId: string;

  /** 商品类型 */
  categoryId: string;

  /** 秒杀价 */
  seckillPrice: number;

  /** 总库存 */
  totalStock: number;

  /** 剩余库存 */
  remainStock: number;
}

/** 秒杀场次 */
export interface SeckillSession {
  /** 时段信息 */
  timeSlot: SeckillTimeSlot;

  /** 秒杀商品列表 */
  productList: SeckillProductInfo[];
}

/** 商品详情页数据 */
export interface ProductInfo {
  /** 商品基础信息 */
  productDetail: ProductDetailInfo;

  /** 秒杀信息（如果商品在秒杀中） */
  seckillInfo?: SeckillProductInfo;

  /** 时段信息 */
  timeSlot?: SeckillTimeSlot;

  /** 是否预约 */
  isReserved?: boolean
  /** 是否已购买 */
  hasPurchased?: boolean
}

export interface ReservedProductInfo {
  productId: string
  slotId: string
  eventId: number
}

/** 优惠项 */
export interface DiscountItem {
  type: number;
  label: string;
  discountPrice: number;
}

/** 购物车价格详情 */
export interface CartPrice {
  originalPrice: number;
  discountList: DiscountItem[];
  finalPrice: number;
}

/** 购物车数据传输对象 */
export interface CartDto {
  version: string;
  total: number;
  cards: CartSkuItem[];
}

/** 预下单商品sku信息 */
export interface PreOrderItem {
  skuCode: string;
  count: number;
  priceType: PriceType
  seckillInfo?: CartItemSeckillInfo
}

export interface CartItemSeckillInfo {
  slotId: string
  productId: string
  seckillPrice: number
}
