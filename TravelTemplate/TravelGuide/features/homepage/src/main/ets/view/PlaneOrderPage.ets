import { TValueType, RouterMap } from 'common';
import {
  OrderType,
  PlaneDetailListModel,
  PlaneReturnDetailListModel,
  TourOrderRouterParam,
  TravelPeopleModel,
} from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { PlanePendingPaymentPageBuilder } from './PlanePendingPaymentPage';
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM';
import { BaseOrderPage } from '../components/BaseOrderPage';

@Builder
export function PlaneOrderPageBuilder(param: TValueType) {
  PlaneOrderPage({
    pageParam: param
  })
}

@ComponentV2
export struct PlaneOrderPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: PlaneReturnDetailListModel = this.pageParam as PlaneReturnDetailListModel
  @Local peopleList: TravelPeopleModel[] = []
  @Local goPrice: number = 0
  @Local backPrice: number = 0
  
  // 初始化数据
  aboutToAppear(): void {
    this.peopleList = this.dataInfo.planeGo.peopleList;
    this.goPrice = Number(this.dataInfo.planeGo.price);
    this.backPrice = Number(this.dataInfo.planeBack.price);
    this.dataInfo.planeGo.returnPrice = (Number(this.goPrice + this.backPrice) * this.peopleList.length).toString();
  }
  
  // 渲染行程信息
  @Builder
  renderTripInfo() {
    if (this.dataInfo.planeGo.type === 0) {
      // 单程
      Column() {
        Row() {
          Text(this.dataInfo.planeGo.currentCity)
            .fontSize(14)
          Image($r('app.media.ic_right'))
            .width(20)
          Text(this.dataInfo.planeGo.returnCity)
            .fontSize(14)
            .margin({ right: 8 })
          Text(this.dataInfo.planeGo.timeDate)
            .fontSize(14)
            .margin({ right: 3 })
          Text(this.dataInfo.planeGo.weekDate)
            .fontSize(14)
            .margin({ right: 3 })
          Text(this.dataInfo.planeGo.startDate)
            .fontSize(14)
        }

        Row() {
          Text('成人¥' + this.dataInfo.planeGo.price)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          Text(' | 车次' + this.dataInfo.planeGo.trainNumber)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
        .margin({ bottom: 9, top: 9 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 21 })
    } else {
      // 往返
      Column() {
        Row() {
          Text('去程')
            .fontSize(10)
            .padding(4)
            .borderRadius(4)
            .backgroundColor('#FEE231')
          Row() {
            Text(this.dataInfo.planeGo.currentCity)
              .fontSize(14)
            Image($r('app.media.ic_right'))
              .width(20)
            Text(this.dataInfo.planeGo.returnCity)
              .fontSize(14)
              .margin({ right: 10 })
            Text(this.dataInfo.planeGo.timeDate)
              .fontSize(14)
            Text(this.dataInfo.planeGo.weekDate)
              .fontSize(14)
              .margin({ right: 3, left: 3 })
            Text(this.dataInfo.planeGo.startDate)
              .fontSize(14)
          }
        }

        Row() {
          Text('成人¥' + this.dataInfo.planeGo.price)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          Text(' | 车次' + this.dataInfo.planeGo.trainNumber)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
        .margin({ bottom: 9, top: 9 })

      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 21 })

      Column() {
        Row() {
          Text('返程')
            .fontSize(10)
            .padding(4)
            .borderRadius(4)
            .backgroundColor('#FEE231')
          Row() {
            Text(this.dataInfo.planeBack.returnCity)
              .fontSize(14)
            Image($r('app.media.ic_right'))
              .width(20)
            Text(this.dataInfo.planeBack.currentCity)
              .fontSize(14)
              .margin({ right: 10 })
            Text(this.dataInfo.planeBack.timeDate)
              .fontSize(14)
            Text(this.dataInfo.planeBack.weekDate)
              .fontSize(14)
              .margin({ right: 3, left: 3 })
            Text(this.dataInfo.planeBack.startDate)
              .fontSize(14)
          }
        }

        Row() {
          Text('成人¥' + this.dataInfo.planeBack.price)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          Text(' | 车次' + this.dataInfo.planeBack.trainNumber)
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
  }
  
  // 获取返回价格
  getReturnPrice(): string {
    return this.dataInfo.planeGo.returnPrice;
  }
  
  // 处理旅客列表变化
  onPeopleListChange(list: TravelPeopleModel[]): void {
    this.peopleList = list;
    this.dataInfo.planeGo.peopleList = list;
    const num = list.filter(item => item.isCheck === true).length;
    this.dataInfo.planeGo.returnPrice = (Number(this.goPrice + this.backPrice) * num).toString();
  }
  
  // 跳转到待支付页面
  jumpToPendingPaymentPage(vm: TicketPendingPaymentVM): void {
    // 设置订单通用信息
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const orderTime = new Date();
    const createTime = `${pad2(orderTime.getHours())}:${pad2(orderTime.getMinutes())}:${pad2(orderTime.getSeconds())}`;
    const createDate = `${orderTime.getFullYear()}-${pad2(orderTime.getMonth() + 1)}-${pad2(orderTime.getDate())}`;

    vm.orderInfo.detailInfo.planeGo = this.dataInfo.planeGo as PlaneDetailListModel
    vm.orderInfo.detailInfo.planeBack = this.dataInfo.planeBack as PlaneDetailListModel
    vm.orderInfo.type = OrderType.TRAIN;
    vm.orderInfo.detailInfo.departurePlace = this.dataInfo.planeGo.startLocation
    vm.orderInfo.detailInfo.destination = this.dataInfo.planeGo.endLocation
    vm.orderInfo.price = Number(this.dataInfo.planeGo.returnPrice);
    vm.orderInfo.detailInfo.planeGo.ticketCreateDate = vm.getDate();
    vm.orderInfo.detailInfo.planeGo.ticketOrderNum = vm.creatOrderNumber();
    if(vm.isPayment){
      vm.orderInfo.ticketPayedData(OrderType.TRAIN);
    }
    vm.orderInfo.upTicketDetail();
    vm.orderInfo.getIcon();
    vm.orderInfo.tag = 1;
    vm.orderInfo.detailInfo.createTime = createTime;
    vm.orderInfo.detailInfo.createDate = createDate;
    vm.orderList.add(vm.orderInfo);
    let param: TourOrderRouterParam = {
      orderInfo: vm.orderInfo,
      isPulUpPay: false
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.PLANE_PENDING_PAYMENT_PAGE,
      builder: wrapBuilder(PlanePendingPaymentPageBuilder),
      param: param
    });
  }

  build() {
    BaseOrderPage({
      pageParam: this.pageParam,
      orderType: OrderType.TRAIN,
      tradeSummary: '火车票',
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