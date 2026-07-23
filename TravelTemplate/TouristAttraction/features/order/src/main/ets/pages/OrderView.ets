import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, Constant, Logger } from 'common';
import { GetOrderDetailRequest, https } from 'network';
import { CommodityOrderInfo, TicketOrderInfo } from 'types';
import { FullLoadingComponent, TitleBar } from 'uicomponents';
import { OrderEmpty } from '../components/OrderEmpty';
import { OrderModuleData, OrderType, TICKET_ORDER_MODULE_INFO } from '../model/OrderModuleInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Builder
export function OrderBuilder() {
  OrderView();
}

@ComponentV2
export struct OrderView {
  vm: OrderPageVM = OrderPageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  cancelOrder(info: CommodityOrderInfo | TicketOrderInfo) {
    let param: GetOrderDetailRequest = {
      category: this.vm.orderType, orderNo: info.orderNo, orderStatus: OrderType.COMPLETED,
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
      category: this.vm.orderType, orderNo: info.orderNo, orderStatus: OrderType.TO_USE,
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
            Column({ space: 12 }) {
              Row() {
                Row({ space: 8 }) {
                  Row({ space: 4 }) {
                    Image($r('app.media.ticket')).size({ width: 24, height: 24 });
                    Text('门票').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
                  };

                  Divider().vertical(true).height(12);
                  Text(item.orderNo.toString())
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'));
                };

                Text(this.vm.getTicketStatus(item).text)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor(this.vm.getTicketStatus(item).color);
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

              Row({ space: 12 }) {
                Image(item.banner).size({ width: 56, height: 56 }).borderRadius(8);
                Column({ space: 2 }) {
                  Text(item.productName)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Text(`可用日期：${item.startTime}至${item.endTime}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'));
                  Text(`数量：${item.productPrice}份`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'));
                }.alignItems(HorizontalAlign.Start).layoutWeight(1);
              }.width(Constant.FULL_PERCENT);

              Row({ space: 12 }) {
                if (item.orderStatus === OrderType.TO_PAY) {
                  Text(`总价 ¥${item.amount}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'));
                  Text(`优惠 ¥${item.discount}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'));
                }
                Text() {
                  Span('实付').fontSize($r('sys.float.Body_S'));
                  Span(`¥${item.amount}`).fontSize($r('sys.float.Body_M')).fontWeight(FontWeight.Medium);
                }.fontColor($r('sys.color.font_primary'));
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);

              if (item.orderStatus === OrderType.TO_PAY) {
                Row({ space: 8 }) {
                  Button('取消订单', { controlSize: ControlSize.SMALL })
                    .fontColor($r('sys.color.font_primary'))
                    .backgroundColor($r('sys.color.comp_background_tertiary'))
                    .onClick(() => {
                      this.cancelOrder(item);
                    });
                  Button('去支付', { controlSize: ControlSize.SMALL })
                    .fontColor($r('sys.color.font_on_primary'))
                    .backgroundColor($r('sys.color.multi_color_04'))
                    .onClick(() => {
                      this.payOrder(item);
                    });
                }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);
              } else if (item.orderStatus === OrderType.TO_USE) {
                Row({ space: 8 }) {
                  this.RefundBuilder(item);
                  this.scheduleBuilder(item);
                }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);
              }
            }.padding(12).backgroundColor($r('sys.color.comp_background_primary')).borderRadius(16).onClick(() => {
              this.mainPathStack.pushPathByName(this.vm.orderType === 0 ? 'TicketOrderDetail' : 'CommodityOrderDetail',
                {
                  category: this.vm.orderType, orderNo: item.orderNo,
                } as GetOrderDetailRequest, (popInfo: ESObject) => { // 重新加载列表
                  this.vm.getOrderList();
                });
            });
          };
        }, (item: TicketOrderInfo) => item.orderNo);
      }
      .contentStartOffset(4)
      .contentEndOffset(12)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .lanes(this.vm.getOrderLane(), 12)
      .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
      .width('100%')
      .layoutWeight(1);
    };
  }

  @Builder
  RefundBuilder(item: TicketOrderInfo | CommodityOrderInfo) {
    Row() {
      Button(`${this.vm.orderType === 0 ? '退订' : '申请退款'}`, { controlSize: ControlSize.SMALL })
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.refundOrder(item);
        });
    };
  }

  @Builder
  scheduleBuilder(item: TicketOrderInfo) {
    Row() {
      Button(item.isAddSchedule ? '已添加日程' : '添加日程', { controlSize: ControlSize.SMALL })
        .fontColor(item.isAddSchedule ? $r('sys.color.font_on_primary') : $r('sys.color.multi_color_04'))
        .backgroundColor(item.isAddSchedule ? $r('sys.color.multi_color_04') : $r('sys.color.comp_background_tertiary'))
        .enabled(item.isAddSchedule ? false : true)
        .onClick(async () => {
          this.vm.addSchedule(item, this.getUIContext());
        });
    };
  }

  @Builder
  CommodityOrder() {
    List({ space: 12 }) {
      ForEach(this.vm.commodityOrderList, (item: CommodityOrderInfo) => {
        ListItem() {
          Column({ space: 12 }) {
            Row() {
              Row({ space: 8 }) {
                Row({ space: 4 }) {
                  Image($r('app.media.mall')).size({ width: 24, height: 24 });
                  Text('文创特产').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
                };

                Divider().vertical(true).height(12);
                Text(item.orderNo.toString())
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_secondary'));
              };

              Text(this.vm.getCommodityStatus(item).text)
                .fontSize($r('sys.float.Body_M'))
                .fontColor(this.vm.getCommodityStatus(item).color);
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

            Row() {
              Image(item.banner).size({ width: 56, height: 56 }).borderRadius(8);
              Column({ space: 2 }) {
                Row({ space: 24 }) {
                  Text(item.productName)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Text(`${item.disCountPrice}`)
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium);
                }.justifyContent(FlexAlign.SpaceBetween);

                if (item.originalPrice) {
                  Row() {
                    Text(`${item.originalPrice}`)
                      .fontSize($r('sys.float.Body_S'))
                      .fontColor($r('sys.color.font_tertiary'))
                      .decoration({ type: TextDecorationType.LineThrough });
                  }.justifyContent(FlexAlign.End);
                }
                Text(`规格：${item.spuName}`).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'));
              }.layoutWeight(1);

            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Top);

            Row({ space: 12 }) {
              if ([OrderType.TO_USE, OrderType.REFUNDED].includes(item.orderStatus)) {
                Text(`总价 ¥${item.amount}`).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'));
                Text(`优惠 ¥${item.discount}`)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_secondary'));
              }
              Text() {
                Span('实付').fontSize($r('sys.float.Body_S'));
                Span(`¥${item.amount}`).fontSize($r('sys.float.Body_M')).fontWeight(FontWeight.Medium);
              }.fontColor($r('sys.color.font_primary'));
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);

            if (item.orderStatus === OrderType.TO_PAY) {
              Row({ space: 8 }) {
                Button('取消订单', { controlSize: ControlSize.SMALL })
                  .fontColor($r('sys.color.font_primary'))
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .onClick(() => {
                    this.cancelOrder(item);
                  });
                Button('去支付', { controlSize: ControlSize.SMALL })
                  .fontColor($r('sys.color.font_on_primary'))
                  .backgroundColor($r('sys.color.multi_color_04'))
                  .onClick(() => {
                    this.payOrder(item);
                  });
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.End);
            } else if (item.orderStatus === OrderType.TO_USE) {
              Row() {
                this.RefundBuilder(item);
              }.width(Constant.FULL_PERCENT);
            }
          }.padding(12).backgroundColor($r('sys.color.comp_background_primary')).borderRadius(16).onClick(() => {
            this.mainPathStack.pushPathByName(this.vm.orderType === 0 ? 'TicketOrderDetail' : 'CommodityOrderDetail', {
              category: this.vm.orderType, orderNo: item.orderNo,
            } as GetOrderDetailRequest, () => { // 重新加载列表
              this.vm.getOrderList();
            });
          });
        };
      }, (item: CommodityOrderInfo) => item.orderNo);
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .contentStartOffset(8)
    .lanes(this.vm.getOrderLane(), 12)
    .contentEndOffset(8)
    .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding });
  }

  @Builder
  OrderListBuilder() {
    List({ space: 8 }) {
      ForEach(TICKET_ORDER_MODULE_INFO, (item: OrderModuleData, index: number) => {
        ListItem() {
          Row() {
            Text(item.title)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor(
                this.vm.orderTabIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'));
          }
          .height(36)
          .padding({ left: 16, right: 16 })
          .borderRadius(20)
          .backgroundColor(this.vm.orderTabIndex === index ? $r('sys.color.multi_color_04') :
            $r('sys.color.comp_background_tertiary'));
        }.onClick(() => {
          this.vm.orderTabIndex = index;
          this.vm.getOrderList();
        });
      }, (item: OrderModuleData) => item.title.toString());
    }
    .listDirection(Axis.Horizontal)
    .contentStartOffset(this.breakPointModel.pagePadding)
    .contentEndOffset(this.breakPointModel.pagePadding)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .height(56)
    .width('100%');

    if (this.vm.hasData) {
      Column() {
        if (this.vm.orderType === 0) {
          this.TicketOrder();
        } else {
          this.CommodityOrder();
        }
      }.layoutWeight(1);
    } else {
      OrderEmpty().layoutWeight(1);
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: this.vm.orderType === 0 ? '门票订单' : '购物订单', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        if (this.vm.isLoading) {
          FullLoadingComponent();
        } else {
          this.OrderListBuilder();
        }
      }.padding({ bottom: this.windowBottomHeight }).backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.vm.orderTabIndex = OrderType.ALL;
      let param = context.pathInfo.param as number;
      if (typeof param !== 'undefined') {
        this.vm.isFromMine = true;
        this.vm.orderType = param;
      }
      this.vm.getOrderList();
      Logger.info('order type ' + this.vm.orderType);
    });
  }
}