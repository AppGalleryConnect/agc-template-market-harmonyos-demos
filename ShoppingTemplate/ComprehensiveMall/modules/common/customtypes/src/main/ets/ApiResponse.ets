// 约定 HTTP 响应数据根据以下类型进行封装
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

// 商品卡片、各类活动卡片、订单卡片、购物车卡片 (根据 type 动态选择 model, 构建对应组件)
export interface Card {
  type: string;
  model: object;
}

// 商品分类项 (category_id + 标题 + 图片)
export interface Category {
  id: string;
  label: string;
  iconUrl: string;
}

// 首页核心数据 (商品分类数据 + 活动卡片数据)
export interface Home {
  categoryList: Category[];
  activityCards: Card[];
}

// 推荐数据 (用于在瀑布流中渲染各类卡片, isFinalData 用于标记这段数据是否是最终数据)
export interface GuessLike {
  isFinalData: boolean;
  cards: Card[];
}

export interface CardDataDto {
  isFinalData: boolean;
  cards: Card[];
}

export interface UserDto {
  id: string;
  token: string;
  maskedPhoneNumber: string;
  nickname: string;
}

export interface CartCardDto {
  productId: string;
  skuCode: string;
  skuDesc: string;
  stock: number;
  count: number;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
  isSelected: boolean;
}

export interface CartDto {
  version: string;
  total: number;
  cards: CartCardDto[];
}

export interface OrderSkuDto {
  skuCode: string;
  skuDesc: string;
  count: number;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
}

export interface OrderCardDto {
  type: number;       // 0: 完成(已完成、已取消、已退款), 1: 待付款, 2: 待发货, 3: 待收货, 4: 退款/售后
  orderCode: string;
  statusDesc: string;
  skuList: OrderSkuDto[];
  logisticsInfo: LogisticsItemDto[];
  totalPrice: number;
  time: string;
}

export interface LogisticsItemDto {
  icon: string;
  status: string;
  desc: string;
  time: string;
}

export interface PreOrderInfoDto {
  nickname: string;
  phone: string;
  addressDesc: string;
  totalPrice: number;
  skuList: OrderSkuDto[];
}

export interface OrderInfo {
  type: number;
  productId:string
  skuCode: string;
  skuDesc: string;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
}
