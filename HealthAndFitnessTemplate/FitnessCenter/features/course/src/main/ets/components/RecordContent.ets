import {
  BookingInfo,
  BookingRecordInfo,
  BookState,
  CardInfo,
  ConsumeType,
  CourseBookingInfo,
  CourseDetailModel,
  DateUtil,
  MockService,
  UserCard,
  getCalendarPermission,
  UserCourse,
  BreakpointNameEnum,
  BreakpointModel,
  BookingRestQuotaUpdate,
  AccountUpdate,
  EmitterConstant,
  GridSettingInfo,
  CardManager,
  Logger
} from 'external_interactions';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError, emitter} from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { SystemSceneUtils } from '../utils/SystemSceneUtils';
import { serviceNotification } from '@kit.PushKit';
import { common } from '@kit.AbilityKit';

const TAG: string = '[RecordContent]';

@ComponentV2
export struct RecordContent {
  @Param bookState: BookState = 0
  @Local bookRecordList: BookingRecordInfo[] = []
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Param currentTabIndex: number = 0
  @Param index: number = 0
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate;
  @Local updateUI: boolean = false
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.bookRecordList = MockService.getBookingListByState(this.bookState)
    SystemSceneUtils.init(this.getUIContext());
  }

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 12,
      rowGap: 12,
    }
    if ([BreakpointNameEnum.MD].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 16
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr 1fr'
      gridSettingInfo.colGap = 16
    }
    return gridSettingInfo
  }

  build() {
    Column() {
      Column() {
        Image($r('app.media.no_result'))
          .width(144)
          .height(144)
          .margin({ bottom: 12 })
        Text('未查询到预约记录')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor('#999999')
      }
      .height('50%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .visibility(this.bookRecordList.length > 0 ? Visibility.None : Visibility.Visible)

      WaterFlow() {
        ForEach(this.bookRecordList, (item: BookingRecordInfo) => {
            RecordItem({ bookingRecordInfo: item, pathStack: this.pathStack , handleCancel: ()=>{
              this.bookRecordList = MockService.getBookingListByState(this.bookState)
            }})
        }, (item: BookState) => JSON.stringify(item))
      }
      .columnsTemplate(this.gridSetting.template)
      .columnsGap(this.gridSetting.colGap)
      .rowsGap(this.gridSetting.rowGap)
      .margin({ left: 16, right: 16 })
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .margin({ top: 16 })
  }
  @Monitor('currentTabIndex', 'accountUpdateStorage.accountUpdate')
  tabIndexChange() {
    if (this.index === this.currentTabIndex) {
      this.bookRecordList = MockService.getBookingListByState(this.bookState)
    }
  }
}

@ComponentV2
struct RecordItem {
  @Param bookingRecordInfo: BookingRecordInfo = {} as BookingRecordInfo;
  @Local courseBookingInfo?: CourseBookingInfo = undefined;
  @Local courseDetailInfo?: CourseDetailModel = undefined;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local bookingRestQuotaUpdateStorage : BookingRestQuotaUpdate = AppStorageV2.connect(BookingRestQuotaUpdate, 'BookingRestQuotaUpdate', () =>new BookingRestQuotaUpdate())!
  @Local bookingRestQuotaUpdate: boolean = this.bookingRestQuotaUpdateStorage.bookingRestQuotaUpdate
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate;
  @Local updateUI:boolean = false
  @Event handleCancel : () => void
  @Local entityIds: string = 'xxx';// todo 推送服务通知模板ID
  @Local calendarMgr: calendarManager.CalendarManager | null = null;

  aboutToAppear(): void {
    this.courseBookingInfo = MockService.getCourseBookingById(this.bookingRecordInfo.courseBookingId)
    this.courseDetailInfo = MockService.getCourseById(this.courseBookingInfo.courseId)
  }

  addCalendarEvent() {
    let calendarMgr: calendarManager.CalendarManager =
      calendarManager.getCalendarManager(this.getUIContext().getHostContext());
    const event: calendarManager.Event = {
      title: this.courseDetailInfo?.courseName,
      reminderTime: [2 * 60, 60, 30, 10],
      type: calendarManager.EventType.NORMAL,
      startTime: DateUtil.parseDateString(this.courseBookingInfo?.date + ' ' +
      this.courseBookingInfo?.timeStart).getTime(),
      endTime: DateUtil.parseDateString(this.courseBookingInfo?.date + ' ' +
      this.courseBookingInfo?.timeEnd).getTime(),
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

  onSubscribeClick: () => void = async () => {
    const resp = await SystemSceneUtils.requestSubscribeNotification(this.entityIds);
    if (resp && resp?.entityResult?.length &&
      resp.entityResult[0]?.resultCode === serviceNotification.ResultCode.ACCEPTED) {
    }
  };

  build() {
    Column() {
      Row() {
        Text('预约时间: ' + DateUtil.formatDate(DateUtil.parseDateString(this.bookingRecordInfo.bookingDate), '.') + ' ' + this.courseBookingInfo?.timeStart + '-' +
          this.courseBookingInfo?.timeEnd)
          .fontSize(14)
        Row() {
          Text(MockService.getBookStateString(this.bookingRecordInfo.bookState))
            .fontSize(14)
            .fontColor(this.getBookingStateColor())
        }
      }.justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(18)

      Divider()
        .margin({ top: 12, bottom: 12 })

      Row() {
        Image($r(this.courseDetailInfo?.advImage))
          .width(80)
          .height(80)
          .borderRadius(8)
        Column() {
          Row() {
            Text(this.courseDetailInfo?.courseName)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
            Text('¥' + this.courseDetailInfo?.price)
              .fontSize(14)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text(this.getBookingInstruction())
              .fontSize(14)
              .width('70%')
            Text('x' + this.bookingRecordInfo.personNum)
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

      Column() {
        Divider()
          .margin({ top: 12, bottom: 12 })
        Row() {
          Text('取消预约')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.getUIContext().showAlertDialog({
                message: '是否确认取消预约',
                textStyle: {
                  fontColor: $r('sys.float.Body_L'),
                  fontWeight: FontWeight.Regular
                },
                autoCancel: false,
                width: 328,
                height: 146,
                primaryButton: {
                  value: '取消',
                  fontColor: $r('sys.color.font_secondary'),
                  action: () => {}
                },
                secondaryButton: {
                  value: '确认取消',
                  action: () => {
                    this.bookingRecordInfo.bookState = BookState.CANCELED;
                    this.bookingRestQuotaUpdate = !this.bookingRestQuotaUpdate
                    if (!this.bookingRecordInfo.userCardId) {
                      AppStorage.setOrCreate<boolean>(this.courseDetailInfo?.id, true)
                    }
                    this.updateMockData()
                    CardManager.get().updateCard()
                    this.accountUpdateStorage.accountUpdate = !this.accountUpdateStorage.accountUpdate
                    try {
                      emitter.emit(EmitterConstant.REFRESH_DATA)
                    } catch (e) {
                      Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                    }
                    try {
                      emitter.emit(EmitterConstant.CANCEL_BOOK)
                    } catch (e) {
                      Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                    }
                  }
                }
              })
            })

          Divider()
            .vertical(true)

          Text('订阅通知')
            .fontColor('#FF9019')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_M'))
            .onClick(() => {
              this.onSubscribeClick()
            })

          Divider()
            .vertical(true)

          Text('添加至日程')
            .fontColor('#FF9019')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_M'))
            .onClick(async () => {
              let permission =
                await getCalendarPermission(this.getUIContext().getHostContext() as common.UIAbilityContext)

              if (permission === 'success') {
                this.calendarMgr =
                  calendarManager.getCalendarManager(this.getUIContext().getHostContext() as common.UIAbilityContext);

                this.addCalendarEvent()
                this.getUIContext().getPromptAction().showToast({ message: '已添加到系统日历' })
              } else {
                this.getUIContext().getPromptAction().showToast({message: '没有日历权限，请去设置页面授权'});
              }
            })
        }
        .height(24)
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
      .visibility(this.bookingRecordInfo.bookState === BookState.TO_BE_USE ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(16)
    .onClick(() => {
      this.pathStack.pushPath({ name: 'course/BookingDetail', param: this.buildBookingInfo() })
    })
  }

  getBookingInstruction(): string {
    switch (this.bookingRecordInfo.bookState) {
      case BookState.TO_BE_USE:
        return '请您按时接受服务，行程有变请提前取消预约'
      case BookState.COMPLETED:
        return '已完成预约课程'
      case BookState.EXPIRED:
        return '您的课程未完成，如有需要请再次预约'
      case BookState.CANCELED:
        return '您的课程未完成，如有需要请再次预约'
      default:
        return ''
    }
  }

  getBookingStateColor(): string {
    switch (this.bookingRecordInfo.bookState) {
      case BookState.TO_BE_USE:
        return '#FF9019'
      case BookState.COMPLETED:
        return '#64BB5C'
      case BookState.EXPIRED:
        return 'rgba(0, 0, 0, 0.4)'
      case BookState.CANCELED:
        return 'rgba(0, 0, 0, 0.4)'
      default:
        return ''
    }
  }

  buildBookingInfo(): BookingInfo {
    let bookingInfo: BookingInfo = {
      courseBookingInfo: this.courseBookingInfo!,
      courseDetail: this.courseDetailInfo!,
      phone: this.bookingRecordInfo.phone,
      name: this.bookingRecordInfo.name,
      personNum: this.bookingRecordInfo.personNum,
      remark: this.bookingRecordInfo.remark,
      bookState: this.bookingRecordInfo.bookState
    }
    return bookingInfo
  }

  updateMockData() {
    let userCourseIndex = MockService.userCourseList.findIndex(
      (item: UserCourse) => item.bookingRecordId === this.bookingRecordInfo.id)
    if (userCourseIndex !== -1) {
      MockService.userCourseList[userCourseIndex].courseState = false
      MockService.userCourseList[userCourseIndex].courseBookingId = ''
      MockService.userCourseList[userCourseIndex].bookingRecordId = ''
      MockService.dataPreferences.putSync('userCourse', JSON.stringify(MockService.userCourseList));
    }
    MockService.getCourseBookingById(this.courseBookingInfo!.id).restQuota += this.bookingRecordInfo.personNum;
    MockService.dataPreferences.putSync('courseBooking', JSON.stringify(MockService.courseBookingList))
    MockService.getBookingRecordById(this.bookingRecordInfo.id).bookState = BookState.CANCELED
    MockService.dataPreferences.putSync('booking', JSON.stringify(MockService.bookingList))
    if (this.bookingRecordInfo.userCardId) {
      let userCard: UserCard = MockService.getUserCardById(this.bookingRecordInfo.userCardId)
      if (userCard) {
        let cardInfo: CardInfo = MockService.getCardById(userCard.cardId)
        if (cardInfo.consumeType === ConsumeType.TIMES) {
          MockService.getUserCardById(this.bookingRecordInfo.userCardId).restQuota += this.bookingRecordInfo.personNum;
          MockService.dataPreferences.putSync('userCard', JSON.stringify(MockService.userCardList))
        }
      }
    }
    this.accountUpdate = !this.accountUpdate
    MockService.dataPreferences.flush()
    this.handleCancel()
  }
}