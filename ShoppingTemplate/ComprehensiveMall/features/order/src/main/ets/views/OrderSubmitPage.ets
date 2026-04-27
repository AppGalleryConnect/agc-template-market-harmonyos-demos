import { AddressManageUtil } from 'address_management';
import { aggregatedPaymentService } from 'aggregated_payment';
import { iData, routerStack } from 'lib_foundation';
import { DiscountItem, OrderSkuItem, PreOrderInfoReq, ShippingOption } from 'lib_network';
import { NavTitleBar } from 'lib_widget';
import { CouponsController } from 'coupons';
import { CouponApis } from 'lib_network';
import { PopupSheet } from 'module_shopping_cart';
import { OrderSubmitVM } from '../viewmodels/OrderSubmitVM';
import { ShippingInfoButton } from '../components/ShippingInfoButton';
import { OrderItemCard } from '../components/OrderItemCard';

@Builder
export function buildOrderSubmitPage() {
  OrderSubmitPage()
}

@ComponentV2
export struct OrderSubmitPage {
  vm: OrderSubmitVM = new OrderSubmitVM();
  @Local
  showPriceDetail: boolean = false;
  @Local
  popupMaskHeight: Length = '';
  @Local
  showRemarkSheet: boolean = false;

  aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  build() {
    NavDestination() {
      NavTitleBar({
        title: '确认订单',
        titleColor: $r('app.color.font_color_level1_invert'),
        arrowColor: $r('app.color.font_color_level1_invert'),
      })

      Scroll() {
        Column() {
          if (this.vm.isLoading) {
            LoadingProgress().width(32).height(32);
          } else {
            this.shippingInfoBuilder();
            this.productInfoBuilder();
          }
        }
      }
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .padding(16);

      PopupSheet({
        visible: this.showPriceDetail!!,
        maskHeight: this.popupMaskHeight,
        customContentBuilder: () => {
          this.priceDetailPopupBuilder();
        },
        title: '金额明细',
      })
        .backgroundColor(Color.White)
        .onAreaChange((_ov, nv) => {
          if (nv.globalPosition.y) {
            this.popupMaskHeight = nv.globalPosition.y;
          }
        });

      this.bottomButtonBuilder();
    }
    .onReady((context) => {
      const params = context.pathInfo.param as PreOrderInfoReq | undefined;
      if (params) {
        this.vm.initData(params);
      }
    })
    .hideTitleBar(true)
    .linearGradient({
      colors: [[$r('app.color.theme_color'), 0.1], [$r('app.color.background_color_grey'), 0.5]],
    });
  }

