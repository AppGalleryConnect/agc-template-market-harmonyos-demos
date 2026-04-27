import { PersistenceV2 } from '@kit.ArkUI';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  CommonUtil,
  STATUS_MAP,
  ParcelStatus,
  PayMethod,
  HttpApi,
  Parcel,
  EmitterUtils,
  CommonDialogUtil,
  ToastLoading,
  PayStatus,
  RouterModule,
  RouterMap,
  Logistics,
  STATUS_DESCRIPTION_MAP,
  STATUS_OPERATOR_MAP,
  ControllerModule,
  UserInfoModel,
  OrderUtil,
  OrderActionReq,
} from 'lib_foundation'
import { CityAndName, IActionInfo, OrderInfo } from '../models/Model';
import { MOCK_RECEIVER_PHONE } from '../constants';


@ComponentV2
export struct OrderItemCard {
  @Param @Require orderInfo: OrderInfo;
  @Local remarkText: string = '';
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  @Computed
  get orderNumberText() {
    return `${this.orderInfo.expressCompany || '订单号'}: ${this.orderInfo.parcelNumber}`
  }

  @Computed
  get symbolValue() {
    return this.orderInfo.status === ParcelStatus.DELIVERED ?
      $r('sys.symbol.checkmark') : $r('sys.symbol.arrow_right');
  }

  @Computed
  get pickupTime() {
    if (this.orderInfo.pickupTime) {
      const today = new Date();
      const base = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
      const target = new Date(this.orderInfo.pickupTime);
      const date = new Date(target.getFullYear(), target.getMonth(), target.getDate()).getTime();
      const diff = Math.floor((date - base) / 86400000);
      const tempY = CommonUtil.formatDate(this.orderInfo.pickupTime, 'YYYY-MM-DD');
      const tempH = CommonUtil.formatDate(this.orderInfo.pickupTime, 'HH');
      const preH = Number(tempH) - 1;
      const timePeriod = `${String(preH).padStart(2, '0')}:00 - ${tempH}:00`
      const dayTexts = ['今天', '明天', '后天'];
      if (dayTexts[diff]) {
        return `${dayTexts[diff]} ${timePeriod}`
      }
      return `${tempY} ${timePeriod}`;
    }
    return ''
  }

  @Computed
  get cancelTime() {
    if (this.orderInfo.cancelTime) {
      return CommonUtil.formatDate(this.orderInfo.cancelTime, 'YYYY-MM-DD HH:mm');
    }
    return ''
  }

  @Computed
  get arrivalTime() {
    if (this.orderInfo.estimatedArrivalTime) {
      return CommonUtil.formatDate(this.orderInfo.estimatedArrivalTime, 'YYYY-MM-DD HH:mm');
    }
    return ''
  }

  @Computed
  get showCancelBtn() {
    // 取消按钮的展示条件
    const status = [
      ParcelStatus.AWAITING_PICKUP, ParcelStatus.PENDING_LOCKER, ParcelStatus.COLLECTED,
      ParcelStatus.IN_TRANSIT, ParcelStatus.DELIVERY,
    ];
    // 这里需要将mock的收件订单排除
    return status.includes(this.orderInfo.status) && this.orderInfo.receiverPhone !== MOCK_RECEIVER_PHONE;
  }

  @Computed
  get showAddRemarkBtn() {
    // 添加备注按钮的展示条件
    const status = [ParcelStatus.AWAITING_PICKUP, ParcelStatus.PENDING_LOCKER];
    return status.includes(this.orderInfo.status);
  }

  @Computed
  get showDeleteBtn() {
    // 删除按钮的展示条件
    const status = [ParcelStatus.DELIVERED, ParcelStatus.CANCELED];
    return status.includes(this.orderInfo.status);
  }

  @Computed
  get showDeliveryBtn() {
    // 确认签收按钮的展示条件
    const status = this.orderInfo.status === ParcelStatus.OUT_FOR_DELIVERY;
    const payStatus = this.orderInfo.paymentStatus === PayStatus.PAID;
    return status && payStatus;
  }

