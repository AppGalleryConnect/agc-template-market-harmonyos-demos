import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { https, UpdateOrderRequest } from 'network';
import { Constants, NavPathName, OrderTabBarType } from 'constant';
import { CommonBlank, CommonHeader } from 'component';
import { formatPriceToNumber, Logger } from 'util';
import { Order, OrderParam } from 'type';
import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';
import { AddressDTO, goToAddressListPage } from 'address_management';
import { OrderPageVM } from '../viewmodel/OrderPageVM';
import {
  OrderTabBar,
  OrderTypesTabBar,
  HOTEL_ORDER_TABS_INFO,
  COMMODITY_ORDER_TABS_INFO,
  ORDER_TYPES,
  ORDER_TYPES_INFO
} from '../model/OrderTabInfo';

@Builder
export function OrderListBuilder() {
  OrderList();
}

@ComponentV2
struct OrderCountDown {
  @Param createTime: string = '';
  @Local count: number = 0;
  textTimerController: TextTimerController = new TextTimerController();

  aboutToAppear(): void {
    let curStamp = new Date().getTime();
    let createStamp = new Date(this.createTime).getTime();
    this.count = createStamp + 10 * 60 * 1000 - curStamp;
  }

  build() {
    Row({ space: 0 }) {
      Text('剩余')
        .fontColor($r('sys.color.warning'))
        .fontSize(12);
      TextTimer({ isCountDown: true, count: this.count, controller: this.textTimerController })
        .format('mm分ss秒')
        .fontColor($r('sys.color.warning'))
        .fontSize(12)
        .onAppear(() => {
          this.textTimerController.start();
        });
    }
  }
}

@ComponentV2
export struct OrderList {
  vm: OrderPageVM = OrderPageVM.instance;
  @Consumer('orderTabIndex') orderTabIndex: number = 0;
  @Local orderTypeTabIndex: number = 0;
  @Local index: number = 0;
  controller: TabsController = new TabsController();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear() {
    this.vm.getOrderList();
  }

  getOrderType(orderItem: Order): string | undefined {
    let orderType = ORDER_TYPES.find((item) => item.status === orderItem.orderStatus);
    return orderType?.text;
  }

  get currentTabStatus(): number {
    let tabs = this.orderTypeTabIndex === 0 ? HOTEL_ORDER_TABS_INFO : COMMODITY_ORDER_TABS_INFO;
    if (this.orderTabIndex >= 0 && this.orderTabIndex < tabs.length) {
      return tabs[this.orderTabIndex].index;
    }
    return 0;
  }

  findTabIndexByStatus(status: number): number {
    let tabs = this.orderTypeTabIndex === 0 ? HOTEL_ORDER_TABS_INFO : COMMODITY_ORDER_TABS_INFO;
    let idx = tabs.findIndex((item) => item.index === status);
    return idx >= 0 ? idx : 0;
  }

