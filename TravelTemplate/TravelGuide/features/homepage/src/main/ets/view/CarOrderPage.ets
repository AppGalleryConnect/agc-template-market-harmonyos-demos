import { TValueType, RouterMap } from 'common';
import {
  OrderType,
  PlaneDetailListModel, TourOrderRouterParam, TravelPeopleModel
} from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { CarPendingPaymentPageBuilder } from './CarPendingPaymentPage';
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM';
import { BaseOrderPage } from '../components/BaseOrderPage';

@Builder
export function CarOrderPageBuilder(param: TValueType) {
  CarOrderPage({
    pageParam: param
  })
}

@ComponentV2
export struct CarOrderPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: PlaneDetailListModel = this.pageParam as PlaneDetailListModel
  @Local peopleList: TravelPeopleModel[] = []
  
  // 初始化数据
  aboutToAppear(): void {
    this.peopleList = this.dataInfo.peopleList;
    this.dataInfo.returnPrice = (Number(this.dataInfo.price) * this.peopleList.length).toString();
  }
  
  // 渲染行程信息
  @Builder
  renderTripInfo() {
    Column() {
      Row() {
        Text(this.dataInfo.currentCity)
          .fontSize(14)
        Image($r('app.media.ic_right'))
          .width(20)
        Text(this.dataInfo.returnCity)
          .fontSize(14)
          .margin({ right: 8 })
        Text(this.dataInfo.timeDate)
          .fontSize(14)
          .margin({ right: 3 })
        Text(this.dataInfo.weekDate)
          .fontSize(14)
          .margin({ right: 3 })
        Text(this.dataInfo.startDate)
          .fontSize(14)
      }

      Row() {
        Text('行程约' + this.dataInfo.duration)
          .fontSize(10)
          .fontColor('#000')
          .opacity(0.4)
      }
      .margin({ bottom: 9, top: 9 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 21 })
  }
  
  // 获取返回价格
  getReturnPrice(): string {
    return this.dataInfo.returnPrice;
  }
  
  // 处理旅客列表变化
  onPeopleListChange(list: TravelPeopleModel[]): void {
    this.peopleList = list;
    this.dataInfo.peopleList = list;
    const num = list.filter(item => item.isCheck === true).length;
    this.dataInfo.returnPrice = (Number(this.dataInfo.price) * num).toString();
  }

  // 跳转到待支付页面
  jumpToPendingPaymentPage(vm: TicketPendingPaymentVM): void {
    // 设置订单通用信息
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const orderTime = new Date();
    const createTime = `${pad2(orderTime.getHours())}:${pad2(orderTime.getMinutes())}:${pad2(orderTime.getSeconds())}`;
    const createDate = `${orderTime.getFullYear()}-${pad2(orderTime.getMonth() + 1)}-${pad2(orderTime.getDate())}`;

    vm.orderInfo.detailInfo.busGo = this.dataInfo as PlaneDetailListModel
    vm.orderInfo.type = OrderType.BUS;
    vm.orderInfo.price = Number(this.dataInfo.returnPrice);
    vm.orderInfo.getIcon();
    vm.orderInfo.detailInfo.departurePlace = this.dataInfo.startLocation
    vm.orderInfo.detailInfo.destination = this.dataInfo.endLocation
    vm.orderInfo.detailInfo.totalPrice = Number(this.dataInfo.returnPrice)
    vm.orderInfo.detailInfo.busGo.ticketCreateDate = vm.getDate();
    vm.orderInfo.detailInfo.busGo.ticketOrderNum = vm.creatOrderNumber();
    if(vm.isPayment){
      vm.orderInfo.ticketPayedData(OrderType.BUS);
    }
    vm.orderInfo.upTicketDetail();
    vm.orderInfo.detailInfo.createTime = createTime;
    vm.orderInfo.detailInfo.createDate = createDate;
    vm.orderList.add(vm.orderInfo);
    let param: TourOrderRouterParam = {
      orderInfo: vm.orderInfo,
      isPulUpPay: false
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.CAR_PENDING_PAYMENT_PAGE,
      builder: wrapBuilder(CarPendingPaymentPageBuilder),
      param: param
    });
  }

  build() {
    BaseOrderPage({
      pageParam: this.pageParam,
      orderType: OrderType.BUS,
      tradeSummary: '汽车票',
      expiredMessage: '车次已过期，从重新下单',
      renderTripInfo: this.renderTripInfo.bind(this),
      getReturnPrice: this.getReturnPrice.bind(this),
      onPeopleListChange: this.onPeopleListChange.bind(this),
      jumpToPendingPaymentPage: (vm: TicketPendingPaymentVM)=>{
        this.jumpToPendingPaymentPage(vm)
      }
    })
  }
}