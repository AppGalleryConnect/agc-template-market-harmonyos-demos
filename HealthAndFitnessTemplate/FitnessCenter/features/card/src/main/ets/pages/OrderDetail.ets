import {
  BookingRecordInfo,
  BookJumpSearch,
  CardInfo,
  CourseBookingInfo,
  CourseDetailModel,
  DateUtil,
  EmitterConstant,
  GridRowColSetting,
  Logger,
  MockService,
  OrderInfo,
  OrderState,
  OrderType,
} from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
import { RechargeRouteParam } from 'module_recharge';
import { emitter, pasteboard } from '@kit.BasicServicesKit';
import  EventData  from '@ohos.events.emitter';

const TAG = '[OrderDetail]';

@ComponentV2
export struct OrderDetail {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local bookJumpSearchStorage : BookJumpSearch = AppStorageV2.connect(BookJumpSearch, 'BookJumpSearch', () =>new BookJumpSearch())!
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate;
  @Param @Once orderInfo: OrderInfo = {} as OrderInfo;
  @Local orderState: number = this.orderInfo.orderState
  @Local bookingRecord?: BookingRecordInfo = undefined;
  @Local courseBookingInfo?: CourseBookingInfo = undefined;
  @Local courseDetailInfo?: CourseDetailModel = undefined;
  @Local cardDetailInfo?: CardInfo = undefined;
  // 在组件类中添加倒计时相关属性
  @Local countdownTime: string = '00:20:00'; // todo 支持编辑未支付订单的倒计时开始时间
  private countdownTimer: number | null = null; // 定时器引用
  private endTime: number = 0; // 结束时间戳（毫秒）

  @Monitor('screenPropStorage.topRectHeight', 'screenPropStorage.bottomRectHeight')
  onScreenPropStorage(mon: IMonitor) {

  }

  // 在组件的 aboutToAppear 生命周期中启动倒计时
  aboutToAppear() {
    // 设置结束时间为当前时间 + 20分钟
    this.startCountdown();
  }

  // 启动倒计时
  startCountdown() {
    this.updateCountdownDisplay();
    this.countdownTimer = setInterval(() => {
      this.updateCountdownDisplay();
    }, 1000); // 每秒更新一次
  }

