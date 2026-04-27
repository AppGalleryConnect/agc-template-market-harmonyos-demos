export class OrderState {
  static readonly ORDER_STATE_SUCCESS = 0
  static readonly ORDER_STATE_NEED_PAYMENT = 1
  static readonly ORDER_STATE_CANCELED = 2
  static readonly ORDER_STATE_EXPIRED = 3

  public static getOrderStateString(orderState: number) {
    switch (orderState) {
      case OrderState.ORDER_STATE_SUCCESS:
        return '预约成功'
      case OrderState.ORDER_STATE_NEED_PAYMENT:
        return '待支付'
      case OrderState.ORDER_STATE_CANCELED:
        return '已取消'
      case OrderState.ORDER_STATE_EXPIRED:
        return '已过期'
      default:
        return '未知'
    }
  }
}