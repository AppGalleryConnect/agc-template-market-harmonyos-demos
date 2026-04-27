import {
  CommonLoading,
  CommonNoticeBar,
  CommonTitle,
  CommonUtil,
  GridPickerParam,
  gridPickerSheetBuilder,
  HttpApi,
  IBuilderType,
  IGoods,
  ISetting,
  PAY_METHOD_LIST,
  PopViewUtils,
  PreferPickupTimeParam,
  preferPickupTimeSheetBuilder,
  RouterMap,
  RouterModule,
} from 'lib_foundation';
import { CouponsController, CouponItem, ReductionTypes, CouponStatus } from 'coupons';
import { AddressSelectCard } from 'module_template';
import { EditOrderPageVM } from '../viewModels/EditOrderPageVM';

@Builder
export function editOrderPageBuilder() {
  EditOrderPage()
}

@ComponentV2
struct EditOrderPage {
  vm: EditOrderPageVM = new EditOrderPageVM();
  @Local showPaymentMethodPop: boolean = false;

  aboutToAppear(): void {
    this.vm.initData();
  }

  // 选择物品
  selectGoods() {
    RouterModule.push({ url: RouterMap.GOODS_PAGE, param: this.vm.selectedGoods }, (popInfo: PopInfo) => {
      if (popInfo.result) {
        const data = popInfo.result as IGoods;
        this.vm.selectedGoods = {
          id: data.id,
          name: data.name,
          weight: data.weight,
          volume: data.volume,
        }
        this.vm.goodsName = `${this.vm.selectedGoods.name} ${this.vm.selectedGoods.weight}kg`;
        this.vm.calcEstimatedPrice()
      }
    })
  }

  // 选择期望上门时间
  selectPreferPickupTime() {
    let builderParams: PreferPickupTimeParam = {
      currentDay: this.vm.selectedDayText,
      currentTime: this.vm.selectedTime,
      dayList: this.vm.dayList,
      confirm: (dayIndex: number, time: string) => {
        this.vm.selectedDayIndex = dayIndex;
        this.vm.selectedDayText = this.vm.dayList[dayIndex].text;
        this.vm.selectedTime = time;
        PopViewUtils.closeSheet();
      },
      cancel: () => {
        PopViewUtils.closeSheet();
      },
    }
    PopViewUtils.showSheet(wrapBuilder(preferPickupTimeSheetBuilder), {
      height: 380,
      preferType: SheetType.CENTER,
      showClose: true,
      title: { title: '时间选择' },
    }, builderParams);
  }

  // 选择格口
  selectGrid() {
    let builderParams: GridPickerParam = {
      currentGrid: this.vm.selectedGrid,
      confirm: (grid: string) => {
        this.vm.selectedGrid = grid;
        this.vm.calcEstimatedPrice();
        PopViewUtils.closeSheet();
      },
      cancel: () => {
        PopViewUtils.closeSheet();
      },
    }
    PopViewUtils.showSheet(wrapBuilder(gridPickerSheetBuilder), {
      height: 360,
      preferType: SheetType.CENTER,
      showClose: true,
      title: { title: '格口选择' },
    }, builderParams);
  }

