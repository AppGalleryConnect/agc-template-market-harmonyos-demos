import { BookingRecordInfo,
  CourseBookingInfo,
  DateUtil,
  MockService,
  EmitterConstant,
  CourseDetailModel,
  UserCourse,
  BookJumpSearch,
  BookState,
  UserCard,
  CardInfo,
  ConsumeType,
  BreakpointNameEnum,
  BreakpointModel,
  CardManager,
  Logger} from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

const TAG: string = '[UserCourses]';

@ComponentV2
export struct UserCourses {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  @Local userCourseList: UserCourse[] = []
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  getBookingDate(bookingRecordId: string): string {
    let bookingRecordInfo: BookingRecordInfo = MockService.getBookingRecordById(bookingRecordId)
    return bookingRecordInfo.bookingDate
  }

  getCourseBookingInfo(courseBookingId: string): CourseBookingInfo {
    let courseBookingInfo: CourseBookingInfo = MockService.getCourseBookingById(courseBookingId)
    return courseBookingInfo
  }

  @Monitor('screenPropStorage.topRectHeight', 'screenPropStorage.bottomRectHeight')
  onScreenPropStorage(mon: IMonitor) {
    this.topRectHeight = this.screenPropStorage.topRectHeight;
    this.bottomRectHeight = this.screenPropStorage.bottomRectHeight
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
    NavDestination() {
      Column() {
        TitleBar({ title: '我的课程', onBackClick:()=>{this.pathStack.pop()} })

        Column() {
          Image($r('app.media.no_result'))
            .width(144)
            .height(144)
            .margin({ bottom: 12 })
          Text('未查询到我的课程信息')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor('#999999')
        }
        .height('50%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .visibility(this.userCourseList.length > 0 ? Visibility.None : Visibility.Visible)

        List({ space: 12 }) {
          ForEach(this.userCourseList, (item: UserCourse) => {
              ListItem() {
                CourseItemBuilder({
                  userCourse: item,
                  pathStack: this.pathStack,
                  withdrawUserCourseCallBack: (userCourseId: string) => {
                    const removeUserCourseIndex = this.userCourseList.findIndex(uc => uc.id === userCourseId);
                    this.userCourseList.splice(removeUserCourseIndex, 1)
                  },
                  cancelBookingCallBack: (userCourseId: string) => {
                    const removeUserCourseIndex = this.userCourseList.findIndex(uc => uc.id === userCourseId);
                    this.userCourseList[removeUserCourseIndex].courseState = false
                    this.userCourseList[removeUserCourseIndex].courseBookingId = ''
                    this.userCourseList[removeUserCourseIndex].bookingRecordId = ''
                  }
                })
            }
          }, (item: UserCourse) => JSON.stringify(item))
        }
        .lanes(this.listLanes, 16)
        .margin({ bottom: 28 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .height('100%')
        .layoutWeight(1)
      }.margin({ left: 16, right: 16 })
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
      MockService.userCourseList.forEach((item: UserCourse) => {
        this.userCourseList.push(item)
      })
    })
    .hideTitleBar(true)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}

@ComponentV2
export struct CourseItemBuilder {
  @Local bookJumpSearchStorage : BookJumpSearch = AppStorageV2.connect(BookJumpSearch, 'BookJumpSearch', () =>new BookJumpSearch())!
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  @Local courseDetail?: CourseDetailModel = undefined
  @Local bookingRecordInfo?: BookingRecordInfo = undefined
  @Local courseBookingInfo?: CourseBookingInfo = undefined
  @Param userCourse: UserCourse = {} as UserCourse
  @Local courseState: boolean = false
  @Event withdrawUserCourseCallBack : (userCourseId: string) => void
  @Event cancelBookingCallBack: (userCourseId: string) => void

  aboutToAppear(): void {
    this.courseDetail = MockService.getCourseById(this.userCourse.courseId);
    this.bookingRecordInfo = MockService.getBookingRecordById(this.userCourse.bookingRecordId);
    this.courseBookingInfo = MockService.getCourseBookingById(this.userCourse.courseBookingId);
    this.courseState = this.userCourse.courseState
  }

  build() {
    Row() {
      Image($r(this.courseDetail?.advImage))
        .width(80)
        .height(80)
        .borderRadius(8)
      Column() {
        // 课名、分享、预约标签
        Row() {
          Row() {
            Text(this.courseDetail?.courseName)
              .maxLines(1)
              .alignSelf(ItemAlign.Center)
              .textAlign(TextAlign.Start)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Image($r('app.media.share'))
              .visibility(Visibility.None)
              .width(16)
              .height(16)
              .margin({ left: 8 })
              .accessibilityText('分享')
              .onClick(() => {
                this.getUIContext().getPromptAction().showToast({
                  message: '分享成功',
                  alignment: Alignment.Bottom,
                  offset: { dx: 0, dy: -this.getUIContext().vp2px(80) },
                })
              })
          }
          .width(`calc(100% - 72vp)`)
          Text(this.courseState ? '已预约' : '未预约')
            .alignSelf(ItemAlign.Center)
            .fontSize(14)
            .fontColor(this.courseState ? '#FF9019' : 'rgba(0, 0, 0, 0.4)')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(18)

        // 预约时间
        Row() {
          Text('预约时间: ' +
            DateUtil.formatDate(DateUtil.parseDateString(this.bookingRecordInfo?.bookingDate), '.') +
            ' ' + this.courseBookingInfo?.timeStart + '-' + this.courseBookingInfo?.timeEnd)
            .fontSize(12)
            .visibility(this.courseState ? Visibility.Visible : Visibility.None)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        // 预约、退课按钮
        Row() {
          Button(this.courseState ? '取消预约' : '预约')
            .width(72)
            .controlSize(ControlSize.SMALL)
            .buttonStyle(!this.courseState ? ButtonStyleMode.EMPHASIZED : ButtonStyleMode.NORMAL)
            .onClick(() => {
              if (this.userCourse.courseState) {
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
                      // 取消预约
                      this.userCourse.courseState = false
                      this.userCourse.courseBookingId = ''
                      this.userCourse.bookingRecordId = ''
                      this.courseState = this.userCourse.courseState
                      if (this.bookingRecordInfo) {
                        if (!this.bookingRecordInfo.userCardId) {
                          AppStorage.setOrCreate<boolean>(this.courseDetail?.id, true)
                        }
                      }
                      let userCourseIndex = MockService.userCourseList.findIndex(
                        (item: UserCourse) => item.id === this.userCourse.id)
                      if (userCourseIndex !== -1) {
                        MockService.userCourseList[userCourseIndex] = this.userCourse
                        MockService.dataPreferences.putSync('userCourse', JSON.stringify(MockService.userCourseList));
                      }
                      this.updateMockData()
                      this.cancelBookingCallBack(this.userCourse.id)
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
              } else {
                // 单击预约，清空路由栈，回到Index.ets页，通过全局状态存储，跳到 预约 页
                this.pathStack.clear(false)
                if (this.courseDetail) {
                  try {
                    emitter.emit(EmitterConstant.CLICK_BOOK_DETAIL)
                  } catch (e) {
                    Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                  }
                  this.bookJumpSearchStorage.bookJumpSearch = this.courseDetail.courseName
                }
              }
            })
          Blank().width(10)
          Button('退课')
            .width(72)
            .controlSize(ControlSize.SMALL)
            .buttonStyle(ButtonStyleMode.NORMAL)
            .role(ButtonRole.ERROR)
            .onClick(() => {
              this.getUIContext().showAlertDialog({
                message: '是否确认退课，确认将取消预约，退课后余额返还余额退回付款账户',
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
                  value: '确认退课',
                  action: () => {
                    // 先取消预约再退课
                    if (this.bookingRecordInfo) {
                      this.bookingRecordInfo.bookState = BookState.CANCELED;
                      if (!this.bookingRecordInfo.userCardId) {
                        AppStorage.setOrCreate<boolean>(this.courseDetail?.id, false)
                      }
                    }
                    this.updateMockData()
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
                    // 退课
                    MockService.removeUserCourse(this.userCourse.id)
                    this.withdrawUserCourseCallBack(this.userCourse.id)
                  }
                }
              })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
      .height(80)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(16)
    .onClick(() => {
      this.pathStack.pushPath({ name: 'course/CourseDetail', param: this.courseDetail })
    })
  }

  updateMockData() {
    if (this.bookingRecordInfo) {
      MockService.getCourseBookingById(this.courseBookingInfo!.id).restQuota += this.bookingRecordInfo.personNum;
      MockService.dataPreferences.putSync('courseBooking', JSON.stringify(MockService.courseBookingList))
      MockService.getBookingRecordById(this.bookingRecordInfo.id).bookState = BookState.CANCELED
      MockService.dataPreferences.putSync('booking', JSON.stringify(MockService.bookingList))
    }
    MockService.dataPreferences.flush()
    CardManager.get().updateCard()
  }
}