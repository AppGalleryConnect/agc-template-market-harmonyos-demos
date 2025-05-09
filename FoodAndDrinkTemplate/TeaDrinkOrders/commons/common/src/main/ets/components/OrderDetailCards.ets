import { Decimal } from '@kit.ArkTS';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { CarGoodInfo, GoodsOfOrder, MyOrderInfo, OrderModel, StoreInfo } from '../models/ResponseModel';
import { copyString, getAnonymousTel } from '../utils/Utils';
import { CommonUrl, Constants, GoodSpecEnum, OrderStateEnum, OrderTypeEnum, orderTypeMap } from '../constants/Common';
import { StoreInfoModel } from '../models/StorageModel';
import { RouterMap } from '../constants/RouterMap';
import { HwMapModel } from '../models/RouterModel';
import { CallTelSheetBuilder } from './CallTelSheet';
import { HwMapComp } from './HwMapComp';
import { MapLocation } from '../models/ParamsModel';
import { PkgGoodComp } from './PkgGoodComp';

@Styles
function cardStyle() {
  .width(Constants.FULL_SIZE)
  .constraintSize({ maxWidth: Constants.FULL_SIZE })
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(12)
  .padding(12)
  .margin({
    left: 16,
    right: 16,
  });
}

@ComponentV2
export struct MakingCard {
  @Param @Require orderState: number
  @Param @Require orderType: number

  @Computed
  get isDelivering() {
    return [OrderStateEnum.DELIVERING, OrderStateEnum.COMPLETED].includes(this.orderState)
  }

  @Computed
  get isFinished() {
    return this.orderState === OrderStateEnum.COMPLETED
  }

