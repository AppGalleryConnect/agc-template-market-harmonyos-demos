import { common } from '@kit.AbilityKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Constants, NavPathName } from 'constant';
import { Order, PurchaseInfo } from 'type';
import { doRandBySync, formatPriceToNumber, getCurrentTime, Logger } from 'util';
import { CommonHeader } from 'component';
import { CreateOrderRequest, https, UpdateOrderRequest } from 'network';
import { AddressDTO, AddressVM, Api, goToAddressListPage } from 'address_management';
import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';

@Builder
export function PurchaseBuilder() {
  Purchase();
}

@ComponentV2
export struct Purchase {
  @Local remark: string = '';
  @Local openId: string = '';
  @Local deliveryIndex: number = 0;
  @Local purchaseInfo: PurchaseInfo = new PurchaseInfo();
  @Local selectedAddress: AddressDTO | null = null;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private deliveryList: string[] = ['快递发货', '到店自提'];

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '确认订单',
          showBackButton: true,
          backButtonClick: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          Column({ space: 12 }) {
            Column() {
            Row() {
              ForEach(this.deliveryList, (item: string, index: number) => {
                Text(item)
                  .fontColor(this.deliveryIndex === index ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Center)
                  .width('50%')
                  .height('100%')
                  .borderRadius(20)
                   .backgroundColor(this.deliveryIndex === index ? $r('sys.color.comp_background_primary') : Color.Transparent)
                  .onClick(() => {
                    this.deliveryIndex = index;
                  });
              }, (item: string) => item);
            }
            .width('100%')
            .height(40)
            .padding(2)
            .borderRadius(20)
            .backgroundColor($r('sys.color.comp_background_tertiary'));

            Row() {
              Image($r('app.media.icon_location'))
                .width(24)
                .height(24)

              if (this.selectedAddress) {
                Column() {
                  Text(new AddressVM(this.selectedAddress).fullAddress)
                    .fontSize(16)
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Text(new AddressVM(this.selectedAddress).title)
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 4 });
                }
                .layoutWeight(1)
                .margin({ left: 16 })
                .alignItems(HorizontalAlign.Start)
              } else {
                Column() {
                  Text('请选择收货地址')
                    .fontSize(16)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Medium)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .layoutWeight(1)
                .margin({ left: 16 })
                .alignItems(HorizontalAlign.Start)
              }

              Image($r('app.media.icon_direction_right_gray'))
                .width(12)
                .height(24)
                .fillColor($r('sys.color.icon_tertiary'))
                .margin({ left: 12 });
            }
            .margin({ top: 12, bottom: 8 })
            .onClick(() => {
              goToAddressListPage(this.mainPathStack, {
                onAddressSelected: (dto: AddressDTO) => {
                  this.selectedAddress = dto;
                  this.mainPathStack.pop();
                }
              });
            });
          }
          .borderRadius(16)
          .padding(12)
          .backgroundColor($r('sys.color.comp_background_primary'))

          Column() {
            Row() {
              Image(this.purchaseInfo.commodityInfo.banner)
                .width(80)
                .height(80)
                .borderRadius(8);

              Column() {
                Text(this.purchaseInfo.commodityInfo.goodsName)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text(`规格：${this.purchaseInfo.sfc}`)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
                  .margin({ top: 4 });
                Text(`数量：${this.purchaseInfo.count}`)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
                  .margin({ top: 4 });
                Text('运费险 | 7天无理由')
                  .fontSize(10)
                  .fontColor($r('sys.color.font_tertiary'))
                  .margin({ top: 8 });
              }
              .layoutWeight(1)
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)

              Column() {
                Row() {
                  Text('￥')
                    .fontSize(12)
                    .fontColor($r('sys.color.warning'))
                    .fontWeight(FontWeight.Medium);
                  Text(`${(this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index] * 100) / 100}`)
                    .fontSize(18)
                    .fontColor($r('sys.color.warning'))
                    .fontWeight(FontWeight.Medium);
                };
                Text(`￥${(this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index] * 100) / 100}`)
                  .fontSize(10)
                  .fontColor($r('sys.color.font_tertiary'))
                  .decoration({ type: TextDecorationType.LineThrough });
              }
              .alignItems(HorizontalAlign.End);
            }
            .width(Constants.FULL_SCREEN)
            .alignItems(VerticalAlign.Top);

            Row() {
              Text('配送服务')
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'));
              Text(this.deliveryList[this.deliveryIndex])
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'));
            }
            .width(Constants.FULL_SCREEN)
            .height(48)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .margin({ top: 12 });

            Row() {
              Text('订单总金额')
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'));
              Text(`￥${formatPriceToNumber(this.purchaseInfo.count *
              this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index])}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'));
            }
            .width(Constants.FULL_SCREEN)
            .height(48)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center);

            Row() {
              Text('备注')
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'));
              TextInput({ placeholder: '选填，建议先与商家沟通后再填写', text: this.remark })
                .maxLength(10)
                .layoutWeight(1)
                .padding(0)
                .textAlign(TextAlign.End)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .placeholderFont({ size: 14 })
                .placeholderColor($r('sys.color.font_secondary'))
                .backgroundColor(Color.Transparent)
                .onChange((value: string) => {
                  this.remark = value;
                });
            }
            .width(Constants.FULL_SCREEN)
            .height(48)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center);
          }
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 12, bottom: 4 })
          .backgroundColor($r('sys.color.comp_background_primary'))

          Row() {
            Image($r('app.media.icon_payment'))
              .width(40)
              .height(40)
              .borderRadius(12);

            Text('华为支付')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 });

            Blank();

            Checkbox()
              .select(true)
              .shape(CheckBoxShape.CIRCLE);
          }
          .width(Constants.FULL_SCREEN)
          .borderRadius(16)
          .padding(12)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .alignItems(VerticalAlign.Center)
          }
        }.layoutWeight(1).justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16, top: 12 });

        Row() {
          Row() {
            Text(`共${this.purchaseInfo.count}件，`)
              .fontSize(12)
              .fontColor($r('sys.color.font_tertiary'))
            Text('合计：')
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
            Text('￥')
              .fontSize(12)
              .fontColor($r('sys.color.warning'))
              .fontWeight(FontWeight.Medium)
            Text(`${formatPriceToNumber(this.purchaseInfo.count *
              this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index])}`)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.warning'))
          }

          Blank().layoutWeight(1)

          Button('提交订单')
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .height(40)
            .width(96)
            .borderRadius($r('sys.float.corner_radius_level10'))
            .padding({ top: 10, bottom: 10, left: 16, right: 16 })
            .onClick(() => {
              this.purchase();
            })
        }
        .width(Constants.FULL_SCREEN)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16, top: 12, bottom: 36 })
        .backgroundColor($r('sys.color.background_primary'))
      }.backgroundColor($r('sys.color.background_secondary')) ;
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.purchaseInfo = context.pathInfo.param as PurchaseInfo;
      Api.listAddresses().then((list: AddressDTO[]) => {
        const defaultAddr = list.find((item: AddressDTO) => item.isDefault);
        if (defaultAddr) {
          this.selectedAddress = defaultAddr;
        } else if (list.length > 0) {
          this.selectedAddress = list[0];
        }
      });
    });
  }

  aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  buildOrderFromPurchase(orderSn: string): Order {
    let order = new Order();
    order.orderSn = orderSn;
    order.orderName = this.purchaseInfo.commodityInfo.goodsName;
    order.orderStatus = 1;
    order.orderType = 1;
    order.orderRemark = this.remark;
    order.goodsBanner = this.purchaseInfo.commodityInfo.banner;
    order.goodsRetailPrice = this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index];
    order.goodsCounterPrice = this.purchaseInfo.commodityInfo.counterPrice[this.purchaseInfo.index];
    order.goodsCount = this.purchaseInfo.count;
    order.sfc = this.purchaseInfo.sfc;
    order.amount = this.purchaseInfo.count *
      this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index];
    order.commodityId = this.purchaseInfo.commodityInfo.id;
    order.createTime = getCurrentTime();
    order.openId = this.openId ?? '';
    return order;
  }

  async openCashierPicker(orderSn: string, amount: number) {
    const order = this.buildOrderFromPurchase(orderSn);
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
              ToastDialog.showToast({ message: '微信拉起失败' });
            }
          }
        } catch (err) {
          Logger.info('pay fail with reason ' + JSON.stringify(err));
        }
      })
      .onWillDismiss((reason: DismissReason) => {
        if (reason !== DismissReason.TOUCH_OUTSIDE) {
          this.mainPathStack.replacePathByName(NavPathName.COMMODITY_ORDER_DETAIL, order);
          cashierPicker.close();
        }
      });

    aggregatedPaymentService.registerPaymentCallback(
      async (_type: PaymentType, isSuccess: boolean) => {
        if (!isSuccess) {
          ToastDialog.showToast({ message: '本地调试阶段，模拟支付成功回调' });
        }
        await https.updateOrder({ orderSn: orderSn, orderStatus: 5 } as UpdateOrderRequest);
        order.orderStatus = 5;
        this.mainPathStack.replacePathByName(NavPathName.COMMODITY_ORDER_DETAIL, order);
        cashierPicker.close();
      },
    );

    cashierPicker
      .reset()
      .setAmount(amount * 100)
      .setTradeSummary(this.purchaseInfo.commodityInfo.goodsName)
      .open();
  }

  async purchase() {
    const data: CreateOrderRequest = {
      appId: '',
      commodityId: this.purchaseInfo.commodityInfo.id,
      orderStatus: Constants.MODE === 'MOCK' ? 1 : 0,
      orderType: 1,
      orderRemark: this.remark,
      goodsCount: this.purchaseInfo.count,
      openId: this.openId ?? '',
      orderSn: doRandBySync(),
      createTime: getCurrentTime(),
      sfc: this.purchaseInfo.sfc,
      amount: (this.purchaseInfo.count *
      this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index]),
      passengerId: 0,
      id: 0,
      planCheckInDate: '',
      planCheckOutDate: '',
      checkInPersonNum: 0,
      dayCount: 0,
      count: 0,
      goodsBanner: '',
    };

    const res = await https.createOrder(data);

    if (res.code === 200) {
      const totalAmount = this.purchaseInfo.count *
        this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index];
      this.openCashierPicker(data.orderSn, totalAmount);
    }
  }
}
