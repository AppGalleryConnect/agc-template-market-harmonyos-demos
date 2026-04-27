import { TValueType } from 'common';

export interface SearchImgType {
  // 图片
  img: Resource;
  // 文字
  text: string;
}

export interface HotSearchType {
  name: string;
  rating: string;
  distance: string
}

export interface AttractionCard {
  id: number
  cover: Resource
  title: string
  desc: string
  author: string
  hot: number
  isLiked: boolean
}


/**
 * 基础行程信息接口
 */
export interface BaseTripInfo {
  currentCity: string
  returnCity: string
  startDate: string
  endDate: string
  startLocation: string
  endLocation: string
  duration: string
  price: string
  type: number  // 0: 单程, 1: 往返
}

/**
 * 往返行程信息接口
 */
export interface RoundTripInfo extends BaseTripInfo {
  timeDate: string
  weekDate: string
  trainNumber?: string
  seatClass?: string
  cabinClass?: string
}

/**
 * 订单列表项配置
 */
export interface OrderListItemConfig {
  totalPrice: number
  discountPrice?: number  // 优惠金额
  description: string[]  // 描述信息数组
  orderPageName: string  // 订单页面路由名称
  orderPageBuilder: WrappedBuilder<[Object]>  // 订单页面构建器
  orderData: TValueType  // 订单数据
  onOrderClick?: () => void  // 自定义点击事件
}

/**
 * 座位/舱位类型选择器通用接口
 */
export interface SeatTypeItem {
  type: string
  price: number
  tickets?: number  // 可选，用于火车票
}

/**
 * 座位项接口
 */
export interface TicketSeatItem {
  type: string
  price: number
}
