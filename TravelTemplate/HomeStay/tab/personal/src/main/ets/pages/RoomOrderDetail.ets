import { ToastDialog } from '@hw-agconnect/ui-toast';
import { copyText, formatPriceToNumber, AppStorageBank, Logger } from 'util';
import { Constants, OrderTabBarType } from 'constant';
import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';
import { https, UpdateOrderRequest } from 'network';
import { Order } from 'type';
import { CommonHeader } from 'component';
import { DialPanel } from 'dial_panel';
import { TenantInfo } from '../model/Index';
import { OrderHeader } from '../components/OrderHeader';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Builder
export function RoomOrderDetailBuilder() {
  RoomOrderDetail();
}

@ComponentV2
export struct RoomOrderDetail {
  @Local tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @Local order: Order = new Order();
  @Local orderNo: string = '';
  @Local showContactSheet: boolean = false;
  @Consumer('orderTabIndex') orderTabIndex: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  vm: OrderPageVM = OrderPageVM.instance;
  private dialPanel: DialPanel = new DialPanel(this.getUIContext())
    .setTitle('电话客服')
    .setPhoneNumber(this.tenantInfo?.phone ?? '');

  @Builder
  OrderFormItemBuilder(label: string, content: string, labelColor?: ResourceColor) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(labelColor ?? $r('sys.color.font_secondary'))
        .constraintSize({ minWidth: 72 });
      Row() {
        Text(content)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(12);
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End);
    }
    .width(Constants.FULL_SCREEN)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  OrderFormItemWithCopyBuilder(label: string, content: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))
        .constraintSize({ minWidth: 72 });
      Row() {
        Text(content)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(12)
          .margin({ right: 12 });
        Text('复制')
          .fontSize(10)
          .borderWidth(1)
          .borderColor($r('app.color.keyword_type_font_color'))
          .fontColor($r('app.color.keyword_type_font_color'))
          .borderRadius(10)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .onClick(() => {
            copyText(this.getUIContext(), content);
          });
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End);
    }
    .width(Constants.FULL_SCREEN)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '订单详情',
          showBackButton: true,
          backButtonClick: () => {
            this.mainPathStack.pop(this.order);
          },
        });

        Scroll() {
          Column({ space: 12 }) {
            Column() {
              OrderHeader({ order: this.order });
            }
            .width(Constants.FULL_SCREEN)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .clip(true);

            Column() {
              Row() {
                Image(this.order.roomTypeBanner)
                  .size({ width: 80, height: 80 })
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                  .margin({ right: 12 });

                Column({ space: 4 }) {
                  Text(this.order.orderName)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Text(`${this.order.planCheckInDate} 至 ${this.order.planCheckOutDate}`)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'));
                  Text(`共${this.order.dayCount}晚`)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'));
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                Column({ space: 4 }) {
                  Text() {
                    Span('¥')
                      .fontSize(12)
                      .fontColor($r('app.color.keyword_type_font_color'));
                    Span(`${formatPriceToNumber(this.order.amount)}`)
                      .fontColor($r('app.color.keyword_type_font_color'))
                      .fontWeight(FontWeight.Medium);
                  }
                }
                .alignItems(HorizontalAlign.End);
              }
              .width(Constants.FULL_SCREEN)
              .alignItems(VerticalAlign.Top);

              Divider()
                .color($r('sys.color.comp_divider'))
                .margin({ top: 16, bottom: 16 });

              Row() {
                SymbolGlyph($r('sys.symbol.service'))
                  .fontColor([$r('sys.color.font_secondary')])
                  .margin({ right: 8 });
                Text('联系客服')
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'));
              }
              .onClick(() => {
                this.showContactSheet = true;
              });
            }
            .padding(16)
            .width(Constants.FULL_SCREEN)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius(16);

            Column({ space: 16 }) {
              this.OrderFormItemBuilder('商品金额', `¥${formatPriceToNumber(this.order.amount)}`);
              Row() {
                Text('实付金额')
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
                  .constraintSize({ minWidth: 72 });
                Row() {
                  Text() {
                    Span('¥')
                      .fontSize(12);
                    Span(`${formatPriceToNumber(this.order.amount)}`);
                  }
                  .fontSize(18)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium);
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.End);
              }
              .width(Constants.FULL_SCREEN)
              .justifyContent(FlexAlign.SpaceBetween);
            }
            .padding(16)
            .width(Constants.FULL_SCREEN)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius(16);

            Column({ space: 16 }) {
              this.OrderFormItemBuilder('入住人', this.order.passengerName);
              this.OrderFormItemBuilder('联系电话', this.order.passengerPhone);
              this.OrderFormItemBuilder('备注', this.order.orderRemark);
              this.OrderFormItemWithCopyBuilder('订单号码', this.order.orderSn);
              this.OrderFormItemBuilder('下单时间', this.order.createTime);
            }
            .padding(16)
            .width(Constants.FULL_SCREEN)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius(16);
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 16 });
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring);

        if (this.order.orderStatus === OrderTabBarType.TO_PAY ||
          this.order.orderStatus === OrderTabBarType.TO_USE) {
          this.OrderFooterBuilder();
        }
      }
      .height(Constants.FULL_SCREEN)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .bindSheet($$this.showContactSheet, this.contactSheetBuilder(), {
        height: SheetSize.FIT_CONTENT,
        showClose: true,
        dragBar: false,
        onWillDismiss: (action: DismissSheetAction) => {
          this.showContactSheet = false;
        }
      })
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.order = context.pathInfo.param as Order;
    }).onBackPressed(() => {
      this.mainPathStack.pop(this.order);
      return true;
    });
  }

  @Builder
  OrderFooterBuilder() {
    Row() {
      Button('取消订单', { type: ButtonType.Normal })
        .height(40)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .layoutWeight(1)
        .onClick(() => {
          this.vm.orderList.map((item => {
            if (item.orderSn === this.order.orderSn) {
              this.order.orderStatus = OrderTabBarType.CANCEL;
              item.orderStatus = OrderTabBarType.CANCEL;
            }
          }));
          AppStorageBank.updateOrder(this.vm.orderList);
          this.mainPathStack.pop(this.order);
        });

      if (this.order.orderStatus === OrderTabBarType.TO_PAY) {
        Button('去支付', { type: ButtonType.Normal })
          .height(40)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .borderRadius($r('sys.float.corner_radius_level10'))
          .layoutWeight(1)
          .margin({ left: 16 })
          .onClick(() => {
            this.openCashierPicker();
          });
      }
    }
    .width(Constants.FULL_SCREEN)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding({ left: 16, right: 16, top: 8, bottom: 36 });
  }

  async openCashierPicker() {
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
          cashierPicker.close();
        }
      });

    aggregatedPaymentService.registerPaymentCallback(
      async (_type: PaymentType, isSuccess: boolean) => {
        if (!isSuccess) {
          ToastDialog.showToast({ message: '本地调试阶段，模拟支付成功回调' });
        }
        let desIndex: number = OrderTabBarType.TO_USE;
        this.order.orderStatus = desIndex;
        this.vm.orderList.map((item => {
          if (item.orderSn === this.order.orderSn) {
            item.orderStatus = desIndex;
          }
        }));
        AppStorageBank.updateOrder(this.vm.orderList);
        await https.updateOrder({ orderSn: this.order.orderSn, orderStatus: 2 } as UpdateOrderRequest);
        cashierPicker.close();
      },
    );

    cashierPicker
      .reset()
      .setAmount(this.order.amount * 100)
      .setTradeSummary(this.order.orderName)
      .open();
  }

  @Builder
  contactSheetBuilder() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.icon_customer_service_dial'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain);

          Text('电话客服')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 12 });

          Image($r('app.media.icon_direction_right_small'))
            .width(12)
            .height(24);
        }
        .width(Constants.FULL_SCREEN)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          this.showContactSheet = false;
          this.dialPanel.open();
        });

        Divider().color($r('sys.color.comp_divider'));

        Row() {
          Image($r('app.media.icon_customer_service_chat'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain);

          Text('在线客服')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 12 });

          Image($r('app.media.icon_direction_right_small'))
            .width(12)
            .height(24);
        }
        .width(Constants.FULL_SCREEN)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          this.showContactSheet = false;
          this.mainPathStack.pushPathByName('Customer', null);
        });
      }
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .padding(12)
    }
    .margin({ top: 64 })
    .width(Constants.FULL_SCREEN)
    .padding({ left: 16, right: 16, bottom: 28 })
  }
}
