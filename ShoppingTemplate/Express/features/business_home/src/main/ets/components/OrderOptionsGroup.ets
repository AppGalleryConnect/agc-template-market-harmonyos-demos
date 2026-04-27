import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  RouterModule,
  IBuilderType,
  ISetting,
  PAY_METHOD_LIST,
  RouterMap,
  PopViewUtils,
  IGoods,
  IServicePoint,
  PreferPickupTimeParam,
  preferPickupTimeSheetBuilder,
  GridPickerParam,
  gridPickerSheetBuilder,
  HttpApi,
  CommonUtil,
} from 'lib_foundation'
import { CouponsController, CouponItem, ReductionTypes, CouponStatus } from 'coupons';
import { ExpressPageVM } from '../viewModels/ExpressPageVM'
import { ExpressPickerParam, expressPickerSheetBuilder } from './ExpressPickerSheet';
import { StoreCard } from './StoreCard';

@ComponentV2
export struct OrderOptionsGroup {
  vm: ExpressPageVM = ExpressPageVM.instance;
  @Local showPaymentMethodPop: boolean = false;

  // 选择物品
  selectGoods() {
    if (!this.vm.checkAddress()) {
      return
    }
    RouterModule.push({ url: RouterMap.GOODS_PAGE, param: this.vm.selectedGoods }, (popInfo: PopInfo) => {
      if (popInfo.result) {
        const data = popInfo.result as IGoods;
        this.vm.selectedGoods = {
          id: data.id,
          name: data.name,
          weight: data.weight,
          volume: data.volume,
          count: data.count ?? 1,
        }
        this.vm.goodsName = `${this.vm.selectedGoods.name} ${this.vm.selectedGoods.weight}kg`;
        this.vm.getEstimatedPrice()
      }
    })
  }

  // 选择快递
  selectExpress() {
    if (!this.vm.checkAddress()) {
      return
    }
    let builderParams: ExpressPickerParam = {
      companyList: this.vm.companyPickerList,
      currentCompany: this.vm.selectedCompany,
      confirm: (value) => {
        if (value) {
          this.vm.selectedCompany = value;
          this.vm.getEstimatedPrice();
        }
        PopViewUtils.closeSheet();
      },
      cancel: () => {
        PopViewUtils.closeSheet();
      },
    }
    PopViewUtils.showSheet(wrapBuilder(expressPickerSheetBuilder), {
      height: 380,
      preferType: SheetType.CENTER,
      showClose: true,
      title: { title: '选择快递' },
    }, builderParams);
  }

  // 选择期望上门时间
  selectPreferPickupTime() {
    if (!this.vm.checkAddress()) {
      return
    }
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
    if (!this.vm.checkAddress()) {
      return
    }
    let builderParams: GridPickerParam = {
      currentGrid: this.vm.selectedGrid,
      confirm: (grid: string) => {
        this.vm.selectedGrid = grid;
        this.vm.getEstimatedPrice();
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
    if (!this.vm.checkAddress()) {
      return
    }
    if (this.vm.price === '--') {
      ToastDialog.showToast({ message: '请先填写基础信息' })
      return
    }
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
          return data
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
      this.vm.price = resPrice.toFixed(2);
    }
    this.vm.controller = controller;

    controller.select(this.getUIContext());
  }

  build() {
    Column({ space: 12 }) {
      // 选择快递柜
      if (this.vm.selectedShippingMethod === 2) {
        this.shippingCard()
      }
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
          // 快递
          this.contentBuilder({
            label: '选择快递',
            placeholder: '请选择快递公司',
            placeholderColor: $r('sys.color.font_primary'),
            text: this.vm.selectedCompany,
            textColor: $r('sys.color.font_tertiary'),
            isDivider: true,
            isTime: false,
            isIcon: true,
            func: () => {
              this.selectExpress()
            },
          })
          // 上门时间
          this.contentBuilder({
            label: '期望上门时间',
            placeholder: '请选择时间',
            placeholderColor: $r('sys.color.font_primary'),
            text: this.vm.selectedDayText + this.vm.selectedTime,
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
              if (!this.vm.checkAddress()) {
                return
              }
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
      .padding({ top: 12, left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
    .width('100%')
  }

  @Builder
  shippingCard() {
    if (this.vm.senderInfo.addressId) {
      Column() {
        StoreCard({ servicePoint: this.vm.selectedServicePoint })
        Row() {
          Text('查看全部')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
            .lineHeight(19)
            .margin({ right: 4 })
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_secondary')])
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          RouterModule.push({
            url: RouterMap.SERVICE_POINT_PAGE,
            param: this.vm.selectedServicePoint?.id,
          }, (popInfo: PopInfo) => {
            this.vm.selectedServicePoint = popInfo.result as IServicePoint;
          })
        })
      }
      .padding({ bottom: 12 })
      .borderRadius(16)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
    } else {
      Column() {
        Text('请填写寄件地址获取附近服务点')
          .fontSize(14)
          .fontWeight(700)
          .lineHeight(19)
          .fontColor($r('sys.color.font_primary'))
      }
      .padding(12)
      .width('100%')
      .borderRadius(16)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
    }
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
        ForEach(PAY_METHOD_LIST, (option: ISetting, index: number) => {
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
}