  @Builder
  qrCodeDialogBuilder() {
    Column({ space: 10 }) {
      Image($r('app.media.qr_code'))
        .width(240)
        .height(240)
        .objectFit(ImageFit.Contain)

      Text('请勿泄漏给他人')
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize(14)

      Text('注意核销使用环境')
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize(14)

      Image($r('app.media.qr_code_close'))
        .width(24)
        .height(24)
        .margin({ top: 10 })
        .onClick(() => {
          UIDialog.closeLast();
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  OrderItemBuilder(orderItem: Order) {
    Column() {
      Row() {
        Text(orderItem.createTime)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(12);
        Row({ space: 12 }) {
          Text(this.getOrderType(orderItem))
            .fontColor(orderItem.orderStatus === 1 ? $r('sys.color.warning') :
              $r('app.color.keyword_type_font_color'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium);
          if (orderItem.orderStatus === 1) {
            OrderCountDown({ createTime: orderItem.createTime });
          }
        }
      }
      .width(Constants.FULL_SCREEN)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 });

      Row() {
        Image(orderItem.orderType === 0 ? orderItem.roomTypeBanner : orderItem.goodsBanner)
          .objectFit(ImageFit.Cover)
          .size({ width: 56, height: 56 })
          .borderRadius(8)
          .margin({ right: 12 });

        Column({ space: 4 }) {
          Text(orderItem.orderName)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          if (orderItem.orderType === 0) {
            Text(`可用日期：${orderItem.planCheckInDate}至${orderItem.planCheckOutDate}`)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'));
            Text(`数量：${orderItem.dayCount}晚`)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'));
          } else {
            Text(`规格：${orderItem.sfc}`)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'));
            Text(`数量：${orderItem.goodsCount}`)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'));
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1);
      }
      .width(Constants.FULL_SCREEN)
      .alignItems(VerticalAlign.Top);

      Text() {
        Span('总价')
        Span('  ')
        Span(`¥${formatPriceToNumber(orderItem.amount)}`)
        Span('    ')
        Span('实付')
        Span('  ')
        Span(`¥${formatPriceToNumber(orderItem.amount)}`)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .width(Constants.FULL_SCREEN)
      .textAlign(TextAlign.End)
      .fontSize(12)
      .fontColor($r('sys.color.font_tertiary'))
      .margin({ top: 12 });

      if (orderItem.orderStatus === 5) {
        Row({ space: 4 }) {
          Image($r('app.media.await_shipment'))
            .width(16)
            .height(16)
          Text('待发货')
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Divider().vertical(true).height(12).color($r('sys.color.comp_divider'))
          Text('48小时内发货')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width(Constants.FULL_SCREEN)
        .padding(8)
        .borderRadius(8)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin({ top: 12 });
      }

      if (orderItem.orderStatus === 1 || orderItem.orderStatus === 2 || orderItem.orderStatus === 5) {
        Row({ space: 8 }) {
          if (orderItem.orderStatus === 1) {
            Button('取消订单', { type: ButtonType.Normal })
              .width(88)
              .height(28)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('sys.float.corner_radius_level7'))
              .onClick(async () => {
                this.vm.orderList.map((item => {
                  if (item.orderSn === orderItem.orderSn) {
                    item.orderStatus = 3;
                  }
                }));
                const res =
                  await https.updateOrder({ orderSn: orderItem.orderSn, orderStatus: 3 } as UpdateOrderRequest);
                if (res.code === 200) {
                  Logger.info('cancel order success in order list');
                }
                this.orderTabIndex = this.findTabIndexByStatus(3);
              });

            if (orderItem.orderType === 1) {
              Button('修改地址', { type: ButtonType.Normal })
                .width(88)
                .height(28)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_emphasize'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .borderRadius($r('sys.float.corner_radius_level7'))
                .onClick(() => {
                  goToAddressListPage(this.mainPathStack, {
                    onAddressSelected: (_dto: AddressDTO) => {
                      this.mainPathStack.pop();
                    }
                  });
                });
            }

            Button('去支付', { type: ButtonType.Normal })
              .width(80)
              .height(28)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor($r('sys.color.comp_background_emphasize'))
              .borderRadius($r('sys.float.corner_radius_level7'))
              .onClick(() => {
                this.openCashierPickerForOrder(orderItem);
              });
          }

          if (orderItem.orderStatus === 2 && orderItem.orderType === 0) {
            Button('退款', { type: ButtonType.Normal })
              .width(80)
              .height(28)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('sys.float.corner_radius_level7'))
              .onClick(async () => {
                this.vm.orderList.map((item => {
                  if (item.orderSn === orderItem.orderSn) {
                    item.orderStatus = 3;
                  }
                }));
                const res =
                  await https.updateOrder({ orderSn: orderItem.orderSn, orderStatus: 3 } as UpdateOrderRequest);
                if (res.code === 200) {
                  Logger.info('refund order success in order list');
                }
                this.orderTabIndex = this.findTabIndexByStatus(3);
              });

            Button('核销', { type: ButtonType.Normal })
              .width(80)
              .height(28)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_emphasize'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('sys.float.corner_radius_level7'))
              .onClick(() => {
                UIDialog.open({
                  contentBuilder: (): void => this.qrCodeDialogBuilder(),
                  bgColor: '#00000000',
                  maskColor: $r('sys.color.mask_fourth'),
                  showConfirmButton: false,
                  showCancelButton: false,
                  closeOnClickMask: true,
                });
              });
          }

          if (orderItem.orderStatus === 5) {
            Button('退款', { type: ButtonType.Normal })
              .width(80)
              .height(28)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('sys.float.corner_radius_level7'))
              .onClick(async () => {
                this.vm.orderList.map((item => {
                  if (item.orderSn === orderItem.orderSn) {
                    item.orderStatus = 3;
                  }
                }));
                const res =
                  await https.updateOrder({ orderSn: orderItem.orderSn, orderStatus: 3 } as UpdateOrderRequest);
                if (res.code === 200) {
                  Logger.info('refund order success in order list');
                }
                this.orderTabIndex = this.findTabIndexByStatus(3);
              });

            Button('修改地址', { type: ButtonType.Normal })
              .width(88)
              .height(28)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_emphasize'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('sys.float.corner_radius_level7'))
              .onClick(() => {
                goToAddressListPage(this.mainPathStack, {
                  onAddressSelected: (_dto: AddressDTO) => {
                    this.mainPathStack.pop();
                  }
                });
              });

            Button('催发货', { type: ButtonType.Normal })
              .width(80)
              .height(28)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor($r('sys.color.comp_background_emphasize'))
              .borderRadius($r('sys.float.corner_radius_level7'))
              .onClick(() => {
                ToastDialog.showToast({ message: '已提交催发货申请，请耐心等待~' });
              });
          }
        }
        .width(Constants.FULL_SCREEN)
        .justifyContent(FlexAlign.End)
        .margin({ top: 12 });
      }
    }
    .padding(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .margin({ bottom: 12 })
    .onClick(() => {
      this.mainPathStack.pushPathByName(orderItem.orderType === 0 ? NavPathName.ROOM_ORDER_DETAIL :
      NavPathName.COMMODITY_ORDER_DETAIL,
        orderItem, (popInfo: ESObject) => {
          this.orderTabIndex = this.findTabIndexByStatus(popInfo.result.orderStatus);
          this.vm.getOrdersByType(this.currentTabStatus, this.orderTypeTabIndex);
        });
    });
  }

  async openCashierPickerForOrder(orderItem: Order) {
    const cashierPicker: CashierPicker = new CashierPicker(this.getUIContext())
      .onRealPayment(async (type: PaymentType) => {
        try {
          if (type === PaymentType.HUAWEI) {
            aggregatedPaymentService.requestPaymentByHuawei(this.getUIContext(), { orderStr: '' });
          } else if (type === PaymentType.ALIPAY) {
            aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: '' });
          } else if (type === PaymentType.WECHAT) {
            const success = await aggregatedPaymentService.requestPaymentByWeChat(
              this.getUIContext() as UIContext, {
                partnerId: '',
                prepayId: '',
                nonceStr: '',
                timeStamp: '',
                sign: '',
              });
            if (!success) {
              this.getUIContext().getPromptAction().showToast({ message: '微信拉起失败' });
            }
          }
        } catch (err) {
          Logger.info('pay fail with reason ' + JSON.stringify(err));
        }
      })
      .onWillDismiss((reason: DismissReason) => {
        if (reason !== DismissReason.TOUCH_OUTSIDE) {
          this.mainPathStack.pushPathByName(
            orderItem.orderType === 0 ? NavPathName.ROOM_ORDER_DETAIL : NavPathName.COMMODITY_ORDER_DETAIL,
            orderItem);
          cashierPicker.close();
        }
      });

    aggregatedPaymentService.registerPaymentCallback(
      async (_type: PaymentType, isSuccess: boolean) => {
        if (!isSuccess) {
          ToastDialog.showToast({ message: '本地调试阶段，模拟支付成功回调' });
        }
        let desIndex: number = orderItem.orderType === 1 ? OrderTabBarType.TO_SHIP : OrderTabBarType.TO_USE;
        orderItem.orderStatus = desIndex;
        this.vm.orderList.map((item => {
          if (item.orderSn === orderItem.orderSn) {
            item.orderStatus = desIndex;
          }
        }));
        await https.updateOrder({ orderSn: orderItem.orderSn, orderStatus: desIndex } as UpdateOrderRequest);
        this.mainPathStack.pushPathByName(
          orderItem.orderType === 0 ? NavPathName.ROOM_ORDER_DETAIL : NavPathName.COMMODITY_ORDER_DETAIL,
          orderItem);
        cashierPicker.close();
      },
    );

    cashierPicker
      .reset()
      .setAmount(orderItem.amount * 100)
      .setTradeSummary(orderItem.orderName)
      .open();
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '全部订单', showBackButton: true, backButtonClick: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          Row() {
            ForEach(ORDER_TYPES_INFO, (item: OrderTypesTabBar, index: number) => {
              Text(item.title)
                .fontColor($r('sys.color.font_primary'))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .width('50%')
                .height('100%')
                .borderRadius(20)
                .backgroundColor(this.orderTypeTabIndex === index ?
                  $r('sys.color.comp_background_primary_contrary_secondary') : Color.Transparent)
                .onClick(() => {
                  this.orderTypeTabIndex = index;
                  this.orderTabIndex = 0;
                  this.vm.getOrdersByType(this.currentTabStatus, this.orderTypeTabIndex);
                });
            }, (item: OrderTypesTabBar) => item.title.toString());
          }
          .width('100%')
          .height(40)
          .padding(2)
          .margin({ top: 8, bottom: 12 })
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'));

          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.orderTypeTabIndex === 0 ? HOTEL_ORDER_TABS_INFO : COMMODITY_ORDER_TABS_INFO,
                (item: OrderTabBar, index: number) => {
                  Text(item.title)
                    .fontSize(14)
                    .fontWeight(this.orderTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(this.orderTabIndex === index ?
                      $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
                    .backgroundColor(this.orderTabIndex === index ?
                      $r('sys.color.comp_background_emphasize') :
                      $r('sys.color.comp_background_tertiary'))
                    .borderRadius(20)
                    .padding({ top: 8, bottom: 8, left: 16, right: 16 })
                    .onClick(() => {
                      this.orderTabIndex = index;
                      this.controller.changeIndex(index);
                      this.vm.getOrdersByType(this.currentTabStatus, this.orderTypeTabIndex);
                    });
                }, (item: OrderTabBar) => item.title.toString());
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width(Constants.FULL_SCREEN)
          .margin({ bottom: 8 })

          Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.orderTabIndex }) {
            ForEach(this.orderTypeTabIndex === 0 ? HOTEL_ORDER_TABS_INFO : COMMODITY_ORDER_TABS_INFO,
              (item: OrderTabBar, index: number) => {
                TabContent() {
                   if (this.vm.orders.length !== 0) {
                     List({ space: 0 }) {
                       ForEach(this.vm.orders, (item: Order) => {
                         ListItem() {
                           this.OrderItemBuilder(item);
                         };
                       }, (item: Order) => item.orderSn,
                       );
                     }.width(Constants.FULL_SCREEN).align(Alignment.Top).scrollBar(BarState.Off);

                   } else {
                     CommonBlank();
                   }
                 }
                 .align(Alignment.Top)
              }, (item: OrderTabBar) => item.title.toString());

          }
          .scrollable(false)
          .animationDuration(0)
          .barHeight(0)
          .width(Constants.FULL_SCREEN)
          .layoutWeight(1)
          .onChange((value: number) => {
            this.orderTabIndex = value;
            this.vm.getOrdersByType(this.currentTabStatus, this.orderTypeTabIndex);
          });
        }.align(Alignment.Top).layoutWeight(1).padding({ left: 16, right: 16 });
      }.backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      let orderParam: OrderParam = context.pathInfo.param as OrderParam;
      this.orderTabIndex = orderParam.orderStatus;
      this.orderTypeTabIndex = orderParam.orderType;
      this.vm.getOrdersByType(this.currentTabStatus, this.orderTypeTabIndex);
    });
  }
}
