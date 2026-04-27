import { AppStorageV2 } from '@kit.ArkUI';
import { RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router';
import {
  OrderType,
  OrderDetailInfo,
  MyOrderList,
  OrderInfo,
  OrderStatus,
  PassengerInfo,
  OrderUtil
} from 'common_travel_guide'
import { ReimbursementVoucherPageBuilder } from '../view/ReimbursementVoucherPage'


@ObservedV2
export class TourOrderDetailPageVM {
  @Trace orderInfo: OrderInfo = new OrderInfo(OrderType.SCENIC, 0, '', OrderStatus.BOOKED);
  @Trace detailInfo: OrderDetailInfo = new OrderDetailInfo()
  @Trace passengerInfo: PassengerInfo[] = []
  @Trace orderStatus: OrderStatus = OrderStatus.PENDING;
  @Trace orderStatusText: string = ''
  @Trace orderDescription: string = ''
  @Trace laterPayTime: Date = new Date();
  @Trace countDownTime: string = ''
  @Trace countdownTIme: string = ''
  @Trace orderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Trace payType: string = '' //支付方式
  // 下单时间
  @Trace orderTime: Date = new Date()
  // 支付时间
  @Trace payTime: Date = new Date()
  @Trace isPulUpPay: boolean = false;
  dialogId: number = 0;

  // 计算总价格
  @Computed
  get totalPrice() {
    let price = this.detailInfo?.scenicSchedulePrice ?? 0
    return this.passengerInfo.length * price;
  }

  // 跳转到报销凭证页面
  jumpReimbursementVoucherPage() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.REIMBURSEMENT_VOUCHER_PAGE,
      builder: wrapBuilder(ReimbursementVoucherPageBuilder),
      param: this.totalPrice
    })
  }

  // 再次预定
  bookAgain() {
    this.orderInfo.scenicBookAgain()
  }

  // 我要退订
  applyRefund() {
    this.orderStatus = OrderStatus.REFUNDED
    this.orderStatusText = OrderUtil.getOrderStatusText(this.orderStatus)
    this.orderDescription = this.getOrderDescription(this.orderStatus)
    this.orderInfo.scenicApplyRefund()
  }

  // 取消订单
  cancelOrder() {
    this.orderStatus = OrderStatus.CANCEL
    this.orderStatusText = OrderUtil.getOrderStatusText(this.orderStatus)
    this.orderDescription = this.getOrderDescription(this.orderStatus)
    this.orderInfo.scenicCancelOrder()
  }

  // 拉起支付完成后-处理订单数据
  handleOrderDetailData() {
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    // 下单时间
    const orderTime = this.orderTime;
    const createTimestamp = orderTime.getTime();
    const createTime = `${pad2(orderTime.getHours())}:${pad2(orderTime.getMinutes())}:${pad2(orderTime.getSeconds())}`;
    const createDate = `${orderTime.getFullYear()}-${pad2(orderTime.getMonth() + 1)}-${pad2(orderTime.getDate())}`;
    // 付款时间
    const payTime = this.payTime;
    const payTimestamp = payTime.getTime();
    const payCreateTime = `${pad2(payTime.getHours())}:${pad2(payTime.getMinutes())}:${pad2(payTime.getSeconds())}`;
    const payCreateDate = `${payTime.getFullYear()}-${pad2(payTime.getMonth() + 1)}-${pad2(payTime.getDate())}`;

    // 景点信息
    let scenicMockInfo = this.detailInfo.scenicMockInfo
    const title = scenicMockInfo?.title || ''
    this.detailInfo.scenicOrderNum = `SCENIC${createTimestamp.toString()}`;
    this.detailInfo.scenicPayType = OrderUtil.getPayTypeText(this.payType);
    this.detailInfo.scenicImage = scenicMockInfo?.image
    this.detailInfo.scenicTitle = title
    this.detailInfo.scenicMockInfo = scenicMockInfo
    // 创建时间
    this.detailInfo.scenicCreateTimestamp = createTimestamp
    this.detailInfo.scenicCreateDate = createDate
    this.detailInfo.scenicCreateTime = createTime
    // 付款时间
    this.detailInfo.scenicPayTimestamp = payTimestamp
    this.detailInfo.scenicPayCreateDate = payCreateDate
    this.detailInfo.scenicPayCreateTime = payCreateTime
    this.detailInfo.scenicPayTotalPrice = this.totalPrice
    // 班期信息
    this.orderInfo.price = this.totalPrice
    this.orderInfo.status = OrderStatus.BOOKED
    this.orderInfo.passengerInfo = this.passengerInfo
    this.orderStatusText = OrderUtil.getOrderStatusText(this.orderStatus)
    this.orderDescription = this.getOrderDescription(this.orderStatus)
    // 同步更新我的订单数据
    this.orderInfo.scenicPayedData()
  }

  // 根据不同状态展示不同订单描述文案
  getOrderDescription(status: OrderStatus) {
    let description: string = ''
    switch (status) {
      case OrderStatus.FINISHED:
        description = '您的订单已完成'
        break;
      case OrderStatus.ISSUED:
        description = ''
        break;
      case OrderStatus.BOOKED:
        description = '您的订单已出票，请注意查收'
        break;
      case OrderStatus.PENDING:
        let laterPayTime = this.getLaterPayTime()
        description = `请在${laterPayTime}前完成支付`
        break;
      case OrderStatus.CANCEL:
        description = '您的订单已取消，请重新预定'
        break;
      case OrderStatus.REFUNDED:
        description = '退款金额已到账'
        break;
      default:
        break;
    }
    return description;
  }

  // 获取已取消状态时，需要在mm:ss之前完成交付
  getLaterPayTime() {
    // 对指定时间操作
    let createTime = `${this.detailInfo.scenicCreateDate} ${this.detailInfo.scenicCreateTime}`
    let time = new Date(createTime);
    time.setMinutes(time.getMinutes() + 10);
    this.laterPayTime = time;
    let hours = String(time.getHours()).padStart(2, '0');
    let minutes = String(time.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 到指定时间的倒计时
  countdownTargetTime(targetTime: Date) {
    const target = new Date(targetTime).getTime();
    const timer = setInterval(() => {
      const now = new Date().getTime();
      const distance = target - now;
      if (distance <= 0) {
        clearInterval(timer);
        // 倒计时结束，取消订单
        this.cancelOrder()
        return;
      }
      // 分、秒
      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((distance % (1000 * 60)) / 1000);
      this.countDownTime = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    }, 1000);
  }


  //返回上一级
  backPage() {
    let navPageInfoList = phoneRouterControl.getNavPageInfoList();
    let navPageIndex = navPageInfoList.findIndex((item) => item.pageName === RouterMap.TOUR_PAGE ||
      item.pageName === RouterMap.ORDER_MANAGEMENT_PAGE)
    if (navPageIndex !== -1) {
      let pageName = navPageInfoList[navPageIndex].pageName
      phoneRouterControl.popAppointPageName(pageName, true)
    } else {
      phoneRouterControl.popPage()
    }
  }
}