  @Computed
  get showPayNowBtn() {
    // 立即支付按钮的展示条件
    const item = this.orderInfo;
    // 判断是否为收货人
    const isReceiver = item.receiverPhone === MOCK_RECEIVER_PHONE ||
      item.receiverPhone === this.userInfoModel.phone;
    // 收货人条件：货到付款且待支付
    const receiverCondition = isReceiver &&
      item.payMethod === PayMethod.CASH_DELIVERY &&
      item.paymentStatus === PayStatus.PENDING;
    // 寄件人条件：预付款且待支付
    const senderCondition = !isReceiver &&
      item.payMethod === PayMethod.PREPAID &&
      item.paymentStatus === PayStatus.PENDING;
    return (receiverCondition || senderCondition) && item.status < ParcelStatus.DELIVERED
  }

  @Computed
  get showSendAgainBtn() {
    // 再寄一件按钮的展示条件
    const status = [ParcelStatus.DELIVERED, ParcelStatus.CANCELED];
    // 这里需要将mock的收件订单排除
    return status.includes(this.orderInfo.status) && this.orderInfo.receiverPhone !== MOCK_RECEIVER_PHONE;
  }

  // 取消寄件
  cancelOrder() {
    ToastLoading.open();
    const nowTime = Date.now()
    const data = {
      id: this.orderInfo.id,
      parcelNumber: this.orderInfo.parcelNumber,
      status: ParcelStatus.CANCELED,
      cancelTime: nowTime,
      updateTime: nowTime,
    } as Parcel
    HttpApi.updateOrder(data).then((resp) => {
      if (resp) {
        // 如果选择了优惠券，则需要将之前的优惠券退还
        if (this.orderInfo.couponId) {
          const userId = this.userInfoModel.id;
          HttpApi.refundCoupon(userId, this.orderInfo.couponId);
        }
        EmitterUtils.emit('refreshOrderList');
        ToastDialog.showToast({ message: '取消成功' })
      }
    }).finally(() => {
      ToastLoading.close();
    })
  }

  // 删除订单
  deleteOrder() {
    ToastLoading.open();
    HttpApi.deleteParcel(this.orderInfo.parcelNumber).then((resp) => {
      if (resp) {
        EmitterUtils.emit('refreshOrderList');
        ToastDialog.showToast({ message: '删除成功' });
      }
    }).finally(() => {
      ToastLoading.close();
    })
  }

