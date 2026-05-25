import { calendarManager } from '@kit.CalendarKit';
import { BusinessError, emitter} from '@kit.BasicServicesKit';
import { BookJumpSearch, EmitterConstant, Logger } from 'external_interactions'
import {
  BookingInfo,
  BookState,
  CardInfo,
  ConsumeType,
  DateUtil,
  MockService,
  OrderState,
  OrderType,
  UserCard
} from 'external_interactions';
import { CustomContentDialog, promptAction } from '@kit.ArkUI';
import { RechargeRouteParam } from 'module_recharge';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage , BookingRestQuotaUpdate, AccountUpdate, GlobalBalance, ClearPath} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
import  EventData  from '@ohos.events.emitter';

const TAG: string = '[ConfirmBooking]';

@ComponentV2
export struct ConfirmBooking {
  @Param @Once bookingInfo: BookingInfo = {} as BookingInfo;
  @Param @Once  pathStack: NavPathStack = new NavPathStack();
  @Local bookingRestQuotaUpdateStorage : BookingRestQuotaUpdate = AppStorageV2.connect(BookingRestQuotaUpdate, 'BookingRestQuotaUpdate', () =>new BookingRestQuotaUpdate())!
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local globalBalanceStorage : GlobalBalance = AppStorageV2.connect(GlobalBalance, 'GlobalBalance', () =>new GlobalBalance())!
  @Local clearPathStorage : ClearPath = AppStorageV2.connect(ClearPath, 'ClearPath', () =>new ClearPath())!

