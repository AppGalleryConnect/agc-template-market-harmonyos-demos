import { AccountUtil } from 'account';
import { https, Mock } from 'network';
import { Order, Passenger } from 'type';
import { Constants, OrderTabBarType } from 'constant';
import { CalenderUtil, DateModel } from 'calendar';

@ObservedV2
export class OrderPageVM {
  @Trace openId: string | undefined = AccountUtil.getOpenId();
  @Trace orderList: Order[] = [];
  @Trace orders: Order[] = [];
  private static _instance: OrderPageVM;

  getOrdersByType(orderTabIndex: number, orderTypeTabIndex: number) {
    if (orderTabIndex === OrderTabBarType.ALL) {
      this.orders = this.orderList.filter((item: Order) => item.orderType === orderTypeTabIndex);
      return;
    }
    this.orders = this.orderList.filter((item: Order) => item.orderStatus === orderTabIndex &&
      item.orderType === orderTypeTabIndex);
  }

  async getOrderList() {
    const res = await https.queryOrderList(this.openId ?? '');
    if (res.code === 200) {
      this.orderList = this.mapOrderInfo(res.data);
    }
  }

  mapOrderInfo(records: Order[]) {
    let list: Order[] = [];
    records.forEach((item: Order) => {
      let orderItem: Order = {
        id: item.id ?? 0,
        orderSn: item.orderSn ?? '',
        passengerId: item.passengerId ?? 0,
        passengerName: item.passengerName ?? '',
        passengerPhone: item.passengerPhone ?? '',
        commodityId: item.commodityId ?? 0,
        orderName: item.orderName ?? '',
        orderStatus: item.orderStatus ?? 0,
        orderType: item.orderType ?? 0,
        orderRemark: item.orderRemark ?? '',
        goodsBanner: item.goodsBanner ?? '',
        goodsCounterPrice: item.goodsCounterPrice ?? 0,
        goodsRetailPrice: item.goodsRetailPrice ?? 0,
        goodsCount: item.goodsCount ?? 0,
        roomTypeBanner: item.roomTypeBanner ?? '',
        roomTypeOriginalPrice: item.roomTypeOriginalPrice ?? 0,
        roomTypeActualPrice: item.roomTypeActualPrice ?? 0,
        planCheckInDate: item.planCheckInDate ?? '',
        planCheckOutDate: item.planCheckOutDate ?? '',
        dayCount: item.dayCount ?? 0,
        orderTotalPrice: item.orderTotalPrice ?? 0,
        rule: item.rule ?? '',
        openId: item.openId ?? '',
        appId: item.appId ?? '',
        createTime: item.createTime ?? '',
        updateTime: item.updateTime ?? '',
        servicePhone: item.servicePhone ?? '',
        count: item.count ?? 1,
        amount: item.amount ?? 0,
        sfc: item.sfc ?? '',
      };

      // 本地mock场景
      if (Constants.MODE === 'MOCK') {
        this.handleLocalOrderInfoBy(orderItem);
      }

      list.push(orderItem);
    });
    return list;
  }

  handleLocalOrderInfoBy(orderItem: Order) {
    orderItem.servicePhone = '12345678901';
    // 民宿订单
    if (orderItem.orderType === 0) {
      let room = Mock.ROOM_TYPE.find((item) => item.id === orderItem.id);
      orderItem.orderName = room?.roomTypeName ?? '';
      orderItem.roomTypeBanner = room?.roomTypeBanner ?? '';

      let passengers: string | undefined = AppStorage.get('psgList');

      if (this.isOverdue(orderItem)) {
        // 超过入住日期变成已完成
        orderItem.orderStatus = OrderTabBarType.READY;
      }

      if (passengers && passengers?.length !== 0) {
        let list: Passenger[] = JSON.parse(passengers);
        let passenger: Passenger | undefined =
          list.find((item: Passenger) => item.passengerId === orderItem.passengerId);
        if (passenger) {
          orderItem.passengerName = passenger.passengerName;
          orderItem.passengerPhone = passenger.passengerPhone;
        }
      }
    } else {
      let commodity = Mock.COMMODITY.data.records.find((item) => item.id === orderItem.commodityId);
      orderItem.orderName = commodity?.goodsName ?? '';
      orderItem.goodsRetailPrice =
        commodity?.retailPrice[commodity?.specification.split(',').indexOf(orderItem.sfc)] ?? 0;
      orderItem.goodsBanner = commodity?.banner ?? '';
    }
  }

  isOverdue(orderItem: Order) {
    let result = false;
    let dueTime = orderItem.planCheckInDate;
    let curTime: DateModel = CalenderUtil.getCurrentDate() ?? new DateModel(0, 0, 0, 0);

    let timeArr = dueTime.split('-');

    if (Number(timeArr[0]) < curTime.year ||
      (Number(timeArr[0]) === curTime.year && Number(timeArr[1]) < curTime.month) ||
      (Number(timeArr[0]) === curTime.year && Number(timeArr[1]) === curTime.month &&
        Number(timeArr[2]) < curTime.day)) {
      return true;
    }

    return result;
  }

  public static get instance() {
    if (!OrderPageVM._instance) {
      OrderPageVM._instance = new OrderPageVM();
    }
    return OrderPageVM._instance;
  }
}
