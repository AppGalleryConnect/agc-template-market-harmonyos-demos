import { Constant, Logger } from 'common';
import {
  COMMODITY_ORDER_MODULE_INFO,
  OrderModuleData,
  OrderType,
  TICKET_ORDER_MODULE_INFO,
} from '../model/OrderModuleInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';
import { FullLoadingComponent, OrderTypeDialog, TitleBar } from 'components';
import { CommodityOrderInfo, TicketOrderInfo } from 'types';
import { GetOrderDetailRequest, https } from 'network';
import { OrderEmpty } from '../components/OrderEmpty';

@Builder
export function OrderBuilder() {
  OrderView();
}

@Extend(Text)
function itemTitle() {
  .fontSize(14).fontWeight(500).opacity(0.9);
}

@Extend(Text)
function itemContent(opa: number) {
  .opacity(opa).fontSize(12);
}

@ComponentV2
export struct OrderView {
  vm: OrderPageVM = OrderPageVM.instance;
  @Local orderTabIndex: number = 0;
  @Local isLoading: boolean = true;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: OrderTypeDialog({
      changeType: (index) => {
        this.vm.orderType = index;
        this.vm.getOrderList();
      },
      type: this.vm.orderType,
    }),
    customStyle: true,
    autoCancel: true,
    alignment: DialogAlignment.TopStart,
    offset: { dx: '36%', dy: 84 },
  });

  cancelOrder(info: CommodityOrderInfo | TicketOrderInfo) {
    let param: GetOrderDetailRequest = {
      category: this.vm.orderType,
      orderNo: info.orderNo,
      orderStatus: OrderType.COMPLETED,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        this.vm.orderTabIndex = param.orderStatus ?? 0;
        this.vm.getOrderList();
      }
    });
  }

  payOrder(info: CommodityOrderInfo | TicketOrderInfo) {
    let param: GetOrderDetailRequest = {
      category: this.vm.orderType,
      orderNo: info.orderNo,
      orderStatus: OrderType.TO_USE,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        this.vm.orderTabIndex = param.orderStatus ?? 0;
        this.vm.getOrderList();
      }
    });
  }

  @Builder
  TicketOrder() {
    Column({ space: 12 }) {
      List({ space: 12 }) {
        ForEach(this.vm.ticketOrderList, (item: TicketOrderInfo) => {
          ListItem() {
            Column({ space: 16 }) {
              Row() {
                Row({ space: 8 }) {
                  Image($r('app.media.ticket')).size({ width: 24, height: 24 });
                  Text('门票').fontSize(12).opacity(0.9);
                  Divider().vertical(true).height(12);
                  Text(item.orderNo.toString()).fontSize(12).opacity(0.4);
                };

                Text(this.vm.getTicketStatus(item).text)
                  .fontSize(14)
                  .fontColor(this.vm.getTicketStatus(item).color)
                  .opacity(this.vm.getTicketStatus(item).opacity);
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

              Divider();

              Column({ space: 6 }) {
                Row() {
                  Text(item.productName).itemTitle().width(200)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });

                  Text(`￥${item.amount}`).itemTitle();
                }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

                Text(`可用日期${item.startTime}至${item.endTime}`).itemContent(0.6);

                Row({ space: 20 }) {
                  Text(`单价: ￥${item.productPrice}`).itemContent(0.6);
                  Text(`数量：${item.productPrice}`).itemContent(0.6);
                };

                Row({ space: 20 }) {
                  Text(`总金额: ¥${item.amount}`).itemContent(0.6);
                  Text(`优惠：${item.discount}`).itemContent(0.6);
                  Text(`实付：${item.amount}`).itemContent(0.6);
                };
              }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start);

              if (item.orderStatus === OrderType.TO_PAY) {
                Row({ space: 8 }) {
                  Button('取消订单')
                    .height(28)
                    .fontSize(12)
                    .fontColor(Color.Black)
                    .backgroundColor(Color.White)
                    .opacity(0.6)
                    .border({ width: 1, color: Color.Black, radius: 24 })
                    .onClick(() => {
                      this.cancelOrder(item);
                    });
                  Button('立即支付')
                    .height(28)
                    .fontSize(12)
                    .fontColor('#64BB5C')
                    .backgroundColor(Color.White)
                    .border({ width: 1, color: '#64BB5C', radius: 24 })
                    .onClick(() => {
                      this.payOrder(item);
                    });
                }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);
              } else if (item.orderStatus === OrderType.TO_USE) {
                this.RefundBuilder(item);
              }
            }.padding(12).backgroundColor(Color.White).borderRadius(8).onClick(() => {
              this.mainPathStack.pushPathByName(this.vm.orderType === 0 ? 'TicketOrderDetail' :
                'CommodityOrderDetail',
                {
                  category: this.vm.orderType,
                  orderNo: item.orderNo,
                } as GetOrderDetailRequest, (popInfo: ESObject) => {
                  // 重新加载列表
                  this.vm.getOrderList();
                });
            });
          };
        }, (item: TicketOrderInfo) => item.orderNo);
      }.align(Alignment.Top).height('90%').padding(12);

      Text('已加载全部了').fontSize(14).fontColor('rgba(0, 0, 0, 0.4)');
    };
  }

  @Builder
  RefundBuilder(item: TicketOrderInfo | CommodityOrderInfo) {
    Row() {
      Button(`${this.vm.orderType === 0 ? '退订' : '申请退款'}`)
        .height(28)
        .fontSize(12)
        .fontColor(Color.Black)
        .backgroundColor(Color.White)
        .opacity(0.6)
        .border({ width: 1, color: Color.Black, radius: 24 })
        .onClick(() => {
          this.refundOrder(item);
        });
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);
  }

  refundOrder(info: TicketOrderInfo | CommodityOrderInfo) {
    let param: GetOrderDetailRequest = {
      category: this.vm.orderType,
      orderNo: info.orderNo,
      orderStatus: OrderType.REFUNDED,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        this.vm.orderTabIndex = param.orderStatus ?? 0;
        this.vm.getOrderList();
      }
    });
  }

  @Builder
  CommodityOrder() {
    Column({ space: 12 }) {
      List({ space: 12 }) {
        ForEach(this.vm.commodityOrderList, (item: CommodityOrderInfo) => {
          ListItem() {
            Column({ space: 16 }) {
              Row() {
                Row({ space: 8 }) {
                  Image($r('app.media.mall')).size({ width: 24, height: 24 });
                  Text('购物').itemContent(0.9);
                  Divider().vertical(true).height(12);
                  Text(item.orderNo.toString()).itemContent(0.4);
                };

                Text(this.vm.getCommodityStatus(item).text)
                  .fontSize(14)
                  .fontColor(this.vm.getCommodityStatus(item).color)
                  .opacity(this.vm.getCommodityStatus(item).opacity);
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

              Divider();

              Row() {
                Row({ space: 8 }) {
                  Image(item.banner)
                    .size({ width: 68, height: 68 })
                    .margin({ right: 14 })
                    .borderRadius(8);
                  Column({ space: 2 }) {
                    Text(item.productName)
                      .fontWeight(500)
                      .fontSize(14)
                      .width(200)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                    Text(item.spuName).itemContent(0.4);
                  }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start);
                };

                Column() {
                  Text(`￥${item.originalPrice}`).itemContent(0.6);

                  Text(`${item.disCountPrice}`).itemContent(0.4).decoration({ type: TextDecorationType.LineThrough });

                  Text(`x${item.count}`).itemContent(0.4);
                }.width(32).alignItems(HorizontalAlign.End).justifyContent(FlexAlign.SpaceBetween);
              }
              .width(Constant.FULL_PERCENT)
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Top);

              Row() {
                Text(`总价￥${item.amount} 优惠￥${item.discount}`).itemContent(0.4);
                Text(` 实付`).itemContent(0.4);
                Text(`￥${item.amount}`).fontSize(14).fontWeight(500);
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);

              if (item.orderStatus === OrderType.TO_PAY) {
                Row({ space: 8 }) {
                  Button('取消订单')
                    .height(28)
                    .fontSize(12)
                    .fontColor(Color.Black)
                    .backgroundColor(Color.White)
                    .opacity(0.6)
                    .border({ width: 1, color: Color.Black, radius: 24 })
                    .onClick(() => {
                      this.cancelOrder(item);
                    });
                  Button('去支付')
                    .height(28)
                    .fontSize(12)
                    .fontColor('#64BB5C')
                    .backgroundColor(Color.White)
                    .border({ width: 1, color: '#64BB5C', radius: 24 })
                    .onClick(() => {
                      this.payOrder(item);
                    });
                }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);
              } else if (item.orderStatus === OrderType.TO_USE) {
                Row() {
                  this.RefundBuilder(item);
                }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);
              }
            }.padding(12).backgroundColor(Color.White).borderRadius(8).onClick(() => {
              this.mainPathStack.pushPathByName(this.vm.orderType === 0 ? 'TicketOrderDetail' :
                'CommodityOrderDetail',
                {
                  category: this.vm.orderType,
                  orderNo: item.orderNo,
                } as GetOrderDetailRequest, () => {
                  // 重新加载列表
                  this.vm.getOrderList();
                });
            });
          };
        }, (item: CommodityOrderInfo) => item.orderNo);
      }.align(Alignment.Top).height('90%').padding(12);

      Text('已加载全部了').fontSize(14).fontColor('rgba(0, 0, 0, 0.4)');
    };
  }

  @Builder
  OrderTabBar(targetIndex: number) {
    Column({ space: 8 }) {
      Text(this.vm.getTitle(targetIndex))
        .fontColor(this.vm.orderTabIndex === targetIndex ? '#64BB5C' :
        Color.Black)
        .opacity(this.vm.orderTabIndex === targetIndex ? 1 : 0.9);

      if (this.vm.orderTabIndex === targetIndex) {
        Divider().color('#64BB5C').strokeWidth(3).width(20);
      }
    }.onClick(() => {
      this.vm.orderTabIndex = targetIndex;
      this.vm.getOrderList();
    });
  }

  @Builder
  OrderTitleBuilder() {
    Column() {
      Row() {
        Text(this.vm.orderType === 0 ? '门票订单' : '购物订单').fontSize(20).fontWeight(600).margin({ right: 8 });
        Image($r('app.media.order_spin_close')).size({ height: 8, width: 10 });
      }.alignItems(VerticalAlign.Center).onClick(() => {
        if (this.dialogController != null) {
          this.dialogController.open();
        }
      });
    }
    .margin({ top: this.windowTopHeight })
    .padding({ top: 16 });
  }

  @Builder
  OrderListBuilder() {
    ForEach(this.vm.orderType === 0 ? TICKET_ORDER_MODULE_INFO : COMMODITY_ORDER_MODULE_INFO,
      (item: OrderModuleData) => {
        if (this.vm.isLoading) {
          FullLoadingComponent();
        } else {
          TabContent() {
            Column() {
              if (this.vm.orderType === 0) {
                if (this.vm.ticketOrderList.length === 0) {
                  OrderEmpty().borderRadius(8).backgroundColor(Color.White);
                } else {
                  this.TicketOrder();
                }
              } else {
                if (this.vm.commodityOrderList.length === 0) {
                  OrderEmpty().borderRadius(8).backgroundColor(Color.White);
                } else {
                  this.CommodityOrder();
                }
              }
            }
            .align(Alignment.Top)
            .height(Constant.FULL_PERCENT);
          }
          .tabBar(this.OrderTabBar(item.id))
          .backgroundColor('#F1F3F5');
        }
      }, (item: OrderModuleData) => item.id.toString());
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          this.OrderTitleBuilder();
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center);

        Tabs({ index: this.vm.orderTabIndex }) {
          this.OrderListBuilder();
        }.barMode(BarMode.Fixed).animationDuration(0).onChange((value: number) => {
          this.vm.orderTabIndex = value;
          this.vm.getOrderList();
        });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let param = context.pathInfo.param as number;
      if (typeof param !== 'undefined') {
        this.vm.isFromMine = true;
        this.vm.orderType = param;
      }
      Logger.info('order type ' + this.vm.orderType);
    });
  }
}