  // 选择优惠券
  selectedCoupon() {
    const controller = new CouponsController();
    controller.themeColor = $r('sys.color.font_emphasize');
    controller.totalMoney = this.vm.originPrice;
    controller.selectedId = this.vm.selectCouponId;
    controller.reduce = this.vm.couponDiscount;
    controller.onLoadCoupons = async () => {
      const resp = await HttpApi.queryUserCouponList(this.vm.userInfoModel.id);
      let couponsList: CouponItem[] = [];

      if (resp.length > 0) {
        couponsList = resp.map((item) => {
          const data = {
            couponID: item.id.toString(),
            couponName: item.name,
            usageRestriction: item.usageRestriction,
            startTime: CommonUtil.formatDate(item.startTime, 'YYYY-MM-DD'),
            endTime: CommonUtil.formatDate(item.endTime, 'YYYY-MM-DD'),
            createdTime: CommonUtil.formatDate(item.createdTime, 'YYYY-MM-DD'),
            amountRule: {
              discountType: item.discountType as ReductionTypes,
              fullAmount: item.fullAmount.toString(),
              discountAmount: item.discountAmount.toString(),
              discountCoefficient: item.discountCoefficient.toString(),
            }
          } as CouponItem;
          if (item.couponStatus !== undefined) {
            data.couponStatus = item.couponStatus as CouponStatus
          }
          if (data.couponID === this.vm.selectCouponId ||
            data.couponID === String(this.vm.orderDetail.couponId)
          ) {
            data.couponStatus = 0;
          }
          return data;
        })
      }
      return couponsList;
    }

    controller.onConfirm = (data) => {
      this.vm.selectCouponId = data.selectId;
      const reduce = data.reduce.toFixed(2);
      this.vm.couponDiscount = Number(reduce);
      let resPrice = this.vm.originPrice - Number(reduce);
      if (resPrice < 0) {
        resPrice = 0;
      }
      this.vm.price = Number(resPrice.toFixed(2));
    }

    controller.select(this.getUIContext());
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '修改信息'
      })
      Stack() {
        Column() {
          Scroll() {
            Column() {
              // 实名认证提示
              if (!this.vm.userInfoModel.isRealName) {
                CommonNoticeBar({
                  text: '根据相关法律法规，寄件须实名认证。',
                  showIcon: true,
                  clickAction: () => {
                    this.vm.jumpToAuthPage();
                  },
                }).margin({ bottom: 8 })
              }

              // 寄/收件人信息
              AddressSelectCard({
                stack: RouterModule.stack,
                userId: this.vm.userInfoModel.id,
                senderInfo: this.vm.senderInfo,
                receiverInfo: this.vm.receiverInfo,
                onChangeSender: () => {
                  this.vm.onChangeSenderAddress();
                },
                onChangeReceiver: () => {
                  this.vm.onChangeReceiverAddress();
                },
                onExchangeAddress: () => {
                  this.vm.onExchangeAddress();
                }
              })

              // 订单配置项
              Column() {
                // 物品
                this.contentBuilder({
                  label: '物品信息',
                  placeholder: '请选择物品信息',
                  placeholderColor: $r('sys.color.font_primary'),
                  text: this.vm.goodsName,
                  textColor: $r('sys.color.font_tertiary'),
                  isDivider: true,
                  isTime: false,
                  isIcon: true,
                  func: () => {
                    this.selectGoods();
                  },
                })

                if (this.vm.selectedShippingMethod === 1) {
                  // 上门时间
                  this.contentBuilder({
                    label: '期望上门时间',
                    placeholder: '请选择时间',
                    placeholderColor: $r('sys.color.font_primary'),
                    text: `${this.vm.selectedDayText} ${this.vm.selectedTime}`,
                    textColor: $r('sys.color.font_tertiary'),
                    isDivider: true,
                    isTime: true,
                    isIcon: true,
                    func: () => {
                      this.selectPreferPickupTime();
                    },
                  })
                }

                // 付款方式
                Row() {
                  this.contentBuilder({
                    label: '付款方式',
                    placeholder: '请选择付款方式',
                    placeholderColor: $r('sys.color.font_primary'),
                    text: this.vm.selectedPayMethod.text,
                    textColor: $r('sys.color.font_tertiary'),
                    isDivider: true,
                    isTime: false,
                    isIcon: true,
                    func: () => {
                      this.showPaymentMethodPop = true;
                    },
                  })
                }
                .bindPopup(this.showPaymentMethodPop, {
                  builder: () => {
                    this.paymentMethodPopBuilder()
                  },
                  enableArrow: false,
                  autoCancel: true,
                  placement: Placement.BottomRight,
                  width: 200,
                  offset: { x: 4, y: -20 },
                  onWillDismiss: () => {
                    this.showPaymentMethodPop = false;
                  },
                })

                // 格口类型
                if (this.vm.selectedShippingMethod === 2) {
                  this.contentBuilder({
                    label: '格口类型',
                    placeholder: '请选择格口',
                    placeholderColor: $r('sys.color.font_primary'),
                    text: this.vm.selectedGrid,
                    textColor: $r('sys.color.font_tertiary'),
                    isDivider: true,
                    isTime: false,
                    isIcon: true,
                    func: () => {
                      this.selectGrid();
                    },
                  })
                }
                // 优惠券
                this.contentBuilder({
                  label: '优惠券',
                  placeholder: '请选择优惠券',
                  placeholderColor: $r('sys.color.font_emphasize'),
                  text: this.vm.couponDiscount > 0 ? '-¥' + this.vm.couponDiscount : '',
                  textColor: $r('sys.color.font_emphasize'),
                  isDivider: this.vm.userInfoModel.isVip ? true : false,
                  isTime: false,
                  isIcon: true,
                  func: () => {
                    this.selectedCoupon();
                  },
                })

                if (this.vm.userInfoModel.isVip) {
                  this.contentBuilder({
                    label: '会员折扣',
                    placeholder: '会员折扣',
                    placeholderColor: $r('sys.color.font_emphasize'),
                    text: '9折',
                    textColor: $r('sys.color.font_emphasize'),
                    isDivider: false,
                    isTime: false,
                    isIcon: false,
                    func: () => {
                    },
                  })
                }
              }
              .width('100%')
              .padding({ top: 12, left: 12, right: 12 })
              .margin({ top: 12 })
              .backgroundColor(Color.White)
              .borderRadius(16)
            }
            .width('100%')
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding,
              top: 8,
              bottom: 16,
            })
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .layoutWeight(1)
          .align(Alignment.Top)

          // 底部价格栏
          this.orderBottomBar()
        }
        .width('100%')
        .layoutWeight(1)

        // 页面loading
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
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  contentBuilder($$: IBuilderType) {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column({ space: 4 }) {
          Text($$.label)
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(21)
          if ($$.isTime) {
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.info_circle'))
                .fontSize(12).fontColor([$r('sys.color.icon_primary')])
              Text('08:00至20:00')
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
            }
          }
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text($$.text ? $$.text : $$.placeholder)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($$.text ? $$.placeholderColor : $$.textColor)
            .margin({ right: 4 })
          if ($$.isIcon) {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(16)
              .fontColor([$r('sys.color.icon_primary')])
          }
        }
      }
      .margin({ bottom: 12 })

      if ($$.isDivider) {
        Divider().color($r('sys.color.comp_divider'))
          .margin({ bottom: 12 })
      }
    }
    .onClick(() => {
      $$.func()
    })
  }

  @Builder
  paymentMethodPopBuilder() {
    Column() {
      List() {
        ForEach(PAY_METHOD_LIST, (option: ISetting) => {
          ListItem() {
            Row() {
              Text(option.text)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize(24)
                .fontColor([$r('sys.color.font_emphasize')])
                .margin({ left: 4 })
                .visibility(this.vm.selectedPayMethod.value === option.value ? Visibility.Visible : Visibility.Hidden)
            }
            .width('100%')
            .borderRadius($r('sys.float.corner_radius_level4'))
            .padding(12)
            .stateStyles({
              normal: {
                .backgroundColor($r('sys.color.comp_background_primary'))
              },
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              },
            })
            .onClick(() => {
              this.vm.selectedPayMethod = option;
              this.showPaymentMethodPop = false;
            })
          }
        }, (option: ISetting) => JSON.stringify(option))
      }
      .width('100%')
      .padding(6)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.comp_divider'),
        startMargin: 8,
        endMargin: 8,
      })
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level4'))
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Builder
  orderBottomBar() {
    Row() {
      Row() {
        Text('预估总价')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(`￥${this.vm.price}`)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_emphasize'))
      }

      Button('保存')
        .width('30%')
        .constraintSize({ maxWidth: 142 })
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .onClick(() => {
          this.vm.save();
        })
    }
    .width('100%')
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
      top: 16,
      bottom: this.vm.windowModel.windowBottomPadding
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}