  // 更新倒计时显示
  updateCountdownDisplay() {
    const currentTime = Date.now();
    const remainingTime = this.endTime - currentTime;

    if (remainingTime > 0) {
      // 计算剩余时间
      const hours = Math.floor(remainingTime / (1000 * 60 * 60));
      const minutes = Math.floor((remainingTime % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((remainingTime % (1000 * 60)) / 1000);

      // 格式化时间显示
      this.countdownTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      // 倒计时结束
      this.countdownTime = '00:00:00';
      this.clearCountdown();
      // 这里可以触发订单自动取消的逻辑
      if (this.orderState === OrderState.TO_BE_PAY) {
        this.handleCountdownEnd();
      }
    }
  }

  // 清理倒计时定时器
  clearCountdown() {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  }

  // 倒计时结束处理
  handleCountdownEnd() {
    // 这里可以处理订单自动取消的逻辑
    Logger.info(TAG, 'Order cancel automatically.')
    // 可以更新订单状态或触发其他业务逻辑
    this.orderState = OrderState.CANCELED
    let mockOrder = MockService.getOrderById(this.orderInfo.id!)
    if (mockOrder) {
      mockOrder.orderState = OrderState.CANCELED
      MockService.dataPreferences.putSync('order', JSON.stringify(MockService.orderList))
      MockService.dataPreferences.flush()
    }
    let data: EventData.EventData = {
      data: {
        'id' : this.orderInfo.id
      }
    } as EventData.EventData
    try {
      emitter.emit('autoCancel', data)
    } catch (e) {
      Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({ title: '订单详情',  onBackClick:()=>{this.pathStack.pop()}})
          .margin({ left: 16, right: 16 })

        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            Column() {
              Scroll() {
                Column() {
                  Column() {
                    Text(this.orderState === OrderState.COMPLETED ? '已完成' :
                      (this.orderState === OrderState.TO_BE_PAY ? '待支付...' : '已取消'))
                      .fontSize(24)
                      .textAlign(TextAlign.Start)
                      .width('100%')
                      .margin({ bottom: 8, left: 8 })

                    Text('订单将在 ') {
                      Span(this.countdownTime)
                        .fontColor($r('sys.color.warning'))
                      Span(' 后自动取消')
                    }
                    .fontSize(14)
                    .textAlign(TextAlign.Start)
                    .width('100%')
                    .margin({ bottom: 16, left: 8 })
                    .visibility(this.orderState === OrderState.TO_BE_PAY ? Visibility.Visible : Visibility.None)
                    // 消费信息
                    Column({ space: 16 }) {
                      Text('订单时间：' + DateUtil.formatDate(DateUtil.parseDateString(this.orderInfo.createTime),
                        '.', 'short', 'medium'))
                        .fontWeight(FontWeight.Bold)
                        .fontSize(14)

                      Divider()

                      Row() {
                        Image($r((this.orderInfo.orderType === OrderType.CARD && this.orderInfo.cardId?.length !== 0)
                          ? this.cardDetailInfo?.advImage : this.courseDetailInfo?.advImage))
                          .width(80)
                          .height(80)
                          .borderRadius(8)
                        Text(this.orderInfo.orderType === OrderType.CARD && this.orderInfo.cardId?.length !== 0
                          ? this.cardDetailInfo?.shortName : this.courseDetailInfo?.courseName)
                          .fontSize(14)
                          .fontWeight(FontWeight.Bold)
                          .margin({ left: 16, top: 5 })
                      }
                      .alignItems(VerticalAlign.Top)


                      Row() {
                        Text('数量')
                          .fontSize(14)
                        Text(this.orderInfo.number.toString())
                          .fontSize(14)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)

                      Divider()

                      Row() {
                        Text('合计')
                          .fontSize(14)
                        Text('¥' + this.orderInfo.price * this.orderInfo.number)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)

                      Row() {
                        Text('实际支付')
                          .fontSize(14)
                        Text('¥' + this.orderInfo.price * this.orderInfo.number)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                      .visibility(this.orderState === OrderState.COMPLETED ? Visibility.Visible : Visibility.None)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                    .borderRadius(16)
                    .backgroundColor($r('sys.color.comp_background_list_card'))
                    .padding(16)
                    .margin({ bottom: 16 })

                    // 订单信息
                    Column({ space: 16 }) {
                      Text('订单信息')
                        .fontWeight(FontWeight.Bold)
                        .fontSize(14)

                      Divider()

                      Row() {
                        Row() {
                          Text('订单编号')
                            .fontSize(14)
                            .margin({ right: 16 })
                          Text(this.orderInfo.id)
                            .fontSize(14)
                        }

                        Image($r('app.media.icon_copy'))
                          .width(16)
                          .onClick(() => {
                            copyText(this.orderInfo.id)
                          })
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)

                      if (this.orderInfo.payTime) {
                        Row() {
                          Text('支付时间')
                            .fontSize(14)
                            .margin({ right: 16 })
                          Text(DateUtil.formatDate(DateUtil.parseDateString(this.orderInfo.payTime!), '.', 'short', 'medium'))
                            .fontSize(14)
                        }
                        .width('100%')
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                    .borderRadius(16)
                    .backgroundColor($r('sys.color.comp_background_list_card'))
                    .padding(16)
                    .margin({ bottom: 16 })
                  }
                  .layoutWeight(1)
                }
              }
              .layoutWeight(1)
              .padding({ left: 16, right: 16 })
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)

              Row() {
                Button('立即预约', { type: ButtonType.Capsule, stateEffect: true })
                  .width('90%')
                  .height(40)
                  .fontColor($r('sys.color.comp_background_list_card'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_M'))
                  .backgroundColor('#FF9019')
                  .borderRadius(8)
                  .onClick(() => {
                    // 单击立即预约，清空路由栈，回到Index.ets页，通过全局状态存储，跳到 预约 页
                    this.pathStack.clear(false)
                    // todo
                    if (this.courseDetailInfo) {
                      try {
                        emitter.emit(EmitterConstant.CLICK_BOOK_DETAIL)
                      } catch (e) {
                        Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                      }
                      this.bookJumpSearchStorage.bookJumpSearch = this.courseDetailInfo.courseName
                    }
                    if (this.cardDetailInfo) {
                      try {
                        emitter.emit(EmitterConstant.CLICK_BOOK_DETAIL)
                      } catch (e) {
                        Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                      }
                      this.bookJumpSearchStorage.bookJumpSearch =
                        MockService.getCourseById(this.cardDetailInfo.avaiCourse).courseName
                    }
                  })
              }
              .margin({ left: 12, right: 12, bottom: 50 })
              .visibility(this.orderInfo.orderState !== OrderState.COMPLETED ? Visibility.None :
                (AppStorage.get(this.orderInfo?.bookingId) ? Visibility.Visible : Visibility.None))

              Row() {
                Text('立即支付')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .fontColor($r('sys.color.comp_background_list_card'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
              }
              .height(40)
              .margin({ left: 12, right: 12, bottom: 50 })
              .backgroundColor('#FF9019')
              .borderRadius(20)
              .visibility(this.orderState === OrderState.TO_BE_PAY ? Visibility.Visible : Visibility.None)
              .onClick(() => {
                if (MockService.account.balance >= this.orderInfo.price) {
                  MockService.account.balance -= this.orderInfo.price
                  MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account))
                  MockService.dataPreferences.flush()
                  if (this.orderInfo.cardId?.length === 0) {
                    AppStorage.setOrCreate<boolean>(this.orderInfo.bookingId, true)
                  }
                  let data: EventData.EventData = {
                    data: {
                      'id' : this.orderInfo.id
                    }
                  } as EventData.EventData
                  try {
                    emitter.emit('paySuccess', data)
                  } catch (e) {
                    Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                  }
                  this.orderInfo.orderState = OrderState.COMPLETED
                  this.orderState = OrderState.COMPLETED
                  this.orderInfo.payTime = DateUtil.formatDate(new Date(), '-', undefined, 'medium')
                  let mockOrder = MockService.getOrderById(this.orderInfo.id)
                  mockOrder.orderState = OrderState.COMPLETED
                  mockOrder.payTime = this.orderInfo.payTime
                  MockService.dataPreferences.putSync('order', JSON.stringify(MockService.orderList))
                  MockService.dataPreferences.flush()
                  if (this.orderInfo.orderType === OrderType.CARD && this.orderInfo.cardId?.length !== 0) {
                    MockService.addUserCard(this.cardDetailInfo!.id, this.cardDetailInfo!.quota)
                  }
                  this.accountUpdate = !this.accountUpdate
                } else {
                  this.getUIContext().getPromptAction().showToast({ message: '余额不足' })
                  this.pathStack.pushPath({ name: 'vip/VipRecharge',
                    param: {
                      balance: MockService.account.balance,
                      handleBack:(balance: number)=>{
                        MockService.account.balance = balance;
                        AppStorage.set('globalBalance', balance)
                      }
                    } as RechargeRouteParam} )
                }
              })
            }
          }
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
      this.orderInfo = ctx?.pathInfo?.param as OrderInfo;
      this.orderState = this.orderInfo.orderState
      // todo 支持修改未支付订单持续时间
      this.endTime = DateUtil.parseDateString(this.orderInfo?.createTime).getTime() + 20 * 60 * 1000;
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
        if (this.orderInfo.orderState === OrderState.COMPLETED) {
          AppStorage.setOrCreate<boolean>(this.courseDetailInfo?.courseName, true)
        }
      }
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({ top: this.getUIContext().px2vp(this.screenPropStorage.topRectHeight),
      bottom: this.getUIContext().px2vp(this.screenPropStorage.bottomRectHeight) })

  }
}

function copyText(text: string) {
  const uiContext: UIContext | undefined = AppStorage.get('context');
  // Create clipboard content object
  try {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    // Get system clipboard object
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // Put data into clipboard
    systemPasteboard.getData().then((data) => { // Read clipboard content
      if (data) {
        uiContext?.getPromptAction().showToast({ message: '复制成功' });
      } else {
        uiContext?.getPromptAction().showToast({ message: '复制失败' });
      }
    })
  } catch (e) {
    Logger.error(TAG, `Failed to createData. error: ${JSON.stringify(e)}`)
  }
}