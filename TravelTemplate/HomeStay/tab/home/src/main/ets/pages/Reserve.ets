import { common } from '@kit.AbilityKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Constants, NavPathName } from 'constant';
import { RoomType, Tag, Passenger as PassengerType, Order } from 'type';
import { CalendarUtil, Constants as CalConstants, DateModel } from 'calendar_select';
import { doRandBySync, getCurrentTime, checkPsgInfo, hasPassenger, isValidPhoneNo, Logger,
  formatPriceToNumber } from 'util';
import { AddOrModifyPassengerRequest, CreateOrderRequest, GetInfoRequest, https, UpdateOrderRequest } from 'network';
import { CommonHeader } from 'component';
import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';
import { SelectPassengerSheet } from '../components/SelectPassengerSheet';
import { AddPassengerSheet } from '../components/AddPassengerSheet';
import { getRoomOrderAmount } from '../viewmodel/ReservePageVM';
import { EnhancedSource } from '../model/Index';
import { Passenger } from '../model/Passengers';

@Builder
export function ReserveBuilder() {
  Reserve();
}

@ComponentV2
export struct Reserve {
  @Local guest: string = '';
  @Local phone: string = '';
  @Local remark: string = '';
  @Local amount: number = 0;
  @Local count: number = 1;
  @Local startDate: DateModel | undefined = CalendarUtil.getStartDate();
  @Local endDate: DateModel | undefined = CalendarUtil.getEndDate();
  @Local openId: string = '';
  @Local roomTypeItem: RoomType = new RoomType();
  @Local selectPassenger: Passenger = new Passenger();
  @Local isShowSelectSheet: boolean = false;
  @Local isShowAddSheet: boolean = false;
  @Local isEditMode: boolean = false;
  @Local editingPassengerId: number = -1;
  @Local passengerList: PassengerType[] = [];
  @Local selectedPassengerIds: number[] = [];
  @Local addGuestName: string = '';
  @Local addGuestPhone: string = '';
  @Local addGuestCardType: number = -1;
  @Local addGuestCardNo: string = '';
  controller: TextInputController = new TextInputController();
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private passengerId: number = 0;

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: this.roomTypeItem.roomTypeName, showBackButton: true, backButtonClick: () => {
          this.mainPathStack.pop();
        }})

        Scroll() {
          Column({ space: 12 }) {
            Column({ space: 12 }) {
              Text('订房日期')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
                .margin({ bottom: 4 })

              Row() {
                Row({ space: 8 }) {
                  Text(`${this.startDate?.month}月${this.startDate?.day}日`)
                    .fontColor($r('sys.color.font_primary'))
                  Text(`周${CalConstants.WEEK[this.startDate?.week ?? 0]}`)
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                  Text(' —— ')
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                  Text(`${this.endDate?.month}月${this.endDate?.day}日`)
                    .fontColor($r('sys.color.font_primary'))
                  Text(`周${CalConstants.WEEK[this.endDate?.week ?? 0]}`)
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                }.layoutWeight(1)

                Text(`共${CalendarUtil.getNight()}晚`)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_secondary'))
              }

              Divider().width(Constants.FULL_SCREEN).color($r('sys.color.comp_divider'))

              Text(this.roomTypeItem.roomTypeName)
                .fontColor($r('sys.color.font_primary'))
            }
            .width(Constants.FULL_SCREEN)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .padding(12)
            .borderRadius(16)

            Column({ space: 8 }) {
              Row() {
                Text('入住信息')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                Blank()
                Column() {
                  Text('选择/添加')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.multi_color_04'))
                }
                .padding({ top: 4, bottom: 4, left: 8, right: 8 })
                .borderRadius(14)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .onClick(() => {
                  this.openSelectPassengerSheet();
                })
              }
              .width(Constants.FULL_SCREEN)
              .padding({ top: 12, bottom: 8 })
              .bindSheet($$this.isShowSelectSheet, this.selectPassengerSheetBuilder(), {
                height: SheetSize.LARGE,
                showClose: false,
                dragBar: false,
              })

              Text() {
                Span('请选择/填写入住人信息，已填写')
                Span(`${this.selectedPassengerIds.length}`)
                  .fontColor($r('sys.color.warning'))
                Span('位')
              }
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
            }
            .width(Constants.FULL_SCREEN)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .padding(12)
            .borderRadius(16)

            Column({ space: 8 }) {
              Text('预订须知')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
                .padding({ top: 12 })

              ForEach(this.roomTypeItem.instructions?.checkOut ?? [], (item: Tag) => {
                Text(`【${item.tag}】：${item.subTags.join('，')}`)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                  .lineHeight(18)
              }, (item: Tag, index: number) => `${item.tag}_${index}`)
            }
            .width(Constants.FULL_SCREEN)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .padding(12)
            .borderRadius(16)
          }
          .padding({ left: 16, right: 16, top: 12 })
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        Row() {
          Row({ space: 12 }) {
            Text('总额')
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
            Text(`￥${formatPriceToNumber(this.amount)}`)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.warning'))
          }

          Blank().layoutWeight(1)

          Button('提交订单')
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.font_primary'))
            .height(40)
            .borderRadius($r('sys.float.corner_radius_level10'))
            .padding({ top: 10, bottom: 10, left: 16, right: 16 })
            .onClick(() => {
              this.pay();
            })
        }
        .width(Constants.FULL_SCREEN)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor($r('sys.color.background_primary'))
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN);
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params: EnhancedSource = context.pathInfo.param as EnhancedSource;
      if (params?.source === 'HotelDetail') {
        this.roomTypeItem = (context.pathInfo.param as EnhancedSource).data;
        this.amount = getRoomOrderAmount(this.roomTypeItem.roomTypePriceList,
          this.startDate ?? new DateModel(1970, 1, 1, 0),
          this.endDate ?? new DateModel(1970, 1, 1, 0));
      }
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  async openSelectPassengerSheet() {
    this.isShowSelectSheet = true;
    const data: GetInfoRequest = {
      appId: '',
      openId: this.openId ?? '',
    };
    const res = await https.queryPassengers(data);
    if (res?.code === 200) {
      this.passengerList = res.data ?? [];
    }
  }

  togglePassengerSelection(item: PassengerType) {
    const index = this.selectedPassengerIds.indexOf(item.passengerId);
    if (index >= 0) {
      this.selectedPassengerIds.splice(index, 1);
    } else {
      this.selectedPassengerIds.push(item.passengerId);
    }
    this.selectedPassengerIds = [...this.selectedPassengerIds];
  }

  confirmPassengerSelection() {
    const selectedPassengers = this.passengerList.filter((item: PassengerType) =>
      this.selectedPassengerIds.includes(item.passengerId));
    if (selectedPassengers.length > 0) {
      const first = selectedPassengers[0];
      this.guest = first.passengerName;
      this.phone = first.passengerPhone;
      this.passengerId = first.passengerId;
    }
    this.isShowSelectSheet = false;
  }

  @Builder
  selectPassengerSheetBuilder() {
    SelectPassengerSheet({
      passengerList: this.passengerList,
      selectedPassengerIds: this.selectedPassengerIds,
      isShowAddSheet: this.isShowAddSheet,
      onClose: () => {
        this.isShowSelectSheet = false;
      },
      onTogglePassenger: (item: PassengerType) => {
        this.togglePassengerSelection(item);
      },
      onConfirm: () => {
        this.confirmPassengerSelection();
      },
      onAddClick: () => {
        this.isEditMode = false;
        this.editingPassengerId = -1;
        this.addGuestName = '';
        this.addGuestPhone = '';
        this.addGuestCardType = -1;
        this.addGuestCardNo = '';
        this.isShowAddSheet = true;
      },
      onEditClick: (item: PassengerType) => {
        this.isEditMode = true;
        this.editingPassengerId = item.passengerId;
        this.addGuestName = item.passengerName;
        this.addGuestPhone = item.passengerPhone;
        this.addGuestCardType = Number(item.passengerCardType) || 0;
        this.addGuestCardNo = item.passengerCardId ?? '';
        this.isShowAddSheet = true;
      },
    }).bindSheet($$this.isShowAddSheet, this.addPassengerSheetBuilder(), {
      height: SheetSize.LARGE,
      showClose: false,
      dragBar: false,
    })
  }

  @Builder
  addPassengerSheetBuilder() {
    AddPassengerSheet({
      isEditMode: this.isEditMode,
      editingPassengerId: this.editingPassengerId,
      passengerList: this.passengerList,
      initialGuestName: this.addGuestName,
      initialGuestPhone: this.addGuestPhone,
      initialGuestCardType: this.addGuestCardType,
      initialGuestCardNo: this.addGuestCardNo,
      onClose: () => {
        this.isShowAddSheet = false;
      },
      onSave: (name: string, phone: string, cardType: number, cardNo: string) => {
        this.addGuestName = name;
        this.addGuestPhone = phone;
        this.addGuestCardType = cardType;
        this.addGuestCardNo = cardNo;
        this.savePassenger();
      },
      onDelete: (passengerId: number) => {
        this.editingPassengerId = passengerId;
        this.deletePassenger();
      },
    })
  }

  async deletePassenger() {
    try {
      const res = await https.deletePassenger(this.editingPassengerId);
      if (res.code === 200) {
        this.selectedPassengerIds = this.selectedPassengerIds.filter(id => id !== this.editingPassengerId);
        this.openSelectPassengerSheet();
      }
    } catch (err) {
      Logger.error('Reserve', 'delete passenger failed: ' + JSON.stringify(err));
    }
  }

  async savePassenger() {
    if (this.addGuestName.length === 0 || !isValidPhoneNo(this.addGuestPhone)) {
      ToastDialog.showToast({ message: '请正确填写姓名或手机号码' });
      return;
    }

    const passengerId = hasPassenger(this.addGuestName, this.addGuestPhone);
    const data: AddOrModifyPassengerRequest = {
      passengerId: passengerId,
      passengerName: this.addGuestName,
      passengerPhone: this.addGuestPhone,
      passengerCardType: this.addGuestCardType.toString(),
      passengerCardId: this.addGuestCardNo,
      appId: '',
    };

    const res = await https.addPassengers(data);
    if (res.code === 200) {
      ToastDialog.showToast({ message: '添加成功' });
      const newPassenger: PassengerType = {
        passengerId: passengerId,
        openId: '',
        passengerName: this.addGuestName,
        passengerPhone: this.addGuestPhone,
        passengerCardType: this.addGuestCardType.toString(),
        passengerCardId: this.addGuestCardNo,
        appId: '',
      };
      this.passengerList = [...this.passengerList, newPassenger];
      this.isShowAddSheet = false;
    }
  }

  addOrSelectPassenger() {
    this.openSelectPassengerSheet();
  }

  aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  buildOrderFromReserve(orderSn: string): Order {
    let order = new Order();
    order.orderSn = orderSn;
    order.orderName = this.roomTypeItem.roomTypeName;
    order.orderStatus = 1;
    order.orderType = 0;
    order.passengerName = this.guest;
    order.passengerPhone = this.phone;
    order.orderRemark = this.remark;
    order.roomTypeBanner = this.roomTypeItem.roomTypeBanner;
    order.roomTypeActualPrice = this.amount;
    order.amount = this.amount;
    order.planCheckInDate = CalendarUtil.getFormatDate(this.startDate ?? new DateModel(1970, 1, 1, 0)) ?? '';
    order.planCheckOutDate = CalendarUtil.getFormatDate(this.endDate ?? new DateModel(1970, 1, 1, 0)) ?? '';
    order.dayCount = CalendarUtil.getDayCount(this.startDate ?? new DateModel(1970, 1, 1, 0),
      this.endDate ?? new DateModel(1970, 1, 1, 0));
    order.createTime = getCurrentTime();
    order.openId = this.openId ?? '';
    return order;
  }

  async openCashierPicker(orderSn: string, amount: number) {
    const order = this.buildOrderFromReserve(orderSn);
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
          this.mainPathStack.replacePathByName(NavPathName.ROOM_ORDER_DETAIL, order);
          cashierPicker.close();
        }
      });

    aggregatedPaymentService.registerPaymentCallback(
      async (_type: PaymentType, isSuccess: boolean) => {
        if (!isSuccess) {
          ToastDialog.showToast({ message: '本地调试阶段，模拟支付成功回调' });
        }
        await https.updateOrder({ orderSn: orderSn, orderStatus: 2 } as UpdateOrderRequest);
        order.orderStatus = 2;
        this.mainPathStack.replacePathByName(NavPathName.ROOM_ORDER_DETAIL, order);
        cashierPicker.close();
      },
    );

    cashierPicker
      .reset()
      .setAmount(amount * 100)
      .setTradeSummary(this.roomTypeItem.roomTypeName)
      .open();
  }

  async pay() {
    if (checkPsgInfo(this.guest, this.phone) || !isValidPhoneNo(this.phone)) {
      ToastDialog.showToast({ message: '请填写正确的入住人姓名或联系电话' });
      return;
    }

    this.passengerId = hasPassenger(this.guest, this.phone);

    const data: CreateOrderRequest = {
      appId: '',
      passengerId: this.passengerId,
      id: this.roomTypeItem.id,
      orderStatus: 1,
      orderType: 0,
      orderRemark: this.remark,
      planCheckInDate: CalendarUtil.getFormatDate(this.startDate ?? new DateModel(1970, 1, 1, 0)) ?? '',
      planCheckOutDate: CalendarUtil.getFormatDate(this.endDate ?? new DateModel(1970, 1, 1, 0)) ?? '',
      checkInPersonNum: 2,
      dayCount: CalendarUtil.getDayCount(this.startDate ?? new DateModel(1970, 1, 1, 0),
        this.endDate ?? new DateModel(1970, 1, 1, 0)),
      openId: this.openId ?? '',
      orderSn: doRandBySync(),
      createTime: getCurrentTime(),
      amount: this.amount,
      count: this.count,
      goodsCount: 0,
      goodsBanner: '',
      commodityId: 0,
      sfc: '',
    };

    const res = await https.createOrder(data);

    if (res.code === 200) {
      this.openCashierPicker(data.orderSn, this.amount);

      const psgData = {
        passengerId: this.passengerId,
        passengerName: this.guest,
        passengerPhone: this.phone,
        passengerCardType: '0',
        passengerCardId: '',
        appId: '',
      } as AddOrModifyPassengerRequest;

      let passengers: string | undefined = AppStorage.get('psgList');

      if (!passengers || this.passengerId === JSON.parse(passengers)?.length) {
        await https.addPassengers(psgData);
      }
    }
  }
}
