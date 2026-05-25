import {
  BookingRecordInfo,
  CardInfo,
  ConsumeType,
  CourseBookingInfo,
  CourseDetailModel,
  DateUtil,
  OrderType,
  OrderInfo,
  MockService,
  OrderState,
  EmitterConstant,
  BreakpointModel,
  BreakpointNameEnum,
  ScreenPropStorage,
  AccountUpdate,
  Logger} from 'external_interactions'
import { RechargeRouteParam } from 'module_recharge';
import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import  EventData  from '@ohos.events.emitter';

const TAG = '[OrderContent]';

@ComponentV2
export struct OrderContent {
  @Param orderState: OrderState = 0
  @Local orderList: OrderInfo[] = []
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Param index: number = 0
  @Param currentTabIndex: number = 0
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate;
  @Local loading: boolean = false
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.orderList = MockService.getOrderListByState(this.orderState)
    this.refresh()
    try {
      emitter.on(EmitterConstant.ORDER_COMPLETE, () => {
        this.orderList = MockService.getOrderListByState(this.orderState)
      })
    } catch (e) {
      Logger.error(TAG, `emitter on failed. error: ${JSON.stringify(e)}`)
    }
  }

  refresh(): void {
    this.loading = true
    this.orderList.forEach((item: OrderInfo) => {
      if (Date.now() - DateUtil.parseDateString(item.createTime).getTime() >= 20 * 60 * 1000 && // todo 同步编辑倒计时时间
        item.orderState === OrderState.TO_BE_PAY) {
        item.orderState = OrderState.CANCELED
      }
    }, (item: OrderInfo) => JSON.stringify(item))
    this.loading = false
  }

  aboutToDisappear(): void {
    try {
      emitter.off(EmitterConstant.ORDER_COMPLETE)
    } catch (e) {
      Logger.error(TAG, `emitter off failed. error: ${JSON.stringify(e)}`)
    }
  }

  @Computed
  get listLanes() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint as BreakpointNameEnum)) {
      return 1;
    }
    if ([BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint as BreakpointNameEnum)) {
      return 2;
    }
    return 3;
  }

  build() {
    Column() {
      Column() {
        Image($r('app.media.no_result'))
          .width(144)
          .height(144)
          .margin({ bottom: 12 })
        Text('未查询到订单信息')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor('#999999')
      }
      .height('50%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .visibility(this.orderList.length > 0 ? Visibility.None : Visibility.Visible)

      Refresh({ refreshing: $$this.loading }) {
        List({ space: 12 }) {
          ForEach(this.orderList, (item: OrderInfo) => {
            ListItem() {
              RecordItem({ orderInfo: item, pathStack: this.pathStack })
            }
          }, (item: OrderInfo) => JSON.stringify(item))
        }
        .lanes(this.listLanes, 16)
        .margin({ left: 16, right: 16 })
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
      }
      .onRefreshing(() => {
        this.refresh();
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .margin({ top: 16 })
  }

  @Monitor('currentTabIndex', 'accountUpdateStorage.accountUpdate')
  tabIndexChange() {
    if (this.index === this.currentTabIndex) {
      this.orderList = MockService.getOrderListByState(this.orderState)
    }
  }
}


@ComponentV2
struct RecordItem {
  @Param orderInfo: OrderInfo = {} as OrderInfo;
  @Local bookingRecord?: BookingRecordInfo = undefined;
  @Local courseBookingInfo?: CourseBookingInfo = undefined;
  @Local courseDetailInfo?: CourseDetailModel = undefined;
  @Local cardDetailInfo?: CardInfo = undefined ;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate;
  @Local orderState: OrderState = this.orderInfo.orderState

  aboutToAppear(): void {
    if (this.orderInfo.orderType === OrderType.CARD) {
      if (this.orderInfo.cardId) {
        this.cardDetailInfo = MockService.getCardById(this.orderInfo.cardId)
      } else {
        this.courseDetailInfo = MockService.getCourseById(this.orderInfo.bookingId!)
      }
    } else {
      this.bookingRecord = MockService.getBookingRecordById(this.orderInfo.bookingId!)
      this.courseBookingInfo = MockService.getCourseBookingById(this.bookingRecord?.courseBookingId!)
      this.courseDetailInfo = MockService.getCourseById(this.courseBookingInfo?.courseId)
      if (this.orderInfo.cardId?.length === 0) {
        this.courseDetailInfo = MockService.getCourseById(this.orderInfo.bookingId!)
      }
    }
    try {
      emitter.on('paySuccess', (data: EventData.EventData) => {
        if (data.data) {
          if (data.data.id === this.orderInfo.id) {
            this.orderState = OrderState.COMPLETED
          }
        }
      })
    } catch (e) {
      Logger.error(TAG, `emitter on failed. error: ${JSON.stringify(e)}`)
    }
    try {
      emitter.on('autoCancel', (data: EventData.EventData) => {
        if (data.data) {
          if (data.data.id === this.orderInfo.id) {
            this.orderState = OrderState.CANCELED
          }
        }
      })
    } catch (e) {
      Logger.error(TAG, `emitter on failed. error: ${JSON.stringify(e)}`)
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off('paySuccess')
    } catch (e) {
      Logger.error(TAG, `emitter off failed. error: ${JSON.stringify(e)}`)
    }
    try {
      emitter.off('autoCancel')
    } catch (e) {
      Logger.error(TAG, `emitter off failed. error: ${JSON.stringify(e)}`)
    }
  }

  build() {
    Column() {
      Row() {
        Text('订单时间: ' +
        DateUtil.formatDate(DateUtil.parseDateString(this.orderInfo.createTime), '.', undefined, 'medium'))
          .fontSize(14)

        Text(MockService.getOrderStateString(this.orderState))
          .fontSize(14)
          .fontColor(this.orderState === OrderState.TO_BE_PAY ? '#FF9019' : '#000000')
      }.justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(18)

      Divider()
        .margin({ top: 12, bottom: 12 })

      if (this.orderInfo.orderType === OrderType.CARD) {
        Row() {
          Image(this.orderInfo.cardId?.length === 0 ? $r(this.courseDetailInfo?.advImage)
            : $r(this.cardDetailInfo?.advImage))
            .width(80)
            .height(80)
            .borderRadius(8)
          Column() {
            Row() {
              Text(this.orderInfo.cardId?.length === 0 ? this.courseDetailInfo?.courseName
                : this.cardDetailInfo?.shortName)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
              Text('¥' + (this.orderInfo.cardId?.length === 0 ? this.courseDetailInfo?.price
                : this.cardDetailInfo?.price))
                .fontSize(14)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              if (this.orderInfo.cardId?.length === 0) {
                Text('')
              } else {
              Text(this.cardDetailInfo?.consumeType === ConsumeType.TIMES ? this.cardDetailInfo.quota + '次' :
                MockService.getQuotaDurationDesc(this.cardDetailInfo?.quota) + '卡')
                .fontSize(14)
                }
              Text('x' + this.orderInfo.number)
                .fontSize(14)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .justifyContent(FlexAlign.SpaceAround)
          .alignItems(HorizontalAlign.Start)
          .height('100%')
          .layoutWeight(1)
          .margin({ left: 16 })
        }.width('100%')
        .height(80)
      } else {
        Row() {
          Image($r(this.courseDetailInfo?.advImage))
            .width(80)
            .height(80)
            .borderRadius(8)
          Column() {
            Text(this.courseDetailInfo?.courseName)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Row() {
              Text('¥' + this.courseDetailInfo?.price)
                .fontSize(14)
              Text('x' + this.orderInfo.number)
                .fontSize(14)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .justifyContent(FlexAlign.SpaceAround)
          .alignItems(HorizontalAlign.Start)
          .height('100%')
          .layoutWeight(1)
          .margin({ left: 16 })
        }.width('100%')
        .height(80)
      }

      Text('订单号：' + this.orderInfo.id)
        .fontSize(10)
        .margin({ top: 8 })

      Divider()
        .margin({ top: 12, bottom: 12 })
      Row() {
        Text('订单金额：¥' + this.orderInfo.price * this.orderInfo.number)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
        Button('去支付')
          .fontSize($r('sys.float.Body_M'))
          .width(100)
          .fontColor($r('sys.color.comp_background_list_card'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF9019')
          .margin({ left: 16 })
          .onClick(() => {
            if (MockService.account.balance >= this.orderInfo.price) {
              MockService.account.balance -= this.orderInfo.price
              MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account))
              MockService.dataPreferences.flush()
              if (this.orderInfo.cardId?.length === 0) {
                AppStorage.setOrCreate<boolean>(this.orderInfo.bookingId, true)
              }
              this.orderInfo.orderState = OrderState.COMPLETED
              this.orderInfo.payTime = DateUtil.formatDate(new Date(), '-', undefined, 'medium')
              let mockOrder = MockService.getOrderById(this.orderInfo.id)
              mockOrder.orderState = OrderState.COMPLETED
              mockOrder.payTime = this.orderInfo.payTime
              MockService.dataPreferences.putSync('order',  JSON.stringify(MockService.orderList))
              MockService.dataPreferences.flush()
              if (this.orderInfo.orderType === OrderType.CARD && this.cardDetailInfo?.id) {
                MockService.addUserCard(this.cardDetailInfo!.id, this.cardDetailInfo!.quota)
              }
              this.accountUpdate = !this.accountUpdate
              try {
                emitter.emit(EmitterConstant.ORDER_COMPLETE)
              } catch (e) {
                Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
              }
            } else {
              this.getUIContext().getPromptAction().showToast({ message: '余额不足' })
              this.pathStack.pushPath(
                {
                  name: 'vip/VipRecharge',
                  param: {
                    balance: MockService.account.balance,
                    handleBack:(balance: number)=>{
                      MockService.account.balance = balance;
                      AppStorage.set('globalBalance', balance)
                  }
              } as RechargeRouteParam})
            }
          })
          .visibility(this.orderState === OrderState.TO_BE_PAY ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(16)
    .onClick(() => {
      this.pathStack.pushPath({ name: 'card/orderDetail', param: this.orderInfo })
    })
  }
}