  build() {
    Column() {
      Row() {
        Text(orderTypeMap[this.orderType??OrderTypeEnum.PICK_SELF])
          .fontSize(10)
          .fontColor('#61860B')
          .padding({
            left: 6,
            right: 6,
            top: 1,
            bottom: 1,
          })
          .borderRadius(8)
          .backgroundColor('#3386AD2B')
      }.width(Constants.FULL_SIZE)

      Row() {
        Column() {
          Image($r('app.media.ic_ordered')).width(40).height(40)
          Text($r('app.string.process_ordered')).fontSize(10).fontColor($r('sys.color.font_primary')).margin({ top: 9 })
        }

        Row() {
          Image($r('app.media.ic_process')).width(6).height(6)
          Image($r('app.media.ic_process')).width(8).height(8).margin({ left: 12 })
        }.margin({ top: 16 })

        Column() {
          Image($r('app.media.ic_making')).width(40).height(40)
          Text($r('app.string.process_making')).fontSize(10).fontColor($r('sys.color.font_primary')).margin({ top: 9 })
        }

        if (this.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {
          Row() {
            Image(this.isDelivering ? $r('app.media.ic_process') : $r('app.media.ic_process_grey')).width(6).height(6)
            Image(this.isDelivering ? $r('app.media.ic_process') : $r('app.media.ic_process_grey'))
              .width(8)
              .height(8)
              .margin({ left: 12 })
          }.margin({ top: 16 })

          Column() {
            Image(this.isDelivering ? $r('app.media.ic_delivery') : $r('app.media.ic_delivery_grey'))
              .width(40)
              .height(40)
            Text($r('app.string.delivering'))
              .fontSize(10)
              .fontColor(this.isDelivering ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
              .margin({ top: 9 })
          }
        }

        Row() {
          Image(this.isFinished ? $r('app.media.ic_process') : $r('app.media.ic_process_grey')).width(8).height(8)
          Image(this.isFinished ? $r('app.media.ic_process') : $r('app.media.ic_process_grey'))
            .width(6)
            .height(6)
            .margin({ left: 12 })
        }.margin({ top: 16 })

        Column() {
          Image(this.isFinished ? $r('app.media.ic_finished') : $r('app.media.ic_finish_grey')).width(40).height(40)
          Text($r('app.string.process_finished'))
            .fontSize(10)
            .fontColor(this.isFinished ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
            .margin({ top: 9 })
        }
      }
      .width(Constants.FULL_SIZE)
      .height(66)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .margin({ top: 28, left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)

      if (this.orderType === OrderTypeEnum.PICK_SELF) {
        Row() {
          Row() {
            Image($r('app.media.ic_qr_code'))
              .width(136)
              .height(136)
          }
          .padding(8)
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(12)
        }.margin({ top: 16 }).backgroundColor('#F1F3F5').borderRadius(12).padding(4)

        Row() {
          Text($r('app.string.show_pick_num'))
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }.margin({ top: 12 })
      }
    }.cardStyle()
  }
}

@ComponentV2
export struct MapCard {
  @Param @Require locations: Array<MapLocation>
  @Param @Require selectStore: MapLocation

  build() {
    Column() {
      HwMapComp({
        mapHeight: 208,
        locations: this.locations,
        showMyLocation: false,
        selectStore: this.selectStore,
        mapBorderRadius: 12,
      })
    }.cardStyle().padding(4)
  }
}

@ComponentV2
export struct StoreCard {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Param storeInfo: StoreInfo = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!.storeInfo;
  @Param hasLogo: boolean = false
  @Local callTelSheet: boolean = false

  build() {
    Column() {
      Row() {
        Row() {
          if (this.hasLogo) {
            Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeInfo.logo}`)
              .width(40)
              .height(40)
              .borderRadius(4)
              .margin({ right: 11 })
          }
          Column() {
            Text(this.storeInfo.name)
              .fontSize(18)
              .fontWeight(500)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.storeInfo.address)
              .fontSize(12)
              .fontColor($r('sys.color.mask_secondary'))
              .lineHeight(14)
              .constraintSize({ maxWidth: 190 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        }.layoutWeight(1)

        Row() {
          Image($r('app.media.ic_tel')).width(24)
            .onClick(() => {
              this.callTelSheet = true
            })
          Image($r('app.media.ic_map')).width(24)
            .margin({ left: 12 })
            .onClick(() => {
              let coordinates = this.storeInfo.coordinates?.split(',')
              if (coordinates?.length === 2) {
                let latitude: number = Number(coordinates[0])
                let longitude: number = Number(coordinates[1])
                this.pageStack.pushPathByName(RouterMap.HW_MAP,
                  { latitude, longitude } as HwMapModel)
              } else {
                promptAction.showToast({ message: $r('app.string.store_address_error') })
              }
            })
        }.width(80).justifyContent(FlexAlign.End)
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .justifyContent(FlexAlign.SpaceBetween)
    }.cardStyle()
    .bindSheet($$this.callTelSheet, CallTelSheetBuilder(this.storeInfo.tel, () => {
      this.closeTelSheet()
    }), {
      height: 290,
      blurStyle: BlurStyle.Thick,
      backgroundColor: '#E6FFFFFF',
      showClose: false,
    });
  }

  closeTelSheet() {
    this.callTelSheet = false
  }
}

@ComponentV2
export struct GoodsComp {
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Param @Require goodList: Array<CarGoodInfo | GoodsOfOrder>;
  @Param bagMoney: number = 0
  @Param readonly: boolean = true
  @Event changeSelectBag: (value: boolean) => void = () => {
  };

  build() {
    Column() {
      // 单品详情
      Column() {
        List({ space: 16 }) {
          ForEach(this.goodList, (goodInfo: CarGoodInfo | GoodsOfOrder) => {
            ListItem() {
              GoodsCard({ goodInfo });
            };
          }, (goodInfo: CarGoodInfo | GoodsOfOrder) => goodInfo.id);
        };

        Divider().margin({ top: 12, bottom: 10 })
        Row() {
          Column() {
            Text($r('app.string.insulation_bag')).fontSize(14).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.insulation_bag_desc'))
              .fontSize(14)
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Row() {
            Text($r('app.string.currency_symbol'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text(this.bagMoney.toString())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            if (!this.readonly) {
              Checkbox({ name: 'selectBag', group: '' })
                .height(12)
                .width(12)
                .selectedColor($r('app.color.mainColor'))
                .shape(CheckBoxShape.CIRCLE)
                .margin({ left: 4 })
                .onChange(value => {
                  this.changeSelectBag(value)
                })
            }
          }
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)
      }.cardStyle();
    }
  }
}

@ComponentV2
export struct GoodsCard {
  @Param @Require goodInfo: CarGoodInfo;

  build() {
    Column() {
      Row() {
        Row() {
          Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.goodInfo.logo}`).width(60).height(60).borderRadius(8)
          Column() {
            Column() {
              Text(this.goodInfo.name).fontSize(14).fontColor($r('sys.color.font_primary')).maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(this.goodInfo.spec?.split(',').join(' | '))
                .fontSize(10)
                .fontColor($r('sys.color.mask_tertiary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .visibility(this.goodInfo.specType !== GoodSpecEnum.PACKAGE_TYPE ? Visibility.Visible : Visibility.None)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1).height(60)

            Text(`x${this.goodInfo.num}`)
              .fontSize(10)
          }
          .height(60)
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1);
        }.layoutWeight(1);

        Row() {
          Text() {
            Span($r('app.string.currency_symbol'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Span(new Decimal(this.goodInfo.money).mul(new Decimal(this.goodInfo.num)).toString())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          };
        }.height(60).alignItems(VerticalAlign.Top).margin({ left: 4 })

      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);

      PkgGoodComp({ pkgGoods: this.goodInfo.combination })
        .margin({ top: 12 })
        .visibility(this.goodInfo.specType === GoodSpecEnum.PACKAGE_TYPE ? Visibility.Visible : Visibility.None)
    }
  }
}

@ComponentV2
export struct ReductionCard {
  @Param @Require orderInfo: OrderModel
  @Param readonly: boolean = true
  @Event goCouponPage: () => void = () => {
  }

  build() {
    Column() {
      // 优惠
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_full_reduction')).width(16)
            Text($r('app.string.store_discount_label'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(20)
              .margin({ left: 8 })
          }

          Text() {
            Span($r('app.string.currency_symbol_pre_params', '-')).fontSize(8).fontWeight(500).lineHeight(14)
            Span(`${Number(this.orderInfo.mjMoney)}`)
              .fontSize(14)
              .fontWeight(500)
              .lineHeight(20)
          }.fontColor('#E84026')
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .padding({ top: 10, bottom: 10 })
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Row() {
            Image($r('app.media.ic_vouchers')).width(16)
            Text($r('app.string.coupon_label'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(20)
              .margin({ left: 8 })
          }

          Row() {
            if (this.readonly || this.orderInfo.yhqMoney !== '0') {
              Text() {
                Span($r('app.string.currency_symbol_pre_params', '-'))
                  .fontSize(8)
                  .fontWeight(500)
                  .lineHeight(14)
                Span(`${Number(this.orderInfo.yhqMoney)}`)
                  .fontSize(14)
                  .fontWeight(500)
                  .lineHeight(20)
              }.fontColor('#E84026')
            } else {
              Text($r('app.string.select_coupon')).fontSize(12).fontColor($r('sys.color.mask_tertiary'))
            }
          }.onClick(() => {
            if (!this.readonly) {
              this.goCouponPage()
            }
          })
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .padding({ top: 10, bottom: 10 })
        .justifyContent(FlexAlign.SpaceBetween)

        if (Number(this.orderInfo.orderType) === OrderTypeEnum.TAKEAWAY_DELIVERY) {
          Row() {
            Row() {
              Image($r('app.media.ic_packet')).width(16)
              Text($r('app.string.packing_box'))
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(20)
                .margin({ left: 8 })
            }

            Row() {
              Text() {
                Span($r('app.string.currency_symbol'))
                  .fontSize(8)
                Span(`${this.orderInfo.boxMoney}`).fontSize(12)
              }.fontColor($r('sys.color.font_primary'))

            }
          }
          .width(Constants.FULL_SIZE)
          .height(40)
          .padding({ top: 10, bottom: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
        }

      }

      Divider().margin({ top: 10, bottom: 10 })
      // 实付金额
      Row() {
        Text($r('app.string.discount_money')).fontSize(14).fontColor('#E84026')
        Text($r('app.string.currency_symbol'))
          .fontSize(8)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
          .fontColor('#E84026')
        Text(`${Number(this.orderInfo.mjMoney) + Number(this.orderInfo.yhqMoney)}`)
          .fontSize(14)
          .fontColor('#E84026')
          .margin({ left: 2 })

        Text($r('app.string.should_pay'))
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 16 })
        Text($r('app.string.currency_symbol'))
          .fontSize(8)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
          .fontColor($r('sys.color.font_primary'))
        Text(`${Number(this.orderInfo.money)}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(Constants.FULL_SIZE)
      .padding({ top: 16 })
      .justifyContent(FlexAlign.End)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })

    }.cardStyle().alignItems(HorizontalAlign.Start)
  }
}

@ComponentV2
export struct DetailMoreCard {
  @Param @Require orderInfo: MyOrderInfo
  @Param readonly: boolean = true
  @Event goRemarkPage: () => void = () => {
  }
  @Event showCutlerySheet: () => void = () => {
  }

  @Computed
  get remarkStr() {
    let result: ResourceStr = ''
    if (!this.orderInfo.order.note) {
      result = $r('app.string.fill_remarks')
      if (this.readonly) {
        result = $r('app.string.none')
      }
    } else {
      result = this.orderInfo.order.note
    }
    return result
  }

  @Computed
  get addressStr() {
    return `${this.orderInfo.address.addressPre}${this.orderInfo.address.addressNum}，${this.orderInfo.address.name}，${getAnonymousTel(this.orderInfo.address.tel)}`
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.remark'))
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
        Row() {
          Text(this.remarkStr)
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
            .textAlign(TextAlign.End)
            .width(200)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }.justifyContent(FlexAlign.End).layoutWeight(1)
      }
      .width(Constants.FULL_SIZE)
      .height(44)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (!this.readonly) {
          this.goRemarkPage()
        }
      })

      Row() {
        Text($r('app.string.dinner_num_label'))
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
        Row() {
          Text(this.orderInfo.order.cutlery)
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.End)
            .width(200)
        }.justifyContent(FlexAlign.End).layoutWeight(1)
      }
      .width(Constants.FULL_SIZE)
      .height(44)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (!this.readonly) {
          this.showCutlerySheet()
        }
      })

      if (this.readonly) {
        // 下单时间
        Row() {
          Text($r('app.string.order_time'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
          Row() {
            Text(this.orderInfo.order.time)
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)
          }.justifyContent(FlexAlign.End).layoutWeight(1)
        }
        .width(Constants.FULL_SIZE)
        .height(44)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .justifyContent(FlexAlign.SpaceBetween)

        // 订单号
        Row() {
          Text($r('app.string.order_id'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
          Row() {
            Text(this.orderInfo.order.orderNum)
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)
            Text($r('app.string.copy'))
              .fontSize(8)
              .fontColor($r('sys.color.mask_secondary'))
              .textAlign(TextAlign.End)
              .margin({ left: 4 })
              .borderRadius(23)
              .borderWidth(1)
              .borderColor('#4D000000')
              .height(16)
              .padding({ left: 8, right: 8 })
              .onClick(() => {
                copyString(this.orderInfo.order.oid || '')
              })
          }.justifyContent(FlexAlign.End).layoutWeight(1)
        }
        .width(Constants.FULL_SIZE)
        .height(44)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .justifyContent(FlexAlign.SpaceBetween)

        // 取餐方式
        Row() {
          Text($r('app.string.order_type'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
          Row() {
            Text(Number(this.orderInfo.order.orderType) === OrderTypeEnum.PICK_SELF ? $r('app.string.order_pick_self') :
            $r('app.string.takeaway_delivery'))
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)
          }.justifyContent(FlexAlign.End).layoutWeight(1)
        }
        .width(Constants.FULL_SIZE)
        .height(44)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .justifyContent(FlexAlign.SpaceBetween)

        // 配送信息
        Row() {
          Text($r('app.string.delivery_info'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
          Text(this.addressStr)
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .textAlign(TextAlign.End)
        }
        .width(Constants.FULL_SIZE)
        .height(44)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .justifyContent(FlexAlign.SpaceBetween)
        .visibility(Number(this.orderInfo.order.orderType) === OrderTypeEnum.TAKEAWAY_DELIVERY ? Visibility.Visible :
        Visibility.None)
      }
    }.cardStyle()
  }
}