export interface OrderBasicInfo {
  /*订单编号*/
  orderNo: string;

  /*下单时间*/
  orderTime: string;

  /*订单状态*/
  orderStatus: number;

  /*优惠券id*/
  couponId: number;

  /*下单数量*/
  count: number
}