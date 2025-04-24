import {
  AddDnOrderReq,
  addDnOrderUtil,
  Constants,
  CouponRouter,
  GetMyCarResp,
  GetTableInfoResp,
  getTableInfoUtil,
  GoodsComp,
  GoodSpecEnum,
  HttpCode,
  HttpRequestApi,
  NavHeaderBar,
  OrderDetailRouter,
  OrderTypeEnum,
  paySheetBuilder,
  purchaseUtil,
  Reduction,
  RemarksRouter,
  StoreSet,
  StoreType,
  TableTitle,
} from 'common/Index';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { MustGoodsController } from '../models/MustGoodsController';
import { common } from '@kit.AbilityKit';
import { CustomSelectSheetBuilder } from '../components/CustomSelectDialog';
import { Decimal } from '@kit.ArkTS';

@Component
export struct ConfirmOrderPage {
  @StorageProp('myCar') myCar: GetMyCarResp = new GetMyCarResp()
  @StorageLink('tableId') tableId: string = ''
  @StorageLink('dinerNum') dinerNum: ResourceStr = ''
  @StorageLink('storeType') storeType: number = 1
  @StorageProp('tableList') tableList: Array<TableTitle> = []
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('tableInfo') tableInfo: GetTableInfoResp
  @Consume('reductionList') reductionList: Array<Reduction>
  @Consume('storeSet') storeSet: StoreSet
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  @State orderType: number = 0
  @State remarks: string = ''
  // 订单总金额
  @State totalMoney: number = 0
  @State pkgDiscountMoney: number = 0
  @State selectArray: Array<string> = []
  @State isNew: boolean = false
  // 店铺优惠金额
  @State reduction: number = 0
  // 已选优惠券Id
  @State selectCouponId: string = ''
  // 已选优惠券金额
  @State selectCouponMoney: string = '0'
  // 下单id
  @State orderId: string = ''
  @State paySheetFlag: boolean = false
  @State tableSheetShow: boolean = false;
  @State dinerSheetShow: boolean = false;
  private scroller: Scroller = new Scroller()
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    this.getIsNew()
    if (this.storeType === StoreType.SCAN_TYPE) {
      this.initTableInfo()
    }
    this.initPkgDiscountMoney()
  }

  initPkgDiscountMoney() {
    this.myCar.res?.forEach(item => {
      if (item.specType === GoodSpecEnum.PACKAGE_TYPE) {
        let discount = new Decimal(item.money2 || 0).sub(item.money || 0).mul(item.num!)
        this.pkgDiscountMoney = new Decimal(this.pkgDiscountMoney).add(discount).toNumber()
      }
    })
  }

  getIsNew() {
    HttpRequestApi.getIsNew().then((resp: number) => {
      if (resp === HttpCode.SUCCESS) {
        console.info(`getIsNew resp:${JSON.stringify(resp)}.`);
        this.isNew = true
      }
    })
      .catch((e: BusinessError) => {
        console.error(`clearCarUtil error: ${JSON.stringify(e)}.`);
      }).finally(() => {
      this.getReduction()
    })
  }

  initTableInfo() {
    this.selectArray = this.tableList.map((item) => {
      return item.name ?? ''
    })
    // 校验餐桌和用餐人数选择
    if (!this.tableId) {
      this.tableSheetShow = true
    }
  }

  getReduction() {
    let maxFullIndex = -1
    let maxFull = 0
    this.reductionList.forEach((item, index) => {
      let full = Number(item.full)
      if ((this.myCar.money ?? 0) > full && full > maxFull) {
        maxFull = full
        maxFullIndex = index
      }
    })
    let reduction = 0
    if (maxFullIndex >= 0) {
      reduction = Number(this.reductionList[maxFullIndex]?.reduction ?? 0)
    }
    if (this.isNew) {
      this.reduction = Number(this.storeSet.xyhMoney) ?? 0
    } else {
      this.reduction = reduction
    }
    this.totalMoney = new Decimal(this.myCar.money ?? 0).sub(this.reduction).toNumber()
  }

  confirmTable(select: ResourceStr) {
    if (select) {
      let table = this.tableList.find(item => item.name === select)
      this.tableId = table?.id ?? '';
      getTableInfoUtil(this.tableId).then((res) => {
        this.tableInfo = res;
      });
    }
    this.tableSheetShow = false
  }

  confirmDiner(select: ResourceStr) {
    if (select) {
      this.dinerNum = select;
    } else {
      this.dinerNum = this.dinerNum || $r('app.string.diner_num_default');
    }
    this.dinerSheetShow = false
  }

  updateOrder() {
    HttpRequestApi.getHuaweiPayInfo(this.orderId).then((resp: number) => {
      if (resp) {
        this.pageStack.replacePath({
          name: 'OrderDetailPage',
          param: { orderId: `${this.orderId}`, isOrderJump: true } as OrderDetailRouter,
        })
      } else {
        promptAction.showToast({ message: $r('app.string.update_order_failed') })
      }
    }).catch((e: BusinessError) => {
      console.error(`getHuaweiPayInfo error: ${JSON.stringify(e)}.`);
      promptAction.showToast({ message: $r('app.string.update_order_failed') })
    })
  }

  confirmOrder() {
    if (!this.myCar.res?.length) {
      promptAction.showToast({ message: $r('app.string.car_empty_toast') })
      return
    }

    let req = {
      money: this.totalMoney,
      reductionMoney: new Decimal(this.reduction).add(this.selectCouponMoney).add(this.pkgDiscountMoney).toNumber(),
      yhqMoney: this.selectCouponMoney,
      couponId: this.selectCouponId,
      orderType: this.orderType,
      mjMoney: this.isNew ? '0' : `${this.reduction}`,
      xyhMoney: this.isNew ? `${this.reduction}` : '0',
      note: this.remarks ? this.remarks : '', // 清除默认备注
      boxMoney: this.orderType === OrderTypeEnum.PICKING ? this.myCar.boxMoney : 0, // 清除默认备注
    } as AddDnOrderReq
    addDnOrderUtil(this.myCar.res, req).then((resp: number) => {
      this.orderId = `${resp}`
      this.mustGoodsCtrl.cleanCar()
      purchaseUtil(this.context).then(() => {
        // 支付成功更新订单信息
        this.updateOrder()
      }).catch(() => {
        this.pageStack.replacePath({
          name: 'OrderDetailPage',
          param: { orderId: `${resp}`, isOrderJump: true } as OrderDetailRouter,
        })
      })
    }).catch((e: BusinessError) => {
      console.error(`confirmOrder error: ${JSON.stringify(e)}.`);
      promptAction.showToast({ message: $r('app.string.place_order_failed_msg', JSON.stringify(e)) })
    })
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
    .margin({
      left: 12,
      right: 12,
    })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: $r('app.string.confirm_order') })
        Scroll(this.scroller) {
          Column({ space: 12 }) {
            Column() {
              if (this.storeType === StoreType.SCAN_TYPE) {
                Row() {
                  Text($r('app.string.my_location'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                  Row() {
                    Image($r('app.media.order_list')).width(14).fillColor($r('app.color.mainColor'))
                    Text(this.tableInfo?.typeName)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ left: 8 })
                    Divider()
                      .vertical(true)
                      .margin({ left: 8, right: 8 })
                      .height(16)
                    Text(this.tableInfo?.tableName)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(20)
                  }
                }
                .width(Constants.FULL_SIZE)
                .margin({
                  left: 12,
                  right: 12,
                  top: 4,
                })
                .constraintSize({ maxWidth: Constants.FULL_SIZE })
                .justifyContent(FlexAlign.SpaceBetween)
                .bindSheet($$this.tableSheetShow,
                  CustomSelectSheetBuilder($r('app.string.pick_table'), this.tableList.map((item) => {
                    return item.name ?? '';
                  }), (select: ResourceStr) => {
                    this.confirmTable(select);
                  }), {
                    height: 408,
                    blurStyle: BlurStyle.Thick,
                    showClose: false,
                  });

                Divider().margin({ top: 16, bottom: 12 })
              }
              Row() {
                Row() {
                  Image($r('app.media.store_dining')).width(40)
                  Column() {
                    Text($r('app.string.store_dining'))
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(16)
                    Text($r('app.string.store_dining_desc'))
                      .fontSize($r('sys.float.Caption_M'))
                      .fontColor($r('sys.color.font_secondary'))
                      .lineHeight(12)
                      .margin({ top: 4 })
                  }.margin({ left: 8 }).alignItems(HorizontalAlign.Start)
                }
                .width(150)
                .height(64)
                .padding(12)
                .borderWidth(1)
                .borderRadius(12)
                .borderColor(this.orderType === OrderTypeEnum.STORE_DINING ? $r('app.color.mainColor') : '#CCCCCC')
                .backgroundColor(this.orderType === OrderTypeEnum.STORE_DINING ? '#0DED6F21' : '#ffffff')
                .onClick(() => {
                  if (this.orderType !== OrderTypeEnum.STORE_DINING) {
                    this.orderType = OrderTypeEnum.STORE_DINING
                    let boxMoney = this.myCar?.boxMoney ?? 0
                    this.totalMoney = new Decimal(this.totalMoney).sub(boxMoney).toNumber()
                  }
                })

                Row() {
                  Image($r('app.media.packing')).width(40)
                  Column() {
                    Text($r('app.string.picking'))
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(16)
                    Text($r('app.string.picking_desc'))
                      .fontSize($r('sys.float.Caption_M'))
                      .fontColor($r('sys.color.font_secondary'))
                      .lineHeight(12)
                      .margin({ top: 4 })
                  }.margin({ left: 8 }).alignItems(HorizontalAlign.Start)
                }
                .width(150)
                .height(64)
                .padding(12)
                .borderWidth(1)
                .borderRadius(12)
                .borderColor(this.orderType === OrderTypeEnum.PICKING ? $r('app.color.mainColor') : '#CCCCCC')
                .backgroundColor(this.orderType === OrderTypeEnum.PICKING ? '#0DED6F21' : '#ffffff')
                .onClick(() => {
                  if (this.orderType !== OrderTypeEnum.PICKING) {
                    this.orderType = OrderTypeEnum.PICKING
                    let boxMoney = this.myCar?.boxMoney ?? 0
                    this.totalMoney = new Decimal(this.totalMoney).add(boxMoney).toNumber()
                  }
                })
              }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 4 })
            }.cardStyle()

            GoodsComp({ goodList: this.myCar.res }).margin({
              left: 12,
              right: 12,
            })
            Column() {
              // 优惠
              Column() {
                Row() {
                  Row() {
                    Image($r('app.media.full_reduction')).width(16)
                    Text(this.isNew ? $r('app.string.new_user_discount_label') : $r('app.string.store_discount_label'))
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(20)
                      .margin({ left: 8 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.layoutWeight(1)

                  Text() {
                    Span($r('app.string.currency_symbol_pre_params', '-'))
                      .fontSize(8)
                      .fontWeight(FontWeight.Medium)
                      .lineHeight(14)
                    Span(`${Number(this.reduction)}`)
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Medium)
                      .lineHeight(20)
                  }.fontColor('#E84026')
                }
                .width(Constants.FULL_SIZE)
                .height(40)
                .padding({ top: 10, bottom: 10 })
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  Row() {
                    Image($r('app.media.vouchers')).width(16)
                    Text($r('app.string.coupon_label'))
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(20)
                      .margin({ left: 8 })
                  }

                  Row() {
                    if (!this.selectCouponMoney || this.selectCouponMoney === '0') {
                      Text($r('app.string.select_coupon'))
                        .fontSize($r('sys.float.Body_S'))
                        .fontColor($r('sys.color.font_secondary'))
                    } else {
                      Text() {
                        Span($r('app.string.currency_symbol_pre_params', '-'))
                          .fontSize(8)
                          .fontWeight(FontWeight.Medium)
                          .lineHeight(14)
                        Span(`${Number(this.selectCouponMoney)}`)
                          .fontSize($r('sys.float.Body_M'))
                          .fontWeight(FontWeight.Medium)
                          .lineHeight(20)
                      }.fontColor('#E84026')
                    }
                    Image($r('app.media.right')).width(16)
                  }.onClick(() => {
                    this.pageStack.pushPath({
                      name: 'SelectCouponPage',
                      param: { totalMoney: (this.myCar.money ?? 0), selectId: this.selectCouponId } as CouponRouter,
                      onPop: (popInfo: PopInfo) => {
                        // 先还原总价格后再减去优惠券金额
                        this.totalMoney = new Decimal(this.totalMoney).add(this.selectCouponMoney).toNumber()
                        let result = popInfo.result as CouponRouter
                        this.selectCouponId = result.selectId
                        this.selectCouponMoney = result.reduce
                        this.totalMoney = new Decimal(this.totalMoney).sub(this.selectCouponMoney).toNumber()
                      },
                    })
                  })
                }
                .width(Constants.FULL_SIZE)
                .height(40)
                .padding({ top: 10, bottom: 10 })
                .justifyContent(FlexAlign.SpaceBetween)

                if (this.orderType === OrderTypeEnum.PICKING) {
                  Row() {
                    Row() {
                      Image($r('app.media.ic_packet')).width(16)
                      Text($r('app.string.packing_box'))
                        .fontSize($r('sys.float.Body_M'))
                        .fontColor($r('sys.color.font_primary'))
                        .lineHeight(20)
                        .margin({ left: 8 })
                    }

                    Row() {
                      Text() {
                        Span($r('app.string.currency_symbol_pre_params', '+'))
                          .fontSize(8)
                          .fontWeight(FontWeight.Medium)
                          .lineHeight(14)
                        Span(`${this.myCar.boxMoney}`)
                          .fontSize($r('sys.float.Body_S'))
                          .lineHeight(20)
                          .fontColor('#E84026')
                      }.fontColor('#E84026')
                    }
                  }
                  .width(Constants.FULL_SIZE)
                  .height(40)
                  .padding({ top: 10, bottom: 10 })
                  .justifyContent(FlexAlign.SpaceBetween)
                }

              }

              Divider().margin({ top: 8 })
              // 实付金额
              Row() {
                Text() {
                  Span($r('app.string.discount_money')).fontSize($r('sys.float.Body_M')).lineHeight(20)
                  Span($r('app.string.currency_symbol'))
                    .fontSize(8)
                    .fontWeight(FontWeight.Medium)
                    .lineHeight(14)
                    .margin({ left: 4 })
                  Span(new Decimal(this.reduction).add(this.selectCouponMoney).add(this.pkgDiscountMoney).toString())
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .lineHeight(20)
                }.fontColor('#E84026')

                Text() {
                  Span($r('app.string.should_pay')).fontSize($r('sys.float.Body_M')).lineHeight(20)
                  Span($r('app.string.currency_symbol'))
                    .fontSize(8)
                    .fontWeight(FontWeight.Medium)
                    .lineHeight(14)
                    .margin({ left: 4 })
                  Span(`${this.totalMoney}`)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .lineHeight(20)
                }.fontColor($r('sys.color.font_primary')).margin({ left: 20 })
              }
              .width(Constants.FULL_SIZE)
              .padding({ top: 16 })
              .justifyContent(FlexAlign.End)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })

            }.cardStyle().alignItems(HorizontalAlign.Start)

            Column() {
              Row() {
                Text($r('app.string.dinner_num_label'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .lineHeight(20)
                Row() {
                  Text(this.dinerNum)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .textAlign(TextAlign.End)
                    .width(100)
                    .textAlign(TextAlign.End)
                  Image($r('app.media.right')).width(16)
                }.justifyContent(FlexAlign.End).layoutWeight(1)
              }
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                this.dinerSheetShow = true
              })
              .bindSheet($$this.dinerSheetShow,
                CustomSelectSheetBuilder($r('app.string.pick_dinner_num'), $r('app.strarray.diner_num'),
                  (select: ResourceStr) => {
                    this.confirmDiner(select);
                  }, this.dinerNum), {
                  height: 408,
                  blurStyle: BlurStyle.Thick,
                  showClose: false,
                });
            }.cardStyle()

            Column() {
              Row() {
                Text($r('app.string.remark'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .lineHeight(20)
                Row() {
                  Text(this.remarks || $r('app.string.fill_remarks'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .textAlign(TextAlign.End)
                    .width(200)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Image($r('app.media.right')).width(16)
                }.justifyContent(FlexAlign.End).layoutWeight(1)
              }
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                this.pageStack.pushPath({
                  name: 'RemarksPage',
                  param: {
                    remarks: this.remarks ? this.remarks : '',
                  } as RemarksRouter, // 清除默认备注
                  onPop: (popInfo: PopInfo) => {
                    // 先还原总价格后再减去优惠券金额
                    let result = popInfo.result as RemarksRouter
                    this.remarks = result.remarks
                  },
                })
              })
            }.cardStyle()
          }.margin({ top: 12, bottom: 12 })
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)

        Row() {
          Column() {
            Text() {
              Span($r('app.string.total_pay'))
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_secondary'))
                .lineHeight(14)
              Span($r('app.string.currency_symbol'))
                .fontSize(8)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(12)
                .margin({ left: 1 })
              Span(`${this.totalMoney}`)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(18)
            }

            Text(``) {
              Span($r('app.string.discount_money')).fontSize(8).lineHeight(12)
              Span($r('app.string.currency_symbol')).fontSize(8).fontWeight(FontWeight.Medium).lineHeight(12)
              Span(new Decimal(this.reduction).add(this.selectCouponMoney).add(this.pkgDiscountMoney).toString())
                .fontSize($r('sys.float.Caption_M'))
                .lineHeight(14)
            }.fontColor('#E84026').margin({ top: 3 })
          }.alignItems(HorizontalAlign.End)

          Button($r('app.string.commit_order'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(700)
            .fontColor($r('sys.color.comp_background_list_card'))
            .padding({
              left: 21,
              right: 21,
              top: 8,
              bottom: 8,
            })
            .margin({ left: 16 })
            .backgroundColor($r('sys.color.multi_color_09'))
            .onClick(() => {
              if (this.storeType === StoreType.SCAN_TYPE) {
                if (!this.tableId) {
                  this.tableSheetShow = true
                  return
                }
              }
              if (!this.dinerNum) {
                this.dinerSheetShow = true
                return
              }
              this.paySheetFlag = true
            })
            .bindSheet($$this.paySheetFlag, paySheetBuilder(this.totalMoney, (flag: boolean) => {
              if (flag) {
                this.confirmOrder()
              }
              this.paySheetFlag = false
            }), {
              height: 397,
              blurStyle: BlurStyle.Thick,
              showClose: false,
            })
        }.width(Constants.FULL_SIZE).height(56).padding(12).justifyContent(FlexAlign.End)
      }.height(Constants.FULL_SIZE)
    }.hideTitleBar(true).padding({ bottom: this.windowBottomHeight })
  }
}