  @Builder
  shippingInfoBuilder() {
    Column() {
      ShippingInfoButton({
        onShippingIndexChange: (index) => {
          this.vm.shippingIndex = index;
        },
      })
        .margin({ bottom: 16 });
      if (this.vm.shippingIndex === ShippingOption.EXPRESS) {
        Row() {
          Image($r('app.media.ic_address'))
            .width(24)
            .margin({ right: 16 });
          Row() {
            Column() {
              Text(this.vm.customerAddress).addressInfoStyle();
              Text(this.vm.customerName + ' ' + this.vm.customerPhone).customerLabelStyle();
            }
            .layoutWeight(1)
            .margin({ right: 16 })
            .alignItems(HorizontalAlign.Start);

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('app.color.font_color_level3')])
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .onClick(() => {
          AddressManageUtil.goToAddressListPage(routerStack.getActiveStack(), (data) => {
            this.vm.customerAddress = data.province + data.city + data.district + data.street + data.detail;
            this.vm.customerName = data.name;
            this.vm.customerPhone = data.phone;
            this.vm.city = data.city;
            this.vm.getPosition = {
              latitude: data.latitude,
              longitude: data.longitude,
            }
            routerStack.pop()
          });
        })
      } else if (this.vm.shippingIndex === ShippingOption.SELF_PICK_UP) {
        Row() {
          Image($r('app.media.shop'))
            .width(24)
            .margin({ right: 16 });
          Column() {
            Text(this.vm.SHOP_ADDRESS).addressInfoStyle();
            Text() {
              Span('预留电话');
              Span(' ').letterSpacing(2);
              Span(this.vm.SHOP_PHONE).fontColor($r('app.color.theme_color'));
            }.customerLabelStyle();
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
        };
      }
    }.containerStyle();
  }

  @Builder
  productInfoBuilder() {
    Column() {
      List() {
        ForEach(this.vm.skuList, (item: OrderSkuItem) => {
          ListItem() {
            OrderItemCard({
              sku: item,
            });
          };
        }, (item: OrderSkuItem, index: number) => index + '__' + item.skuCode);
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

      this.infoItemBuilder({
        label: '配送服务',
        content: this.vm.ShippingLabel,
      });

      ForEach(this.vm.cartPrice.discountList, (discount: DiscountItem) => {
        if (discount.type === 2) {
          this.infoItemBuilder({
            label: discount.label,
            content: '-¥' + discount.discountPrice,
            contentColor: $r('app.color.theme_color'),
            callback: () => {
              const controller = new CouponsController()
              controller.themeColor = $r('app.color.theme_color')
              controller.totalMoney = this.vm.cartPrice.originalPrice
              controller.selectedId = this.vm.discountId
              controller.reduce = this.vm.discountAmount
              controller.onLoadCoupons = async () => {
                const res = await CouponApis.getCoupons({ userId: iData.global.userInfo.phone })
                return res.code === 0 ? res.couponsList : []
              }
              controller.onConfirm = (data) => {
                this.vm.addCouponDiscount(data.reduce)
                this.vm.discountId = data.selectId;
                this.vm.discountAmount = data.reduce;
              }
              controller.select(this.getUIContext());
            },
          });
        } else {
          this.infoItemBuilder({
            label: discount.label,
            content: '-¥' + discount.discountPrice,
            contentColor: $r('app.color.theme_color'),
          });
        }
      },
        (discount: DiscountItem) => discount.type + '__' + discount.discountPrice)

      this.infoItemBuilder({
        label: '订单总金额',
        content: '¥' + this.vm.cartPrice.finalPrice,
      });
      this.infoItemBuilder({
        label: '备注',
        content: this.vm.remark,
        callback: () => {
          this.showRemarkSheet = true;
        },
      });
    }
    .containerStyle()
    .bindSheet($$this.showRemarkSheet, this.remarkEditSheet(), {
      height: 400,
      title: { title: '订单备注' },
      backgroundColor: $r('app.color.background_color_primary'),
      onWillDismiss: (action) => {
        this.vm.remarkCache = '';
        action.dismiss();
      },
    });
  }

  @Builder
  bottomButtonBuilder() {
    Row() {
      Column() {
        Text() {
          Span(`共${this.vm.totalProductCount}件, `).fontColor($r('app.color.font_color_level3'));
          Span('合计: ');
          Span('¥ ').fontWeight(FontWeight.Medium).fontColor($r('app.color.theme_color'));
          Span(this.vm.cartPrice.finalPrice.toString())
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.theme_color'))
            .fontSize($r('app.float.font_size_16'));
        }
        .fontSize($r('app.float.font_size_12'))
        .fontColor($r('app.color.font_color_level1'))
        .margin({ bottom: 4 });

        Row() {
          Text('查看明细')
            .fontColor($r('app.color.theme_color'))
            .fontSize($r('app.float.font_size_12'));
          Image($r('sys.media.ohos_ic_public_arrow_up'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.theme_color'));
        }
        .onClick(() => {
          this.showPriceDetail = !this.showPriceDetail;
        });
      }
      .margin({ right: 16 })
      .alignItems(HorizontalAlign.End);

      Button('提交订单')
        .backgroundColor($r('app.color.theme_color'))
        .onClick(() => {
          this.vm.onSubmit();
        });
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding({
      top: 8,
      bottom: 8,
      left: 16,
      right: 16,
    });
  }

  @Builder
  infoItemBuilder($$: InfoBuilderParam) {
    Row() {
      Text($$.label)
        .fontColor($r('app.color.font_color_level2'))
        .fontSize($r('app.float.font_size_14'))

      Blank().constraintSize({ minWidth: 48 })

      Row() {
        Text($$.content)
          .formContentStyle($$.contentColor)
          .layoutWeight(1)
          .textAlign(TextAlign.End)
        if ($$.callback) {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('app.color.font_color_level3')])
            .margin({ left: $r('app.float.space_xs') })
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        if($$.callback){
          $$.callback();
        }
      });
    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .margin({ top: 16 });
  }

  @Builder
  priceDetailPopupBuilder() {
    Column({ space: 14 }) {
      this.PopupContentItem('商品金额', this.vm.cartPrice.originalPrice);
      // 是否有优惠
      ForEach(this.vm.cartPrice.discountList, (discount: DiscountItem) => {
        this.PopupContentItem(discount.label, discount.discountPrice, true);
      }, (discount: DiscountItem) => discount.type + '__' + discount.discountPrice)
      Row() {
        Text('合计')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium);

        Text() {
          Span('¥').fontSize(12);
          Span(this.vm.cartPrice.finalPrice.toString());
        }
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color_primary'));
  }

  @Builder
  PopupContentItem(label: string, value: number, isDiscount: boolean = false) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Regular);

      Text() {
        if (isDiscount) {
          Span('-')
        }
        Span(`¥${value}`)
      }
      .fontSize(14)
      .fontColor($r('app.color.font_color_level1'))
      .fontWeight(FontWeight.Medium);
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  remarkEditSheet() {
    Column() {
      Scroll() {
        Column() {
          TextArea({ text: this.vm.remark, placeholder: '选填，建议先与商家沟通后再填写' })
            .width('100%')
            .height(120)
            .caretColor($r('app.color.theme_color'))
            .fontColor($r('app.color.font_color_level1'))
            .fontSize($r('app.float.font_size_14'))
            .placeholderFont({ size: $r('app.float.font_size_14') })
            .maxLength(100)
            .showCounter(true)
            .barState(BarState.Off)
            .enterKeyType(EnterKeyType.Done)
            .onChange((value: string) => {
              this.vm.remarkCache = value;
            })
            .borderRadius(12)
            .backgroundColor($r('app.color.background_color_button_grey'));
        }
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)

      Button('确定')
        .width('100%')
        .height(40)
        .margin({ bottom: $r('app.float.space_m') })
        .backgroundColor($r('app.color.theme_color'))
        .onClick(() => {
          this.vm.remark = this.vm.remarkCache;
          this.showRemarkSheet = false;
        });
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor($r('app.color.background_color_primary'));
  }
}

@Styles
function containerStyle() {
  .backgroundColor($r('app.color.background_color_primary'))
  .padding(12)
  .borderRadius($r('app.float.border_radius_l'))
  .width('100%')
  .margin({ bottom: 16 });
}

@Extend(Text)
function addressInfoStyle() {
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .margin({ bottom: 2 });
}

@Extend(Text)
function customerLabelStyle() {
  .fontColor($r('app.color.font_color_level3'))
  .fontSize($r('app.float.font_size_14'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis });
}

@Extend(Text)
function formContentStyle(color?: ResourceColor) {
  .fontColor(color ? color : $r('app.color.font_color_level1'))
  .fontSize($r('app.float.font_size_14'))
  .fontWeight(FontWeight.Medium)
  .lineHeight(20)
}

class InfoBuilderParam {
  label: string = '';
  content: string = '';
  contentColor?: ResourceColor;
  callback?: () => void;
}