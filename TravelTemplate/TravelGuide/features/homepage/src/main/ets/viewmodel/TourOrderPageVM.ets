import { AppStorageV2 } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';
import { RouterMap } from 'common';
import { TravelPeopleModel } from 'common_travel_guide';
import { TourOrderDetailPageBuilder } from '../view/TourOrderDetailPage';
import {
  MyOrderList,
  OrderDetailInfo,
  OrderInfo,
  OrderStatus,
  OrderType,
  OrderUtil,
  PassengerInfo,
  TourModel,
  TourOrderRouterParam,
  TravelerModel
} from 'common_travel_guide';


@ObservedV2
export class TourOrderPageVM {
  @Trace scenicMockInfo: TourModel | null = null
  @Trace orderPrice: number = 0
  @Trace starTime: string = ''
  @Trace endTime: string = ''
  @Trace scheduleDateCode: string = ''
  @Trace grownManNum: number = 0
  @Trace childrenNum: number = 0
  @Trace orderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Trace travelPersonList: TravelPeopleModel[] = []
  @Trace orderStatus: OrderStatus = OrderStatus.BOOKED;
  @Trace orderDetailInfo: OrderDetailInfo = new OrderDetailInfo()
  @Trace payType: string = '' //支付方式
  @Trace selectPersonNum: number = 0 // 选中的人员数量
  @Trace contactPhone: string | number = '' // 联系人电话

  // 下单时间
  @Trace orderTime: Date = new Date()
  // 支付时间
  @Trace payTime: Date = new Date()

  // 计算总价格
  @Computed
  get totalPrice() {
    return this.selectPersonNum * this.orderPrice;
  }

  countFieldValues(array: TravelerModel[]) {
    return array.filter(item => item.select === true).length;
  }

  // 回显出行人信息
  getTravelPersonList(list: PassengerInfo[]) {
    this.travelPersonList = []
    list.forEach((personItem: PassengerInfo) => {
      let travelPerson: TravelPeopleModel = {
        name: personItem.name,
        idNumber: personItem.idNumber,
        phone: personItem.phone,
        isCheck: true,
      }
      this.travelPersonList.push(travelPerson)
    })
  }

  // 处理订单数据
  handleOrderDetailData() {
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    // 选择的出行人
    let passengerList: PassengerInfo[] = []
    this.travelPersonList.forEach((personItem: TravelPeopleModel) => {
      let passengerInfo = new PassengerInfo()
      passengerInfo.name = personItem.name
      passengerInfo.phone = personItem.phone
      passengerInfo.idNumber = personItem.idNumber
      passengerList.push(passengerInfo)
    })
    let detailInfo: OrderDetailInfo = new OrderDetailInfo()
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
    const title = this.scenicMockInfo?.title || ''
    detailInfo.scenicImage = this.scenicMockInfo?.image
    detailInfo.scenicTitle = title
    detailInfo.scenicMockInfo = this.scenicMockInfo
    // 订单信息
    detailInfo.scenicOrderNum = `SCENIC${createTimestamp.toString()}`;
    detailInfo.scenicPayType = OrderUtil.getPayTypeText(this.payType);
    detailInfo.scenicGrownManNum = this.grownManNum
    detailInfo.scenicChildrenNum = this.childrenNum
    detailInfo.scenicContactPhone = this.contactPhone
    // 创建时间
    detailInfo.scenicCreateTimestamp = createTimestamp
    detailInfo.scenicCreateDate = createDate
    detailInfo.scenicCreateTime = createTime
    // 付款时间
    detailInfo.scenicPayTimestamp = payTimestamp
    detailInfo.scenicPayCreateDate = payCreateDate
    detailInfo.scenicPayCreateTime = payCreateTime
    detailInfo.scenicPayTotalPrice = this.totalPrice

    // 班期信息
    detailInfo.scenicScheduleDate = this.scheduleDateCode
    detailInfo.scenicSchedulePrice = this.orderPrice
    detailInfo.scenicStarTime = this.starTime
    detailInfo.scenicEndTime = this.endTime
    detailInfo.startTime = this.starTime // 开始时间
    detailInfo.endTime = this.endTime // 结束时间

    let orderInfo: OrderInfo = new OrderInfo(
      OrderType.SCENIC,
      this.totalPrice,
      title,
      this.orderStatus,
      detailInfo
    )
    orderInfo.passengerInfo = passengerList
    this.orderList.add(orderInfo)
    // 跳转订单详情页面
    this.jumpTourOrderDetailPage(orderInfo);
  }

  // 跳转订单详情页面
  jumpTourOrderDetailPage(orderInfo: OrderInfo) {
    let param: TourOrderRouterParam = {
      orderInfo: orderInfo,
      isPulUpPay: false
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TOUR_ORDER_DETAIL_PAGE,
      builder: wrapBuilder(TourOrderDetailPageBuilder),
      param: param
    })
  }
}