  bookingDate: Date = new Date()
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local bookJumpSearchStorage : BookJumpSearch = AppStorageV2.connect(BookJumpSearch, 'BookJumpSearch', () =>new BookJumpSearch())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Local needPayMoney: number = 0;
  @Local pickerIndex: number = 0;
  @Local selectIndex: number = 0;
  @Local pickerArray: string[] = []
  cardArray: UserCard[] = []
  @Local canPay: boolean = true;
  @Local costString: string = ''
  @Local toast: string = ''
  @Local bookingRestQuotaUpdate: boolean = this.bookingRestQuotaUpdateStorage.bookingRestQuotaUpdate
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '请选择预约方式',
      contentBuilder: () => {
        this.buildPicker();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          },
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.pickerIndex = this.selectIndex
            this.updateChoose()
          },
        },
      ],
    }),
    backgroundColor: Color.White,
  });

  @Builder
  rowBuilder(key: string, value: string): void {
    Row() {
      Text(key)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.End)
        .opacity(0.6)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildPicker() {
    List({ space: 16 }) {
      ForEach(this.pickerArray, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(item)
            Image($r('app.media.checkmark'))
              .height(24)
              .width(24)
              .fillColor(Color.Red)
              .visibility(this.selectIndex === index ? Visibility.Visible : Visibility.Hidden)
          }
          .enabled(this.getEnable(index))
          .opacity(this.getEnable(index) ? 1 : 0.3)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.selectIndex = index
          })
        }
      }, (item: string) => item)
    }
  }

  getEnable(index: number): boolean {
    if (index === this.pickerArray.length - 1) {
      return true;
    } else {
      let cardInfo: CardInfo = MockService.getCardById(this.cardArray[index].cardId);
      let item = this.cardArray[index]
      if (cardInfo.consumeType === ConsumeType.TIMES) {
        return item.restQuota >= this.bookingInfo.personNum
      } else {
        let now = new Date()
        return now.getTime() <=
        DateUtil.parseDateString(DateUtil.formatDate(MockService.getCardExpireDate(item), '-')).getTime()
      }
    }
  }

  refreshPage(): void {
    this.pickerArray = []
    this.cardArray = []
    this.getMemberMoney();
    this.buildPickerArray()
    this.updateChoose()
  }
  build() {
    NavDestination() {
      TitleBar({ title: '确认预约', onBackClick:()=>{ this.pathStack.pop()} })
        .margin({ left: 16, right: 16 })
      Stack() {
        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 16 }) {
              Text('预约信息')
                .textAlign(TextAlign.Start)
                .fontSize(14)
                .width('100%')
                .fontWeight(FontWeight.Bold)
              this.rowBuilder('预约课程', this.bookingInfo.courseDetail.courseName)
              Divider()
                .margin({ top: 8, bottom: 8 })
              this.rowBuilder('预约门店', AppStorage.get('currentStore') ?? '全市门店')
              this.rowBuilder('预约时间', DateUtil.formatDate(this.bookingDate, '.', 'short') +
                ' ' + this.bookingInfo.courseBookingInfo.timeStart + '~' +
              this.bookingInfo.courseBookingInfo.timeEnd)
              this.rowBuilder('预约人', this.bookingInfo.name)
              this.rowBuilder('预约人数', this.bookingInfo.personNum.toString())
              this.rowBuilder('手机号码', this.bookingInfo.phone)
              this.rowBuilder('备注',
                (this.bookingInfo.remark === undefined || this.bookingInfo.remark.length === 0) ? '无' :
                this.bookingInfo.remark)
            }
            .width('100%')
            .padding(16)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_list_card'))

            // 订单金额
            Column({ space: 16 }) {
              Text('订单金额')
                .textAlign(TextAlign.Start)
                .fontSize(14)
                .width('100%')
                .fontWeight(FontWeight.Bold)
              Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
                Text('合计（总价）')
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                Text('¥' + this.bookingInfo.personNum * this.bookingInfo.courseDetail.price)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .opacity(0.6)
              }

              Divider()
                .margin({ top: 8, bottom: 8 })

              Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
                Text(this.bookJumpSearchStorage.bookJumpSearch ? this.pickerArray[AppStorage.get('selectedCardIndex') as number] : this.pickerArray[this.pickerIndex])
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                Row() {
                  Text(this.costString)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .opacity(0.6)
                  Image($r('app.media.chevron_right'))
                    .width(13)
                    .height(13)
                    .fillColor(Color.Gray)
                    .visibility(this.pickerArray.length > 1 ? Visibility.Visible : Visibility.None)
                }
              }
              .onClick(() => {
                this.dialogController.open()
              })
            }
            .padding(16)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_list_card'))
          }
          .width('100%')
        }
        .margin({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .alignContent(Alignment.Top)
      Row() {
        Text(this.toast)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width('40%')
          .height('60%')
          .textAlign(TextAlign.Start)
          .margin({ left: 16 })
        Button(this.canPay ? '确认预约' : '前往充值', { type: ButtonType.Capsule, stateEffect: true })
          .width('50%')
          .height('60%')
          .fontColor($r('sys.color.comp_background_list_card'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .backgroundColor('#FF9019')
          .borderRadius(8)
          .onClick(() => {
            if (this.canPay) {
              if (this.bookingInfo.courseBookingInfo.restQuota < this.bookingInfo.personNum) {
                this.getUIContext().getPromptAction().showToast({message: '课程余量不足'})
              } else {
                AppStorage.setOrCreate('clearPath', true)
                this.clearPathStorage.clearPath = true
                this.bookingRestQuotaUpdate = !this.bookingRestQuotaUpdate
                this.bookingInfo.bookState = BookState.TO_BE_USE
                this.accountUpdate = !this.accountUpdate
                let data: EventData.EventData = {
                  data: {
                    'quota' : this.bookingInfo.courseBookingInfo.restQuota - this.bookingInfo.personNum
                  }
                } as EventData.EventData
                try {
                  emitter.emit(EmitterConstant.CONFIRM_DATA, data)
                } catch (e) {
                  Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                }
                this.pathStack.pushPath({ name: 'course/BookingDetail', param: this.bookingInfo})
                this.updateMockData()
                this.refreshPage()
              }
            } else {
              this.pathStack.pushPath({ name: 'vip/VipRecharge' , param:{
                balance: MockService.account.balance,
                handleBack:(balance: number)=>{
                  MockService.account.balance = balance
                  MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account));
                  MockService.dataPreferences.flush()
                  AppStorage.set('globalBalance', balance)
                  this.refreshPage()
                }
              } as RechargeRouteParam })
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .height(75)
      .width('100%')
      .padding({ bottom: 10 })
      .backgroundColor(Color.White)
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack;
      this.bookingInfo = ctx?.pathInfo?.param as BookingInfo;
      this.bookingDate = DateUtil.parseDateString(this.bookingInfo.courseBookingInfo.date)
      this.refreshPage()
      this.pickerIndex = AppStorage.get('selectedCardIndex') ?? 0
      this.updateChoose()
    })
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.main_background_color'))
  }
  getMemberMoney() {
    this.globalBalanceStorage.globalBalance = MockService.account.balance;
  }
  @Monitor('accountUpdateStorage.accountUpdate')
  updateAccount() {
    this.getMemberMoney()
    this.pickerArray[this.pickerArray.length-1] = '会员卡（剩余¥' + this.globalBalanceStorage.globalBalance + '）'
    this.updateChoose()
  }

  addCalendarEvent() {
    let calendarMgr: calendarManager.CalendarManager =
      calendarManager.getCalendarManager(this.getUIContext().getHostContext());
    const event: calendarManager.Event = {
      title: this.bookingInfo.courseDetail.courseName,
      reminderTime: [2 * 60, 60, 30, 10],
      type: calendarManager.EventType.NORMAL,
      startTime: DateUtil.parseDateString(this.bookingInfo.courseBookingInfo.date + ' ' +
      this.bookingInfo.courseBookingInfo.timeStart).getTime(),
      endTime: DateUtil.parseDateString(this.bookingInfo.courseBookingInfo.date + ' ' +
      this.bookingInfo.courseBookingInfo.timeEnd).getTime(),
    };
    calendarMgr?.getCalendar().then((data: calendarManager.Calendar) => {
      Logger.info(TAG, `Succeeded in getting calendar, data -> ${JSON.stringify(data)}`);
      data.addEvent(event).then((data: number) => {
        Logger.info(TAG, `Succeeded in adding event, id -> ${JSON.stringify(data)}`);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
      });
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
    });
  }

  buildPickerArray() {
    MockService.userCardList.forEach((item: UserCard) => {
      if (this.bookingInfo.courseDetail.avaiCard.includes(item.cardId) && MockService.userCardCanUse(item)) {
        let cardInfo: CardInfo = MockService.getCardById(item.cardId)
        let picker = cardInfo.name;
        picker += cardInfo.consumeType === ConsumeType.TIMES ? '（剩余' + item.restQuota + '次）' : '（不限次）'
        this.pickerArray.push(picker)
        this.cardArray.push(item)
      }
    })

    this.pickerArray.push('会员卡（剩余¥' + MockService.account.balance + '）')
    let flag: boolean = false;
    for (let i = 0; i < this.cardArray.length; i++) {
      let item = this.cardArray[i]
      let cardInfo: CardInfo = MockService.getCardById(item.cardId)
      if (cardInfo.consumeType === ConsumeType.TIMES) {
        if (item.restQuota >= this.bookingInfo.personNum) {
          this.pickerIndex = i;
          flag = true;
          break;
        }
      } else {
        let now = new Date()
        if (now.getTime() <=
        DateUtil.parseDateString(DateUtil.formatDate(MockService.getCardExpireDate(item), '-')).getTime()) {
          this.pickerIndex = i;
          flag = true;
          break;
        }
      }
    }
    if (!flag) {
      this.pickerIndex = this.pickerArray.length - 1;
    }
    this.selectIndex = this.pickerIndex
  }

  getCost(): number {
    if (this.pickerIndex === this.pickerArray.length - 1) {
      return this.bookingInfo.personNum * this.bookingInfo.courseDetail.price
    } else {
      return this.bookingInfo.personNum
    }
  }

  updateChoose() {
    this.needPayMoney = this.getCost();
    if (this.pickerArray.length > 1 && this.pickerIndex !== this.pickerArray.length - 1) {
      this.canPay = true
    } else {
      this.canPay = this.globalBalanceStorage.globalBalance >= this.needPayMoney
    }
    if (this.canPay) {
      if (this.pickerIndex === this.pickerArray.length - 1) {
        this.toast = '需支付：' + this.needPayMoney + '元'
        this.costString = '-' + this.needPayMoney
      } else {
        if (MockService.getCardById(this.cardArray[this.pickerIndex].cardId).consumeType === ConsumeType.TIMES) {
          this.toast = '需消耗：' + this.needPayMoney + '次'
          this.costString = '-' + this.needPayMoney
        } else {
          this.toast =
            '到期时间:' + DateUtil.formatDate(MockService.getCardExpireDate(this.cardArray[this.pickerIndex]))
          this.costString = ''
        }
      }
    } else {
      this.toast = '余额不足'
      this.costString = '-' + this.needPayMoney
    }
  }

  updateMockData() {
    let userCardId: string | undefined = undefined
    if (this.pickerIndex === this.pickerArray.length - 1) {
      let bookingInfo = MockService.createBookingRecord(this.bookingInfo.courseBookingInfo.id, BookState.TO_BE_USE,
        this.bookingInfo.phone, this.bookingInfo.name, this.bookingInfo.personNum, this.bookingInfo.remark,
        this.bookingInfo.courseBookingInfo.date, userCardId)
      MockService.createOrder(OrderType.COURSE, OrderState.COMPLETED, this.bookingInfo.personNum,
        this.bookingInfo.courseDetail.price, undefined, bookingInfo.id)
      MockService.account.balance -= this.needPayMoney;
      MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account))
    } else {
      let cardInfo = MockService.getCardById(this.cardArray[this.pickerIndex].cardId)
      if (cardInfo.consumeType === ConsumeType.TIMES) {
        let userCard = MockService.getUserCardById(this.cardArray[this.pickerIndex].id)
        MockService.userCardMap.set(userCard.id, userCard)
        this.cardArray[this.pickerIndex].restQuota -= this.bookingInfo.personNum
        MockService.dataPreferences.putSync('userCard', JSON.stringify(MockService.userCardList))
      }
      MockService.createBookingRecord(this.bookingInfo.courseBookingInfo.id, BookState.TO_BE_USE,
        this.bookingInfo.phone, this.bookingInfo.name, this.bookingInfo.personNum, this.bookingInfo.remark,
        this.bookingInfo.courseBookingInfo.date, this.cardArray[this.pickerIndex].id)
    }
    MockService.getCourseBookingById(this.bookingInfo.courseBookingInfo.id).restQuota -= this.bookingInfo.personNum;
    MockService.dataPreferences.putSync('courseBooking', JSON.stringify(MockService.courseBookingList))
    MockService.dataPreferences.flush()
  }
}
