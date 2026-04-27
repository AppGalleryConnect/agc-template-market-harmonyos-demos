import { map, MapComponent } from '@kit.MapKit';
import { customInfoWindowCallback } from '@hms.core.map.MapComponent';
import {
  CommonLoading,
  CommonNoticeBar,
  CommonTitle,
  EmitterUtils,
  ParcelStatus,
  RouterMap,
  RouterModule,
  ShippingType,
} from 'lib_foundation';
import { AddressInfoModel } from 'module_template';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';
import { ActionMenuItem, NavItem } from '../models/Model';


@Builder
export function orderDetailPageBuilder() {
  OrderDetailPage()
}

@ComponentV2
struct OrderDetailPage {
  vm: OrderDetailPageVM = new OrderDetailPageVM();
  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: customInfoWindowCallback = this.customInfoWindowBuilder;

  aboutToAppear() {
    this.vm.initMap();
    this.vm.initData();

    EmitterUtils.on('refreshOrderDetail', () => {
      this.vm.mapController?.clear();
      this.vm.queryOrderInfo();
    })
  }

  aboutToDisappear(): void {
    EmitterUtils.off('refreshOrderDetail')
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '寄快递',
        onBack: () => {
          RouterModule.popToName(RouterMap.MAIN_ENTRY);
        },
      })
      Stack() {
        Scroll() {
          Column() {
            Row() {
              Column({ space: 8 }) {
                Text(this.vm.getStateText())
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))

                Text(this.vm.getSubTitle())
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .alignItems(HorizontalAlign.Start)

              Row({ space: 4 }) {
                Text(`寄件码 ${this.vm.orderInfo.dropOffCode}`)
                  .fontColor(Color.White)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .lineHeight(19)
              }
              .padding({
                left: 12,
                right: 12,
                top: 8,
                bottom: 8,
              })
              .backgroundColor($r('sys.color.comp_background_emphasize'))
              .justifyContent(FlexAlign.Center)
              .borderRadius(16)
              .visibility(this.vm.orderInfo.status === ParcelStatus.CANCELED ? Visibility.Hidden : Visibility.Visible)
            }
            .width('100%')
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding,
            })
            .margin({ bottom: 8 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Bottom)

            Stack({ alignContent: Alignment.Bottom }) {
              Stack({ alignContent: Alignment.Top }) {
                MapComponent({
                  mapOptions: this.vm.mapOptions,
                  mapCallback: this.vm.callback,
                  customInfoWindow: this.customInfoWindow,
                })
                  .width('100%')
                  .height(360)

                if (this.vm.showTip) {
                  Row() {
                    CommonNoticeBar({
                      text: '部分快递需要当面实名认证，请配合出示证件。',
                      showIcon: true,
                      icon: $r('sys.symbol.xmark'),
                      clickAction: () => {
                        this.vm.showTip = false
                      },
                    })
                  }
                  .width('100%')
                  .padding({
                    left: this.vm.breakPointModel.pagePadding,
                    right: this.vm.breakPointModel.pagePadding,
                  })
                  .margin({ top: 16 })
                }
              }
              .width('100%')
              .height(this.vm.orderInfo.status === ParcelStatus.CANCELED ? 360 : 394)

              if (this.vm.orderInfo.status !== ParcelStatus.CANCELED) {
                Column() {
                  Row() {
                    ForEach(this.vm.actionMenuList, (item: ActionMenuItem) => {
                      Column({ space: 6 }) {
                        SymbolGlyph(item.icon).fontSize(26).fontColor([$r('sys.color.icon_emphasize')])
                        Text(item.label)
                          .fontSize(12)
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_primary'))
                          .lineHeight(16)
                      }
                      .onClick(() => {
                        item.action();
                      })
                    }, (item: ActionMenuItem) => JSON.stringify(item))
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceAround)
                  .backgroundColor(Color.White)
                  .borderRadius(16)
                  .padding(12)
                }
                .padding({
                  left: this.vm.breakPointModel.pagePadding,
                  right: this.vm.breakPointModel.pagePadding,
                })
              }
            }
            .width('100%')
            .height(this.vm.orderInfo.status === ParcelStatus.CANCELED ? 360 : 394)

            // 寄/收件人信息
            Column() {
              Column() {
                this.addressInfoRow($r('app.media.ic_send_address'), this.vm.senderInfo)

                Row({ space: 12 }) {
                  SymbolGlyph($r('sys.symbol.arrow_down_circle'))
                    .fontSize(24)
                    .fontColor([$r('sys.color.icon_tertiary')])
                  Divider().color($r('sys.color.comp_divider')).layoutWeight(1)
                }
                .width('100%')

                this.addressInfoRow($r('app.media.ic_receiver_address'), this.vm.receiverInfo)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(12)
              .borderRadius(16)
              .backgroundColor(Color.White)
            }
            .width('100%')
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding,
            })
            .margin({ top: 12 })

            // 寄件订单信息
            Column() {
              Column() {
                this.shippingInfoBuilder({ label: '物品信息', value: this.vm.goodsName })
                Divider().color($r('sys.color.comp_divider')).margin({ top: 12, bottom: 12 })
                if (this.vm.orderInfo.shippingMethod === ShippingType.PICKUP_SERVICE) {
                  this.shippingInfoBuilder({ label: '选择快递', value: this.vm.expressName })
                } else {
                  this.shippingInfoBuilder({ label: '选择格口', value: this.vm.gridText })
                }

                Divider().color($r('sys.color.comp_divider')).margin({ top: 12, bottom: 12 })
                this.shippingInfoBuilder({ label: '付款方式', value: this.vm.payMethodText })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(12)
              .borderRadius(16)
              .backgroundColor(Color.White)
            }
            .width('100%')
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding,
            })
            .margin({ top: 12 })
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .align(Alignment.Top)

        if (this.vm.showLoadingMask) {
          Column() {
            CommonLoading({ showLoadingProgress: this.vm.showLoadingMask })
          }
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.background_secondary'))
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ bottom: this.vm.windowModel.windowBottomPadding })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      RouterModule.popToName(RouterMap.MAIN_ENTRY);
      return true;
    })
  }

  // 自定义信息窗Builder
  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    if ($$.marker) {
      Column() {
        Text($$.marker.getTitle())
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.White)

        Text($$.marker.getSnippet())
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.White)
      }
      .constraintSize({ maxWidth: 168 })
      .padding(8)
      .borderRadius(8)
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .margin({ bottom: 4 })
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  addressInfoRow(icon: ResourceStr, addressInfo: AddressInfoModel) {
    Row() {
      Image(icon).width(24).height(28).flexShrink(0)

      Column({ space: 8 }) {
        Row() {
          Text(addressInfo.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ right: 10 })
          Text(addressInfo.phone)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')

        Row() {
          Text(addressInfo.fullAddress)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
            .lineHeight(19)
        }
        .width('100%')
      }
      .padding({ left: 12, right: 12 })
      .layoutWeight(1)
    }
  }

  @Builder
  shippingInfoBuilder($$: NavItem) {
    Row() {
      Text($$.label)
        .textFancy()
      Text($$.value)
        .textFancy()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Extend(Text)
function textFancy() {
  .fontColor($r('sys.color.font_primary'))
  .fontSize(16)
  .fontWeight(400)
  .lineHeight(21)
}