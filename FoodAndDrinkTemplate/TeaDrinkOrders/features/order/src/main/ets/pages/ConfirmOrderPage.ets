import {
  AddDnOrderReq,
  AddressComp,
  AddressInfo,
  calculatorUtils,
  CarGoodInfo,
  ConfirmOrderRouter,
  Constants,
  CouponCard,
  CouponStateEnum,
  FuncType,
  GoodsComp,
  HttpRequest,
  MyCoupon,
  NavHeaderBar,
  OrderDetailRouter,
  OrderTypeEnum,
  Reduction,
  RouterMap,
  SheetHeaderComp,
  StoreInfoModel,
  StoreMakeInfo,
  Utils,
  WindowModel,
} from 'common/Index';
import { AppStorageV2, NavPushPathHelper, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Decimal } from '@kit.ArkTS';
import { AddressSheetBuilder } from '../components/AddressSheetComp';

@Builder
export function ConfirmOrderPageBuilder() {
  ConfirmOrderPage()
}

@ComponentV2
struct ConfirmOrderPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Consumer('reductionList') reductionList?: Array<Reduction>
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel) as StoreInfoModel;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local carGoods: Array<CarGoodInfo> = []
  @Local cutlery: ResourceStr = ''
  @Local remarks: string = ''
  @Local remarksTemp: string = ''
  // 订单总金额
  @Local totalMoney: number = 0
  @Local selectArray: Array<string> = []
  @Local numOfDinerList: Array<string> = []
  @Local cutlerySheetShow: boolean = false
  @Local couponSheetShow: boolean = false
  @Local addressSheetShow: boolean = false
  @Local remarkSheet: boolean = false
  // 店铺优惠金额
  @Local reductionMoney: number = 0
  // 已选优惠券Id
  @Local selectCouponId: string = ''
  // 已选优惠券金额
  @Local selectCouponMoney: string = '0'
  // 已选优惠券Id
  @Local selectCouponIdTemp: string = ''
  // 已选优惠券金额
  @Local selectCouponMoneyTemp: string = '0'
  // 配送时间
  @Local selectTime: Date = new Date()
  @Local boxMoney: number = 0
  @Local selectBagMoney: boolean = false
  @Local storeMakeInfo: StoreMakeInfo = new StoreMakeInfo()
  // 下单id
  @Local orderId: string = ''
  @Local myCouponsUsable: Array<MyCoupon> = []
  @Local selectAddress: AddressInfo = new AddressInfo()
  pageStackHelper: NavPushPathHelper = new NavPushPathHelper(this.pageStack)
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  @Computed
  get orderSumMoney() {
    let sum = new Decimal(this.totalMoney).sub(this.reductionMoney).sub(this.selectCouponMoney).toNumber()
    if (this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {
      sum = new Decimal(sum).add(this.boxMoney).toNumber()
    }
    if (this.selectBagMoney) {
      sum = new Decimal(sum).add(this.storeModel.storeInfo.bagMoney).toNumber()
    }
    return sum > 0 ? sum : 0
  }

  async aboutToAppear(): Promise<void> {
    this.getParams()
    this.getMyCoupon()
    this.carGoods.forEach(item => {
      this.totalMoney = new Decimal(item.money || 0).mul(item.num || 0).add(this.totalMoney).toNumber()
      this.boxMoney = calculatorUtils(this.boxMoney, item.boxMoney, FuncType.ADD)
    })
    this.getReduction()
  }

  getParams() {
    let paramsArr: ConfirmOrderRouter[] =
      this.pageStack?.getParamByName(RouterMap.CONFIRM_ORDER_PAGE) as ConfirmOrderRouter[];
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1];
      this.carGoods = routerParam?.carGoods ?? [];
    }
  }

  getReduction() {
    let maxFullIndex = -1
    let maxFull = 0
    this.storeModel.storeInfo.reduction.forEach((item, index) => {
      let full = Number(item.full)
      if (item.status === 1 && this.totalMoney > full && full >= maxFull) {
        maxFull = full
        maxFullIndex = index
      }
    })
    let reduction = 0
    if (maxFullIndex >= 0) {
      reduction = Number(this.storeModel.storeInfo.reduction[maxFullIndex].reduction ?? 0)
    }
    this.reductionMoney = reduction
  }

  changeSelectBag(value: boolean) {
    this.selectBagMoney = value
  }

  confirmOrder() {
    if (this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY && !this.selectAddress.id) {
      promptAction.showToast({ message: $r('app.string.select_address_err') })
      return
    }
    if (!this.cutlery) {
      this.cutlerySheetShow = true
      return
    }
    let req = {
      money: this.orderSumMoney,
      yhqMoney: this.selectCouponMoney,
      couponId: this.selectCouponId,
      orderType: this.storeModel.orderType,
      mjMoney: `${this.reductionMoney}`,
      note: this.remarks ? this.remarks : '', // 清除默认备注
      cutlery: this.cutlery,
      boxMoney: this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY ? this.boxMoney : 0,
      bagMoney: this.selectBagMoney ? this.storeModel.storeInfo.bagMoney : 0,
    } as AddDnOrderReq
    HttpRequest.addDnOrder(this.carGoods, req, this.storeModel.storeInfo, this.selectAddress).then((resp: number) => {
      this.orderId = `${resp}`
      this.pageStackHelper.replacePathByName('order_list', RouterMap.ORDER_DETAIL_PAGE,
        { orderId: `${this.orderId}`, isOrderJump: true } as OrderDetailRouter)
    }).catch((e: BusinessError) => {
      console.error(`confirmOrder error: ${JSON.stringify(e)}.`);
      promptAction.showToast({ message: $r('app.string.place_order_failed_msg', JSON.stringify(e)) })
    })
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.white'))
    .borderRadius(8)
    .padding(12)
    .margin({
      left: 16,
      right: 16,
    })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: $r('app.string.confirm_order') })
        List({ space: 12 }) {
          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.logo')).width(40).height(40).borderRadius(4);
                Column() {
                  Row() {
                    Text(this.storeModel.storeInfo.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)
                    Image($r('app.media.ic_right')).width(12).margin({ left: 6 });
                  };

                  Row() {
                    Image($r('app.media.ic_position')).width(12);
                    Text(this.storeModel.storeInfo.address)
                      .fontSize(10)
                      .fontColor($r('sys.color.mask_secondary'))
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ left: 4 });
                  }.layoutWeight(1);
                }
                .height(40)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ left: 8 })
                .layoutWeight(1);
              }
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .width(Constants.FULL_SIZE)
              .justifyContent(FlexAlign.Start)
              .onClick(() => {
                this.pageStack?.pushPathByName(RouterMap.MERCHANT_DETAIL_PAGE, null, false)
              })

              Row() {
                Text($r('app.string.store_make_pre')).fontSize(10).fontColor($r('sys.color.font_primary'))
                Text(this.storeMakeInfo.waitNum.toString())
                  .fontSize(12)
                  .fontColor($r('app.color.mainColor'))
                  .margin({ left: 2, right: 2 })
                Text($r('app.string.store_make_post')).fontSize(10).fontColor($r('sys.color.font_primary'))

                Text($r('app.string.store_wait_time_pre'))
                  .fontSize(10)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ left: 16 })
                Text(this.storeMakeInfo.waitTime.toString())
                  .fontSize(12)
                  .fontColor($r('app.color.mainColor'))
                  .margin({ left: 2, right: 2 })
                Text($r('app.string.store_wait_time_post')).fontSize(10).fontColor($r('sys.color.font_primary'))
              }.width(Constants.FULL_SIZE).margin({ top: 6 })

              Column() {
                Divider().margin({ top: 8, bottom: 10 })
                Row() {
                  Text($r('app.string.appointment_time')).fontSize(10).fontColor($r('sys.color.font_primary'))
                  Row() {
                    Text(this.selectTime.getTime() > new Date().getTime() ? Utils.getTime(this.selectTime) :
                    $r('app.string.pick_now')).fontSize(10).fontColor($r('app.color.mainColor'))
                    Image($r('app.media.ic_right2')).width(14).margin({ left: 10 })
                  }.onClick(() => {
                    this.showTimePicker()
                  })
                }.width(Constants.FULL_SIZE).margin({ left: 7 }).justifyContent(FlexAlign.SpaceBetween)

                Divider().margin({ top: 12, bottom: 10 })
              }.visibility(this.storeModel.orderType === OrderTypeEnum.PICK_SELF ? Visibility.Visible : Visibility.None)

              Row({ space: 24 }) {
                Column() {
                  Image($r('app.media.ic_pick_self')).width(76)
                  Text($r('app.string.pick_self'))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ top: 6 })
                }
                .height(92)
                .padding(10)
                .borderWidth(1)
                .borderRadius(12)
                .layoutWeight(1)
                .borderColor(this.storeModel.orderType === OrderTypeEnum.PICK_SELF ? $r('app.color.mainColor') :
                Color.White)
                .onClick(() => {
                  this.storeModel.orderType = OrderTypeEnum.PICK_SELF
                })

                Column() {
                  Image($r('app.media.ic_takeaway_delivery')).width(76)
                  Text($r('app.string.takeaway_delivery'))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ top: 6 })
                }
                .height(92)
                .padding(10)
                .borderWidth(1)
                .borderRadius(12)
                .layoutWeight(1)
                .borderColor(this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY ? $r('app.color.mainColor') :
                Color.White)
                .onClick(() => {
                  this.storeModel.orderType = OrderTypeEnum.TAKEAWAY_DELIVERY
                })
              }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).margin({ left: 12, right: 12 })

              Column() {
                Divider().margin({ top: 12, bottom: 12 })
                Row() {
                  Text($r('app.string.select_address_cfm'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                  Image($r('app.media.ic_right2')).width(14).margin({ left: 10 })
                }
                .width(Constants.FULL_SIZE)
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 12 })
                .onClick(() => {
                  this.addressSheetShow = true
                })
                .visibility(this.selectAddress.id ? Visibility.None : Visibility.Visible)

                Row() {
                  AddressComp({ address: this.selectAddress })
                  Image($r('app.media.ic_right2')).width(14).margin({ left: 10 })
                }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
                  this.addressSheetShow = true
                }).visibility(this.selectAddress.id ? Visibility.Visible : Visibility.None)
              }
              .visibility(this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY ? Visibility.Visible :
              Visibility.None)
              .bindSheet($$this.addressSheetShow,
                AddressSheetBuilder(this.selectAddress, (selectAddress?: AddressInfo) => {
                  this.closeAddressSheet(selectAddress)
                }), {
                  height: 736,
                  blurStyle: BlurStyle.Thick,
                  showClose: false,
                })
            }.cardStyle()
          }

          ListItem() {
            GoodsComp({
              goodList: this.carGoods,
              readonly: false,
              bagMoney: this.storeModel.storeInfo.bagMoney,
              changeSelectBag: (value) => {
                this.changeSelectBag(value)
              },
            })
          }

          ListItem() {
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
                    Span(`${Number(this.reductionMoney)}`)
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
                    if (!this.selectCouponMoney || this.selectCouponMoney === '0') {
                      Text($r('app.string.select_coupon')).fontSize(12).fontColor($r('sys.color.mask_tertiary'))
                    } else {
                      Text() {
                        Span($r('app.string.currency_symbol_pre_params', '-'))
                          .fontSize(8)
                          .fontWeight(500)
                          .lineHeight(14)
                        Span(`${Number(this.selectCouponMoney)}`)
                          .fontSize(14)
                          .fontWeight(500)
                          .lineHeight(20)
                      }.fontColor('#E84026')
                    }
                    Image($r('app.media.ic_right2')).width(14).margin({ left: 10 })
                  }.onClick(() => {
                    this.selectCouponIdTemp = this.selectCouponId
                    this.selectCouponMoneyTemp = this.selectCouponMoney || '0'
                    this.couponSheetShow = true
                  })
                }
                .width(Constants.FULL_SIZE)
                .height(40)
                .padding({ top: 10, bottom: 10 })
                .justifyContent(FlexAlign.SpaceBetween)
                .bindSheet($$this.couponSheetShow, this.couponSheetBuilder(), {
                  height: 600,
                  blurStyle: BlurStyle.Thick,
                  showClose: false,
                });

                if (this.storeModel.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {
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
                        Span(`${this.boxMoney}`).fontSize(12)
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
                Text(`${Number(this.reductionMoney) + Number(this.selectCouponMoney)}`)
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
                Text(`${Number(this.orderSumMoney)}`)
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

          ListItem() {
            // 备注
            Column() {
              Row() {
                Text($r('app.string.remark'))
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                Row() {
                  Text(this.remarks || $r('app.string.fill_remarks'))
                    .fontSize(12)
                    .fontColor($r('sys.color.mask_secondary'))
                    .textAlign(TextAlign.End)
                    .width(200)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Image($r('app.media.ic_right2')).width(14).margin({ left: 10 })
                }.justifyContent(FlexAlign.End).layoutWeight(1)
              }
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                this.remarksTemp = this.remarks
                this.remarkSheet = true
              })

              Divider().margin({ top: 12, bottom: 12 })
              Row() {
                Text($r('app.string.dinner_num_label'))
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                Row() {
                  Text(this.cutlery ? this.cutlery : $r('app.string.select_dinner_num'))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_primary'))
                    .textAlign(TextAlign.End)
                    .width(200)
                    .textAlign(TextAlign.End)
                  Image($r('app.media.ic_right2')).width(14).margin({ left: 10 })
                }.justifyContent(FlexAlign.End).layoutWeight(1)
              }
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                this.cutlerySheetShow = true
              })
            }.cardStyle()
          }
        }
        .backgroundColor('#F1F3F5')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .contentStartOffset(12)
        .contentEndOffset(12)

        Row() {
          Row() {
            Text($r('app.string.total_num', this.carGoods.length)).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.total_pay')).fontSize(12).fontColor($r('sys.color.font_primary')).margin({ left: 12 })
            Text($r('app.string.currency_symbol'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 4 })
            Text(`${Number(this.orderSumMoney)}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 2 })
          }

          Button($r('app.string.commit_order'))
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.comp_background_list_card'))
            .width(120)
            .height(40)
            .padding({
              left: 20,
              right: 20,
              top: 8,
              bottom: 8,
            })
            .backgroundColor($r('app.color.mainColor'))
            .onClick(() => {
              this.confirmOrder()
            })
        }
        .width(Constants.FULL_SIZE)
        .height(56)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .justifyContent(FlexAlign.SpaceBetween)
      }.height(Constants.FULL_SIZE)
      .bindSheet($$this.remarkSheet, this.remarkSheetBuilder(), {
        height: 480,
        blurStyle: BlurStyle.Thick,
        showClose: false,
      })
    }
    .hideTitleBar(true)
    .padding({ bottom: this.windowModel.getWindowBottomHeight() })
    .bindSheet($$this.cutlerySheetShow, this.cutlerySheetBuilder(), {
      height: 480,
      blurStyle: BlurStyle.Thick,
      showClose: false,
    });
  }

  @Builder
  remarkSheetBuilder() {
    Column() {
      SheetHeaderComp({
        title: $r('app.string.remark'), close: () => {
          this.remarkSheet = false
        },
      })

      Column() {
        Column() {
          TextArea({ text: $$this.remarksTemp })
            .height(144)
            .borderRadius(8)
            .width(Constants.FULL_SIZE)
            .showCounter(true)
            .maxLength(100)
            .backgroundColor($r('sys.color.background_secondary'))
          if (this.storeModel.storeInfo.taste.length) {
            Text($r('app.string.quick_input'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 16 })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.storeModel.storeInfo.taste, (item: string) => {
                Row() {
                  Text(item)
                    .fontSize(10)
                    .fontColor($r('sys.color.font_primary'))
                }
                .padding({
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: 8,
                })
                .margin({ right: 8, top: 8 })
                .borderRadius(16)
                .backgroundColor('#0D000000')
                .onClick(() => {
                  this.remarksTemp = `${this.remarksTemp} ${item}`
                })
              }, (item: string) => item)
            }.margin({ top: 2 })
          }
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)

        Row() {
          Text($r('app.string.confirm')).fontSize(14).fontColor(Color.White).fontWeight(FontWeight.Medium)
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .padding({ top: 6, bottom: 6 })
        .backgroundColor($r('app.color.mainColor'))
        .margin({ left: 16, right: 16 })
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .onClick(() => {
          this.remarks = this.remarksTemp
          this.remarkSheet = false
        })
      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius({ topLeft: 12, topRight: 12 })
      .margin({ top: 8 })
      .padding({
        left: 8,
        right: 8,
        top: 19,
        bottom: this.windowModel.getWindowBottomHeight(),
      })
    }
    .width(Constants.FULL_SIZE)
    .padding({
      left: Constants.BORDER_WIDTH,
      right: Constants.BORDER_WIDTH,
      top: 8,
      bottom: this.windowModel.getWindowBottomHeight(),
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  @Builder
  cutlerySheetBuilder() {
    Column() {
      SheetHeaderComp({
        title: $r('app.string.dinner_num_label'), close: () => {
          this.cutlerySheetShow = false
        },
      })

      Column() {
        Column() {
          Row() {
            Text($r('app.string.cutlery_tips')).fontSize(12).fontColor($r('sys.color.font_secondary'))
          }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center)

          TextPicker({ range: $r('app.strarray.cutlery_num'), value: $$this.cutlery })
            .width(Constants.FULL_SIZE)
            .disappearTextStyle({
              color: $r('sys.color.font_primary'),
              font: { size: 14 },
            })// 设置所有选项中除了最上、最下及选中项以外的文本颜色、字号、字体粗细。
            .textStyle({
              color: $r('sys.color.font_primary'),
              font: {
                size: 16,
              },
            })// 设置选中项的文本颜色、字号、字体粗细。
            .selectedTextStyle({
              color: $r('app.color.mainColor'),
              font: {
                size: 20,
                weight: FontWeight.Medium,
              },
            })
            .canLoop(false)
            .divider(null)
            .margin({ top: 50 })
            .onChange((value: string | string[], index: number | number[]) => {
              console.info('Picker item changed, value: ' + value + ', index: ' + index)
            })
        }.margin({ top: 24 })

        Row() {
          Text($r('app.string.confirm')).fontSize(14).fontColor(Color.White).fontWeight(FontWeight.Medium)
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .padding({ top: 6, bottom: 6 })
        .backgroundColor($r('app.color.mainColor'))
        .margin({ left: 16, right: 16 })
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .onClick(() => {
          if (!this.cutlery) {
            this.cutlery = $r('app.string.cutlery_none')
          }
          this.cutlerySheetShow = false
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius({ topLeft: 12, topRight: 12 })
      .margin({ top: 8 })
    }
    .width(Constants.FULL_SIZE)
    .padding({
      left: Constants.BORDER_WIDTH,
      right: Constants.BORDER_WIDTH,
      top: 8,
      bottom: this.windowModel.getWindowBottomHeight(),
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  @Builder
  couponSheetBuilder() {
    Column() {
      SheetHeaderComp({
        title: $r('app.string.select_coupon_title'), close: () => {
          this.couponSheetShow = false
        },
      })

      Column() {
        List({ space: 8 }) {
          ForEach(this.myCouponsUsable, (item: MyCoupon) => {
            ListItem() {
              CouponCard({
                coupon: item,
                totalMoney: this.totalMoney,
                showUseNowBtn: false,
                showUseCheck: true,
                selectCouponId: this.selectCouponIdTemp,
                changeCoupon: (item: MyCoupon, isCheck: boolean) => {
                  this.changeCoupon(item, isCheck)
                },
              })
            }
          }, (item: MyCoupon, index: number) => JSON.stringify(item))
        }.align(Alignment.Top).height(Constants.FULL_SIZE).scrollBar(BarState.Off).layoutWeight(1)

        Row() {
          Text($r('app.string.confirm')).fontSize(14).fontColor(Color.White).fontWeight(FontWeight.Medium)
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .padding({ top: 6, bottom: 6 })
        .backgroundColor($r('app.color.mainColor'))
        .margin({ left: 16, right: 16 })
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .onClick(() => {
          this.selectCouponId = this.selectCouponIdTemp
          this.selectCouponMoney = this.selectCouponMoneyTemp
          this.couponSheetShow = false
        })
      }
      .layoutWeight(1)
      .margin({ top: 8 })
    }
    .width(Constants.FULL_SIZE)
    .padding({
      left: Constants.BORDER_WIDTH,
      right: Constants.BORDER_WIDTH,
      top: 8,
      bottom: this.windowModel.getWindowBottomHeight(),
    })
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  showTimePicker() {
    TimePickerDialog.show({
      selected: this.selectTime,
      useMilitaryTime: true,
      disappearTextStyle: { color: $r('sys.color.font_primary'), font: { size: 14 } },
      textStyle: { color: $r('sys.color.font_primary'), font: { size: 16 } },
      selectedTextStyle: { color: $r('app.color.mainColor'), font: { size: 20, weight: FontWeight.Medium } },
      onAccept: (value: TimePickerResult) => {
        if (value.hour !== undefined && value.minute !== undefined) {
          let date = new Date()
          date.setHours(value.hour, value.minute)
          if (date.getTime() < new Date().getTime()) {
            promptAction.showToast({ message: $r('app.string.select_time_less') })
            return
          }
          this.selectTime.setHours(value.hour, value.minute)
          console.info('TimePickerDialog:onAccept()' + JSON.stringify(value))
        }
      },
    })
  }

  changeCoupon(coupon: MyCoupon, isCheck: boolean) {
    if (this.selectCouponIdTemp === coupon.id) {
      if (isCheck) {
        this.selectCouponIdTemp = coupon.id
        this.selectCouponMoneyTemp = coupon.reduce
      } else {
        this.selectCouponIdTemp = ''
        this.selectCouponMoneyTemp = '0'
      }
    } else {
      if (isCheck) {
        this.selectCouponIdTemp = coupon.id
        this.selectCouponMoneyTemp = coupon.reduce
      }
    }
  }

  getMyCoupon() {
    HttpRequest.getMyCoupons().then((res) => {
      res.forEach(item => {
        // 过滤可使用的优惠券 日期在有效期内 未使用的
        if (new Date(`${item.endTime} 23:59:59`).getTime() > new Date().getTime() &&
          item.state === CouponStateEnum.USABLE) {
          this.myCouponsUsable.push(item)
        }
      })
    })
  }

  closeAddressSheet(selectAddress?: AddressInfo) {
    if (selectAddress) {
      this.selectAddress.id = selectAddress.id
      this.selectAddress.addressPre = selectAddress.addressPre
      this.selectAddress.addressNum = selectAddress.addressNum
      this.selectAddress.name = selectAddress.name
      this.selectAddress.sex = selectAddress.sex
      this.selectAddress.tel = selectAddress.tel
      this.selectAddress.tag = selectAddress.tag
      this.selectAddress.latitude = selectAddress.latitude
      this.selectAddress.longitude = selectAddress.longitude
    }
    this.addressSheetShow = false
  }
}