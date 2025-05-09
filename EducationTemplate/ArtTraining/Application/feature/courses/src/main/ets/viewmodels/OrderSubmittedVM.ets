import {
  CoursePaymentMap,
  FrameworkUtil,
  OrderSubmittedRouteParam,
  OrderTabsMap,
  RouterMap,
  RouterModule,
} from 'commonlib';

@ObservedV2
export class OrderSubmittedVM {
  @Trace orderParams: OrderSubmittedRouteParam | null = null;
  private static _instance: OrderSubmittedVM;

  @Computed
  public get orderTips() {
    if (this.orderParams) {
      if (this.orderParams.paymentMethod === CoursePaymentMap.OFFLINE) {
        return '已提交订单，请尽快到店支付';
      } else if (this.orderParams.orderStatus === OrderTabsMap.PENDING_PAYMENT) {
        return '已提交订单，请尽快支付，超时订单将被取消';
      } else if (this.orderParams.orderStatus === OrderTabsMap.COMPLETED) {
        return '订单已支付成功';
      }
    }
    return '';
  }

  public static get instance() {
    if (!OrderSubmittedVM._instance) {
      OrderSubmittedVM._instance = new OrderSubmittedVM();
    }
    return OrderSubmittedVM._instance;
  }

  public getOrderInfo() {
    const param = RouterModule.getNavParam<OrderSubmittedRouteParam>({
      url: RouterMap.COURSE_SUBMITTED,
    });
    if (param) {
      this.orderParams = param;
    }
  }

  public jumpToOrderDetail() {
    if (this.orderParams) {
      RouterModule.push({
        url: RouterMap.MINE_ORDER_DETAIL,
        param: this.orderParams.orderNo,
      });
    }
  }

  public backToHome() {
    FrameworkUtil.backToHome();
  }
}