/**
 * 价格类型枚举
 */
export enum PriceType {
  NORMAL = 0, // 正价
  SECKILL = 1, // 秒杀
  POINT = 2 // 积分兑换
}

/** 秒杀状态 */
export enum SeckillStatus {
  /** 等待开始(可预约) */
  WAITING = 0,
  /** 进行中(可抢购) */
  ONGOING = 1,
  /** 已结束 */
  ENDED = 2,
}

/** 订单状态 */
export enum OrderStatus {
  /** 待付款 */
  PENDING_PAYMENT = 0,
  /** 已取消 */
  CANCELED = 1,
  /** 待发货 */
  PENDING_SHIPMENT = 2,
  /** 待收货 */
  PENDING_RECEIPT = 3,
  /** 待评价 */
  PENDING_REVIEW = 4,
  /** 已评价（已完成） */
  REVIEWED = 5,
  /** 退款/售后 */
  REFUND_IN_PROGRESS = 6,
  /** 已退款 */
  REFUNDED = 7,
  /** 待取件（到店自提） */
  PENDING_PICKUP = 8,
}

/** 配送方式 */
export enum ShippingOption {
  EXPRESS = 0,
  SELF_PICK_UP = 1,
}

/** 评论媒体资源类型 */
export enum ReviewMediaType {
  IMAGE,
  MOVING_PHOTO,
  VIDEO,
}