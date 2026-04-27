import { TValueType, RouterMap } from 'common';
import {
  OrderType,
  TicketDetailListModel,
  TicketReturnDetailListModel,
  TourOrderRouterParam,
  TravelPeopleModel,
} from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { TicketPendingPaymentPageBuilder } from './TicketPendingPaymentPage';
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM';
import { BaseOrderPage } from '../components/BaseOrderPage';

@Builder
export function TicketOrderPageBuilder(param: TValueType) {
  TicketOrderPage({
    pageParam: param
  })
}

@ComponentV2
export struct TicketOrderPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: TicketReturnDetailListModel = this.pageParam as TicketReturnDetailListModel
  @Local peopleList: TravelPeopleModel[] = []
  @Local goPrice: number = 0
  @Local backPrice: number = 0
  
  // 初始化数据
  aboutToAppear(): void {
    this.peopleList = this.dataInfo.ticketGo.peopleList;
    this.goPrice = Number(this.dataInfo.ticketGo.price);
    this.backPrice = Number(this.dataInfo.ticketBack.price);
    this.dataInfo.ticketGo.returnPrice = (Number(this.goPrice + this.backPrice) * this.peopleList.length).toString();
  }
  
  // 渲染行程信息
  @Builder
  renderTripInfo() {
    if (this.dataInfo.ticketGo.type === 0) {
      // 单程
      Column() {
        Row() {
          Text(this.dataInfo.ticketGo.currentCity)
            .fontSize(14)
          Image($r('app.media.ic_right'))
            .width(20)
          Text(this.dataInfo.ticketGo.returnCity)
            .fontSize(14)
            .margin({ right: 8 })
          Text(this.dataInfo.ticketGo.timeDate)
            .fontSize(14)
            .margin({ right: 3 })
          Text(this.dataInfo.ticketGo.weekDate)
            .fontSize(14)
            .margin({ right: 3 })
          Text(this.dataInfo.ticketGo.startDate)
            .fontSize(14)
        }

        Row() {
          Text('成人¥' + this.dataInfo.ticketGo.price)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          Text('+机建燃油¥70')
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
        .margin({ bottom: 9, top: 9 })

        Row() {
          Image($r('app.media.ic_aviation_01'))
            .width(14)
            .height(14)
          Text(`国航｜${this.dataInfo.ticketGo.aviation}｜${this.dataInfo.ticketGo.boeing}｜有餐食`)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
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
            Text(this.dataInfo.ticketGo.currentCity)
              .fontSize(14)
            Image($r('app.media.ic_right'))
              .width(20)
            Text(this.dataInfo.ticketGo.returnCity)
              .fontSize(14)
            Text(this.dataInfo.ticketGo.timeDate)
              .fontSize(14)
            Text(this.dataInfo.ticketGo.weekDate)
              .fontSize(14)
              .margin({ right: 3, left: 3 })
            Text(this.dataInfo.ticketGo.startDate)
              .fontSize(14)
          }
        }

        Row() {
          Text('成人¥' + this.dataInfo.ticketGo.price)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          Text('+机建燃油¥70')
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
        .margin({ bottom: 9, top: 9 })

        Row() {
          Image($r('app.media.ic_aviation_01'))
            .width(14)
            .height(14)
          Text(`国航｜${this.dataInfo.ticketGo.aviation}｜${this.dataInfo.ticketGo.boeing}｜有餐食`)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
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
            Text(this.dataInfo.ticketBack.returnCity)
              .fontSize(14)
            Image($r('app.media.ic_right'))
              .width(20)
            Text(this.dataInfo.ticketBack.currentCity)
              .fontSize(14)
            Text(this.dataInfo.ticketBack.timeDate)
              .fontSize(14)
            Text(this.dataInfo.ticketBack.weekDate)
              .fontSize(14)
              .margin({ right: 3, left: 3 })
            Text(this.dataInfo.ticketBack.startDate)
              .fontSize(14)
          }
        }

        Row() {
          Text('成人¥' + this.dataInfo.ticketBack.price)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          Text('+机建燃油¥70')
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
        .margin({ bottom: 9, top: 9 })

        Row() {
          Image($r('app.media.ic_aviation_01'))
            .width(14)
            .height(14)
          Text(`国航｜${this.dataInfo.ticketBack.aviation}｜${this.dataInfo.ticketBack.boeing}｜有餐食`)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 21 })
    }
  }
  
  // 获取返回价格
  getReturnPrice(): string {
    return this.dataInfo.ticketGo.returnPrice;
  }
  
  // 处理旅客列表变化
  onPeopleListChange(list: TravelPeopleModel[]): void {
    this.peopleList = list;
    this.dataInfo.ticketGo.peopleList = list;
    const num = list.filter(item => item.isCheck === true).length;
    this.dataInfo.ticketGo.returnPrice = (Number(this.goPrice + this.backPrice) * num).toString();
  }
  
  // 跳转到待支付页面
  jumpToPendingPaymentPage(vm: TicketPendingPaymentVM): void {
    // 设置订单通用信息
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const orderTime = new Date();
    const createTime = `${pad2(orderTime.getHours())}:${pad2(orderTime.getMinutes())}:${pad2(orderTime.getSeconds())}`;
    const createDate = `${orderTime.getFullYear()}-${pad2(orderTime.getMonth() + 1)}-${pad2(orderTime.getDate())}`;
    vm.orderInfo.type = OrderType.AIRPLANE;
    vm.orderInfo.detailInfo.ticketGo = this.dataInfo.ticketGo as TicketDetailListModel
    vm.orderInfo.detailInfo.ticketBack = this.dataInfo.ticketBack as TicketDetailListModel
    vm.orderInfo.price = Number(this.dataInfo.ticketGo.returnPrice);
    vm.orderInfo.detailInfo.departurePlace = this.dataInfo.ticketGo.startLocation
    vm.orderInfo.detailInfo.destination = this.dataInfo.ticketGo.endLocation
    vm.orderInfo.detailInfo.ticketGo.ticketCreateDate = vm.getDate();
    vm.orderInfo.detailInfo.ticketGo.ticketOrderNum = vm.creatOrderNumber();
    if(vm.isPayment){
      vm.orderInfo.ticketPayedData(OrderType.AIRPLANE);
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
      pageName: RouterMap.TICKET_PENDING_PAYMENT_PAGE,
      builder: wrapBuilder(TicketPendingPaymentPageBuilder),
      param: param
    });
  }

  build() {
    BaseOrderPage({
      pageParam: this.pageParam,
      orderType: OrderType.AIRPLANE,
      tradeSummary: '飞机票',
      expiredMessage: '航班已过期，从重新下单',
      renderTripInfo: this.renderTripInfo.bind(this),
      getReturnPrice: this.getReturnPrice.bind(this),
      onPeopleListChange: this.onPeopleListChange.bind(this),
      jumpToPendingPaymentPage:(vm: TicketPendingPaymentVM)=>{
        this.jumpToPendingPaymentPage(vm)
      }
    })
  }
}