  // 添加备注
  addRemarkForOrder() {
    this.remarkText = this.orderInfo.remark;
    UIDialog.open({
      contentBuilder: () => this.inputContentBuilder(),
      showConfirmButton: true,
      showCancelButton: true,
      confirmButtonOptions: {
        buttonFontColor: $r('sys.color.font_emphasize'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      cancelButtonOptions: {
        buttonFontColor: $r('sys.color.font_primary'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      onConfirm: () => {
        ToastLoading.open();
        const nowTime = Date.now();
        const data = {
          id: this.orderInfo.id,
          parcelNumber: this.orderInfo.parcelNumber,
          updateTime: nowTime,
          remark: this.remarkText,
        } as Parcel
        HttpApi.updateOrder(data).then((resp) => {
          if (resp) {
            EmitterUtils.emit('refreshOrderList');
            ToastDialog.showToast({ message: '添加成功' })
          }
        }).finally(() => {
          ToastLoading.close();
        })
      },
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }

  // 确认签收
  deliveryOrder() {
    ToastLoading.open();
    const nowTime = Date.now()
    const data = {
      id: this.orderInfo.id,
      parcelNumber: this.orderInfo.parcelNumber,
      status: ParcelStatus.DELIVERED,
      updateTime: nowTime,
      deliveryTime: nowTime,
    } as Parcel
    HttpApi.updateOrder(data).then((resp) => {
      if (resp) {
        EmitterUtils.emit('refreshOrderList');
        ToastDialog.showToast({ message: '签收成功' })
        // 新增物流轨迹，已签收
        const parcel = {
          status: ParcelStatus.DELIVERED,
          updateTime: nowTime,
          senderCity: this.orderInfo.senderCity,
          receiverCity: this.orderInfo.receiverCity
        } as Parcel;
        this.createLogistics(parcel);
      }
    }).finally(() => {
      ToastLoading.close();
    })
  }

  // 立即支付
  payNow() {
    const payParam = {
      orderNo: this.orderInfo.parcelNumber,
      callback: () => {
        this.payOrderSuccess();
      },
      data: {
        id: this.orderInfo.id,
        parcelNumber: this.orderInfo.parcelNumber,
        price: this.orderInfo.price,
        status: this.orderInfo.status,
      } as Parcel
    } as OrderActionReq
    OrderUtil.handleImmediatePayment(payParam)
  }

  // 再寄一件
  sendAgain() {
    const controller = ControllerModule.get();
    if (controller) {
      controller.changeIndex(0);
    }
    RouterModule.push({ url: RouterMap.EXPRESS_PAGE });
  }

  payOrderSuccess() {
    ToastLoading.open();
    const nowTime = Date.now();
    const data = {
      id: this.orderInfo.id,
      parcelNumber: this.orderInfo.parcelNumber,
      paymentStatus: PayStatus.PAID,
      updateTime: nowTime,
    } as Parcel
    HttpApi.updateOrder(data).then((resp) => {
      if (resp) {
        ToastDialog.showToast({ message: '支付成功' });
        EmitterUtils.emit('refreshOrderList');
      }
    }).finally(() => {
      ToastLoading.close();
    })
  }

  // 插入物流轨迹表
  createLogistics(parcel: Parcel) {
    const operatorInfo = STATUS_OPERATOR_MAP.get(parcel.status);
    const logistics = {
      parcelNumber: this.orderInfo.parcelNumber,
      occurrenceTime: parcel.updateTime,
      description: CommonUtil.handleDes(STATUS_DESCRIPTION_MAP.get(parcel.status), parcel),
      location: this.orderInfo.senderCity,
      nodeStatus: parcel.status,
      operatorName: operatorInfo?.[0] || '',
      operatorPhone: operatorInfo?.[1] || '',
    } as Logistics;
    HttpApi.createLogistics(logistics);
  }

  // 跳转运单详情
  jumpToOrderInfoPage() {
    const detail = [ParcelStatus.AWAITING_PICKUP, ParcelStatus.PENDING_LOCKER, ParcelStatus.CANCELED];
    if (detail.includes(this.orderInfo.status)) {
      RouterModule.push({
        url: RouterMap.ORDER_DETAIL,
        param: this.orderInfo.parcelNumber,
      });
    } else {
      RouterModule.push({
        url: RouterMap.ORDER_INFO_PAGE,
        param: this.orderInfo.parcelNumber,
      });
    }
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Text(this.orderNumberText)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
          .lineHeight(16)

        SymbolGlyph($r('sys.symbol.plus_square_on_square'))
          .fontSize(16)
          .fontColor([$r('sys.color.icon_secondary')])
          .onClick(() => {
            CommonUtil.copyText(this.orderInfo.parcelNumber)
          })
      }

      Row() {
        // 寄件
        this.topBottomTextLayout({
          city: this.orderInfo.senderCity,
          name: this.orderInfo.senderName,
        })
        // 状态
        Column({ space: 8 }) {
          SymbolGlyph(this.symbolValue)
            .fontSize(16)
            .fontColor([$r('sys.color.icon_emphasize')])
          Text(STATUS_MAP[this.orderInfo.status])
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_emphasize'))
            .lineHeight(13)
        }
        .flexShrink(0)

        // 收件
        this.topBottomTextLayout({
          city: this.orderInfo.receiverCity,
          name: this.orderInfo.receiverName,
        })
      }
      .width('100%')

      // 待入柜状态
      if (this.orderInfo.status === ParcelStatus.PENDING_LOCKER) {
        Row() {
          Text('寄件码：').fontSize(12).fontColor($r('sys.color.font_tertiary'))
          Text(this.orderInfo.dropOffCode)
            .fontSize(16)
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(700)
            .margin({ left: 2 })
          Text('请前往附近任意快递柜寄件').fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ left: 4 })
        }
      } else if (this.orderInfo.status === ParcelStatus.AWAITING_PICKUP) { // 待取件
        TextDateTime({
          label: '预计上门取件时间：',
          value: this.pickupTime
        })
      } else if (this.orderInfo.status === ParcelStatus.CANCELED) { // 已取消
        TextDateTime({
          label: '取消时间：',
          value: this.cancelTime
        })
      } else {
        TextDateTime({
          label: '预计送达时间：',
          value: this.arrivalTime
        })
      }

      // 备注
      if (this.orderInfo.remark) {
        this.remarkView()
      }

      // 金额或支付方式
      this.priceOrPayMethodBuilder()

      Divider().backgroundColor($r('sys.color.comp_divider'))

      // 卡片底部操作按钮
      this.bottomActionCard()
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.jumpToOrderInfoPage()
    })
  }

  @Builder
  topBottomTextLayout($$: CityAndName) {
    Column({ space: 4 }) {
      Text($$.city)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(24)
      Text($$.name)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(19)
    }
    .flexGrow(1)
  }

  @Builder
  remarkView() {
    Row() {
      Text('备注：')
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(13)
      Text(this.orderInfo.remark)
        .fontSize(10)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight(13)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({
      top: 8,
      bottom: 8,
      left: 12,
      right: 12,
    })
    .borderRadius(8)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  priceOrPayMethodBuilder() {
    if (this.orderInfo.payMethod === PayMethod.PREPAID) {
      Text(`￥${this.orderInfo.price.toFixed(2)}`)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_emphasize'))
        .lineHeight(21)
        .textAlign(TextAlign.End)
    } else {
      Text('到付')
        .width('100%')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(19)
        .textAlign(TextAlign.End)
    }
  }

  @Builder
  inputContentBuilder() {
    Column({ space: 16 }) {
      Text('添加备注')
        .width('100%')
        .fontColor($r('sys.color.font_primary'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
      TextArea({ text: this.remarkText, placeholder: '请输入备注' })
        .width('100%')
        .height(64)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_M'), weight: FontWeight.Regular })
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .maxLength(120)
        .showCounter(true)
        .barState(BarState.Off)
        .onChange((value: string) => this.remarkText = value)
        .borderWidth(0)
        .borderRadius(8)
        .padding(8)
        .backgroundColor($r('sys.color.background_secondary'))
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
  }

  @Builder
  actionBtn($$: IActionInfo) {
    Button() {
      Text($$.label)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($$.fontColor || $r('sys.color.font_primary'))
        .fontWeight(400)
    }
    .type(ButtonType.Capsule)
    .padding({
      left: 8,
      right: 8,
      top: 4,
      bottom: 4,
    })
    .backgroundColor($$.btnBg || $r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      $$.onAction();
    })
  }

  @Builder
  bottomActionCard() {
    Row({ space: 12 }) {
      // 取消寄件
      if (this.showCancelBtn) {
        this.actionBtn({
          label: '取消寄件', onAction: () => {
            CommonDialogUtil.open({ content: '确定要取消寄件吗？' }, () => {
              this.cancelOrder();
            })
          },
        })
      }
      // 添加备注
      if (this.showAddRemarkBtn) {
        this.actionBtn({
          label: '添加备注', onAction: () => {
            this.addRemarkForOrder();
          },
        })
      }
      // 删除订单
      if (this.showDeleteBtn) {
        this.actionBtn({
          label: '删除订单',
          fontColor: $r('sys.color.warning'),
          onAction: () => {
            CommonDialogUtil.open({ content: '删除后将无法恢复，是否确认删除？' }, () => {
              this.deleteOrder();
            })
          },
        })
      }
      // 确认签收
      if (this.showDeliveryBtn) {
        this.actionBtn({
          label: '确认签收',
          fontColor: $r('sys.color.white'),
          btnBg: $r('sys.color.comp_background_emphasize'),
          onAction: () => {
            CommonDialogUtil.open({
              content: '是否确认签收？',
              confirmBtnFontColor: $r('sys.color.font_emphasize'),
              cancelBtnFontColor: $r('sys.color.font_primary'),
            }, () => {
              this.deliveryOrder();
            })
          },
        })
      }
      // 再寄一件
      if (this.showSendAgainBtn) {
        this.actionBtn({
          label: '再寄一件', onAction: () => {
            this.sendAgain();
          },
        })
      }
      // 待支付
      if (this.showPayNowBtn) {
        this.actionBtn({
          label: '立即支付',
          fontColor: $r('sys.color.white'),
          btnBg: $r('sys.color.comp_background_emphasize'),
          onAction: () => {
            this.payNow()
          },
        })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
  }
}

@ComponentV2
struct TextDateTime {
  @Param label: ResourceStr = '';
  @Param value: string = '';

  build() {
    Row({ space: 2 }) {
      Text(this.label).fontSize(12).fontColor($r('sys.color.font_tertiary')).lineHeight(16)
      Text(this.value).fontSize(12).fontColor($r('sys.color.font_secondary')).lineHeight(16)
    }
  }
}