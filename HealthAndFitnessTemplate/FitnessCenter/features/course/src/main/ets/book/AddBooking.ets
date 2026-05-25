import { BookingInfo,
  BookingRestQuotaUpdate,
  BookState,
  CardInfo,
  ClearPath,
  ConsumeType,
  CourseBookingInfo, CourseDetailModel, DateUtil,
  EmitterConstant,
  MockService,
  OrderState,
  OrderType,
  UserCard,
  UserCourse,
  BreakpointNameEnum,
  BreakpointModel,
  GridSettingInfo,
  ScreenPropStorage,
  AccountUpdate,
  CardManager,
  Logger} from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { AppStorageV2, UIContext, KeyboardAvoidMode } from '@kit.ArkUI';
import  EventData  from '@ohos.events.emitter';
import emitter from '@ohos.events.emitter';

const TAG: string = 'AddBooking';

@ComponentV2
export struct AddBooking {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local clearPathStorage : ClearPath = AppStorageV2.connect(ClearPath, 'ClearPath', () =>new ClearPath())!

  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;

  @Param @Once courseBookingInfo: CourseBookingInfo | undefined = undefined;
  courseDetail?: CourseDetailModel = undefined
  bookingDate: Date = new Date()
  @Local phone: string = ''
  @Local name: string = ''
  @Local personNum: number = 1
  @Local remark: string = ''
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  remarkMaxCount: number = 50;
  @Local remarkInputCount: number = 0;
  @Local totalPrice: number = 0;
  @Local userCardList: UserCard[] = []
  @Local selectedCardId: string = '';
  @Local selectedCard: CardInfo = new CardInfo('', 0, '', '', '', '', [], '', '', 1, 0, 0, 0 )
  @Local selectedCardIndex: number = -1;
  @Local bookingRestQuotaUpdateStorage : BookingRestQuotaUpdate = AppStorageV2.connect(BookingRestQuotaUpdate, 'BookingRestQuotaUpdate', () =>new BookingRestQuotaUpdate())!
  @Local bookingRestQuotaUpdate: boolean = this.bookingRestQuotaUpdateStorage.bookingRestQuotaUpdate
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private uiContext: UIContext = this.getUIContext();
  private cacheKeyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.OFFSET;

  public aboutToAppear(): void {
    this.cacheKeyboardAvoidMode = this.uiContext.getKeyboardAvoidMode();
  }

  isMDorLGorXL() {
    return [BreakpointNameEnum.MD, BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(
      this.breakPointModel.currentBreakpoint)
  }

  isLGorXL() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))
  }

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 12,
      rowGap: 16,
    }
    if (this.isLGorXL()) {
      gridSettingInfo.template = '1fr 1fr'
    }
    return gridSettingInfo
  }

  @Builder
  courseInfoBuilder() {
    Column() {
      Image($r(this.courseDetail?.advImage))
        .width('100%')
        .height(this.isMDorLGorXL() ? 248 : 132)
        .margin({ top: this.isLGorXL() ? 110 : 0, bottom: this.isLGorXL() ? 110 : 12 })
        .borderRadius(12)
      Column() {
        Text(this.courseDetail?.courseName)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .justifyContent(FlexAlign.End)
    .padding({ left: 12, right: 12, top: 16, bottom: 16 })
    .width('100%')
    .borderRadius(20)
    .backgroundColor(Color.White)
  }

  @Builder
  bookingTimeBuilder() {
    Column() {
      Row() {
        Text('预约门店')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
        Text(AppStorage.get('currentStore') ?? '全市门店')
          .fontWeight(500)
          .fontSize(14)
      }
      .margin({ bottom: 12 })
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(21)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          Text('预约时间')
            .fontWeight(FontWeight.Bold)
            .fontSize(16)
        }
        .height('100%')

        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.SpaceBetween,
          alignItems: ItemAlign.End
        }) {
          if(this.courseBookingInfo){
            Text(this.courseBookingInfo.timeStart + '-' + this.courseBookingInfo.timeEnd)
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor('#FF9019')
            Text(DateUtil.formatDate(this.bookingDate, '.', 'long'))
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor('#666666')
          }
        }
        .height('100%')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(39)
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding(16)
  }

  @Builder
  bookingPersonInfo() {
    Row() {
      Column() {
        Text('预约人信息')
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .width('100%')
          .fontWeight(FontWeight.Bold)
        Row() {
          Text('手机号码')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .width('20%')
            .textAlign(TextAlign.Start)
          TextInput({ placeholder: '(必填)', text: this.phone })
            .type(InputType.Number)
            .placeholderFont({ size: $r('sys.float.Body_S'), weight: FontWeight.Regular })
            .placeholderColor($r('sys.color.font_tertiary'))
            .width('60%')
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .borderRadius(0)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onChange((value) => {
              this.phone = value;
            })
          Text('一键填写')
            .fontSize(12)
            .width('18%')
            .textAlign(TextAlign.End)
            .fontColor('#FF9019')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 5 })
            .onClick(() => {
              this.getUserInfo()
            })
        }
        .width('100%')

        Divider()

        Row() {
          Text('姓名')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .width('20%')
            .textAlign(TextAlign.Start)
          TextInput({ placeholder: '(必填)', text: this.name })
            .placeholderFont({ size: $r('sys.float.Body_S'), weight: FontWeight.Regular })
            .placeholderColor($r('sys.color.font_tertiary'))
            .width('80%')
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .borderRadius(0)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onChange((value) => {
              this.name = value;
            })
        }
        .width('100%')

        Divider()
        Row() {
          Text('预约人数')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .width('20%')
            .textAlign(TextAlign.Start)
          Row({ space: 8 }) {
            Image($r('app.media.minus'))
              .borderRadius(800)
              .backgroundColor($r('app.color.main_background_color'))
              .height(32)
              .width(32)
              .padding(4)
              .onClick(() => {
                if (this.personNum > 1) {
                  this.personNum--;
                  this.totalPrice = this.personNum * this.courseDetail!.price;
                }
              })
            Text(this.personNum.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .width(40)
              .height('100%')
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .textAlign(TextAlign.Center)
            Image($r('app.media.plus'))
              .borderRadius(800)
              .height(32)
              .width(32)
              .padding(4)
              .backgroundColor($r('app.color.main_background_color'))
              .onClick(() => {
                if (this.courseBookingInfo && this.personNum >= this.courseBookingInfo.restQuota) {
                  this.getUIContext().getPromptAction().showToast({ message: '课程空余数量不足' })
                } else {
                  this.personNum++;
                  this.totalPrice = this.personNum * this.courseDetail!.price;
                }
              })
          }
          .width('40%')
          .height('100%')
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .height(32)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .margin({ top: 10 })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(164)
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding(16)
  }

  @Builder
  cardListInfo() {
    ForEach(this.userCardList, (userCard: UserCard, index: number) => {
      this.cardBuilder(userCard, MockService.getCardById(userCard.cardId), index)
    }, (item: CardInfo) => JSON.stringify(item))
  }

  @Builder
  cardBuilder(userCard: UserCard, card: CardInfo, index: number) {
    Row() {
      // 添加单选框组件
      Checkbox({ name: card?.id })
        .select(this.selectedCardId === card?.id)
        .onChange((checked: boolean) => {
          if (checked) {
            this.selectedCardId = card?.id; // 更新选中状态
            this.selectedCard = JSON.parse(JSON.stringify(card))
            this.selectedCardIndex = index;
          } else {
            if (this.selectedCardId === card?.id) {
              this.selectedCardId = '';
              if (this.courseDetail) {
                this.selectedCard.id = ''
                this.selectedCard.price = this.courseDetail?.price as number
                this.selectedCard.advImage = this.courseDetail?.advImage as string
                this.selectedCard.name = this.courseDetail?.courseName as string
                this.selectedCard.avaiCourse = this.courseDetail?.id as string
              }
            }
          }
        })
        .margin({ right: 12 })

      Row() {
        Image($r(card.advImage))
          .width(80)
          .height(80)
          .borderRadius(8)
        Column() {
          Text(card.name)
            .textAlign(TextAlign.Start)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
          Row() {
            Text(card.consumeType === ConsumeType.TIMES ? card.quota + '次' :
              MockService.getQuotaDurationDesc(card.quota) + '卡')
              .textAlign(TextAlign.Start)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
            Text() {
              Span(card.consumeType === ConsumeType.TIMES ? '剩余次数: ' : '到期时间: ')
              Span(card.consumeType === ConsumeType.TIMES ? userCard.restQuota.toString() :
                DateUtil.formatDate(MockService.getCardExpireDate(userCard)))
                .fontColor('#FF9019')
            }
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .height('100%')
      }
      .layoutWeight(1)
      .width('90%')
      .padding({ left: 12, right: 12, top: 16, bottom: 16 })
      .borderRadius(20)
      .backgroundColor(Color.White)
      .onClick(() => {
        this.jumpToCard(card)
      })
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height(112)
  }

  @Builder
  remarkBuilder() {
    Row() {
      Column() {
        Row() {
          Text('备注')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
          Text(this.remarkInputCount + '/' + this.remarkMaxCount)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .opacity(0.9)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        TextArea({ text: this.remark, placeholder: '选填，请输入您的其他要求' })
          .fontSize(12)
          .padding(0)
          .placeholderFont({ size: 12 })
          .placeholderColor('#999999')
          .maxLength(this.remarkMaxCount)
          .width('100%')
          .height(80)
          .borderRadius(0)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onChange((value) => {
            this.remark = value
            this.remarkInputCount = value.length
          })
          .margin({ top: 12 })
      }
      .width('100%')
      .height(74)
    }
    .clip(true)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding(16)
  }

  build() {
    NavDestination() {
      TitleBar({ title: '新增预约', onBackClick:()=>{this.pathStack.pop()} })
        .margin({ left: 16, right: 16 })

      Scroll() {
        Column({ space: 16 }) {
          Grid() {
            GridItem() {
              // 课程
              this.courseInfoBuilder()
            }
            GridItem() {
              Column({ space: 12 }) {
                // 预约时间
                this.bookingTimeBuilder()

                // 预约人信息
                this.bookingPersonInfo()

                // 卡项信息
                this.cardListInfo()

                // 备注
                this.remarkBuilder()
              }
            }
          }
          .columnsTemplate(this.gridSetting.template)
          .columnsGap(this.gridSetting.colGap)
          .rowsGap(this.gridSetting.rowGap)
        }
        .margin({ left: 16, right: 16, bottom: 16 })
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)

      // 下方咨询和跳转预约
      Row() {
        Button('提交预约', { type: ButtonType.Capsule, stateEffect: true })
          .width('75%')
          .height('60%')
          .fontColor($r('sys.color.comp_background_list_card'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .backgroundColor('#FF9019')
          .borderRadius(8)
          .onClick(() => {
            if (this.name === '' || this.name === undefined || this.phone === '' || this.phone === undefined) {
              this.getUIContext().getPromptAction().showToast({ message: '请完善预约人信息' })
              return;
            }
            if (this.selectedCard.id === '' && !AppStorage.get(this.courseDetail?.id)) {
              this.getUIContext().getPromptAction().showToast({ message: '请选择预约卡项' })
              return;
            }
            if (this.selectedCard.id === '' && this.personNum > 1 && AppStorage.get(this.courseDetail?.id)) {
              this.getUIContext().getPromptAction().showToast({ message: '请购买卡项或选择预约卡项' })
              return;
            }
            if(this.courseBookingInfo){
              let bookingInfo: BookingInfo = {
                courseBookingInfo: this.courseBookingInfo,
                courseDetail: this.courseDetail!,
                phone: this.phone,
                name: this.name,
                personNum: this.personNum,
                remark: this.remark,
              }
              AppStorage.setOrCreate<number>('selectedCardIndex', this.selectedCardIndex)
              AppStorage.setOrCreate('clearPath', true)
              this.clearPathStorage.clearPath = true
              this.bookingRestQuotaUpdate = !this.bookingRestQuotaUpdate
              bookingInfo.bookState = BookState.TO_BE_USE
              this.accountUpdate = !this.accountUpdate
              let data: EventData.EventData = {
                data: {
                  'quota' : bookingInfo.courseBookingInfo.restQuota - bookingInfo.personNum,
                  'date' : bookingInfo.courseBookingInfo.date,
                  'id' : bookingInfo.courseBookingInfo.courseId
                }
              } as EventData.EventData
              try {
                emitter.emit(EmitterConstant.CONFIRM_DATA, data)
              } catch (e) {
                Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
              }
              if (this.selectedCard.id !== '') {
                this.updateMockData(bookingInfo)
              } else {
                // 未选择卡项，使用已购买的单次课程
                let bookingRecord = MockService.createBookingRecord(bookingInfo.courseBookingInfo.id,
                  BookState.TO_BE_USE, bookingInfo.phone, bookingInfo.name, bookingInfo.personNum, bookingInfo.remark,
                  bookingInfo.courseBookingInfo.date)
                MockService.getCourseBookingById(bookingInfo.courseBookingInfo.id).restQuota -= bookingInfo.personNum;
                let userCourseIndex = MockService.userCourseList.findIndex(
                  (item: UserCourse) => item.courseId === this.courseDetail?.id && !item.courseState)
                if (userCourseIndex !== -1) {
                  MockService.userCourseList[userCourseIndex].courseState = true
                  MockService.userCourseList[userCourseIndex].courseBookingId = bookingInfo.courseBookingInfo.id
                  MockService.userCourseList[userCourseIndex].bookingRecordId = bookingRecord.id
                  MockService.dataPreferences.putSync('userCourse', JSON.stringify(MockService.userCourseList));
                }
                // 查看是否还存在已购买未预约的单次课程
                if (MockService.userCourseList.findIndex(
                  (item: UserCourse) => item.courseId === this.courseDetail?.id && !item.courseState) === -1) {
                  AppStorage.setOrCreate<boolean>(this.courseDetail?.id, false)
                }
                MockService.dataPreferences.putSync('courseBooking', JSON.stringify(MockService.courseBookingList))
                MockService.dataPreferences.flush()
              }
              CardManager.get().updateCard()
              this.pathStack.pushPath({ name: 'course/BookingDetail', param: bookingInfo })
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
    .onShown(() => this.uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE))
    .onWillDisappear(() => this.uiContext.setKeyboardAvoidMode(this.cacheKeyboardAvoidMode))
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      this.courseBookingInfo = ctx?.pathInfo?.param as CourseBookingInfo;
      this.courseDetail = MockService.getCourseById(this.courseBookingInfo.courseId)
      this.bookingDate = DateUtil.parseDateString(this.courseBookingInfo.date)
      this.totalPrice = this.courseDetail.price
      this.selectedCardId = ''
      if (this.courseDetail) {
        this.selectedCard.price = this.courseDetail?.price as number
        this.selectedCard.advImage = this.courseDetail?.advImage as string
        this.selectedCard.name = this.courseDetail?.courseName as string
        this.selectedCard.avaiCourse = this.courseDetail?.id as string
      }
      this.getCardList()
    })
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.main_background_color'))
  }

  getCardList() {
    MockService.userCardList.forEach((item: UserCard) => {
      if (this.courseDetail && this.courseDetail.avaiCard.includes(item.cardId) && MockService.userCardCanUse(item)) {
        this.userCardList.push(item)
      }
    })
  }

  jumpToCard(card: CardInfo) {
    let cardIndex = this.pathStack.getIndexByName('card/cardDetail')
    // 防止课程和卡项互相跳转导致路由路径过长，查找是否路由已存在，存在删除之前的页面
    if (cardIndex.length > 0) {
      this.pathStack.removeByName('card/cardDetail')
      this.pathStack.pushPath({ name: 'card/cardDetail', param: card })
    } else {
      this.pathStack.pushPath({ name: 'card/cardDetail', param: card })
    }
  }

  getUserInfo() {
    this.phone = MockService.account.phone;
    this.name = MockService.account.nickname ? MockService.account.nickname : '华为用户'
  }

  updateMockData(bookingInfo: BookingInfo) {
    let cardInfo = MockService.getCardById(this.userCardList[this.selectedCardIndex].cardId)
    if (cardInfo.consumeType === ConsumeType.TIMES) {
      let userCard = MockService.getUserCardById(this.userCardList[this.selectedCardIndex].id)
      MockService.userCardMap.set(userCard.id, userCard)
      this.userCardList[this.selectedCardIndex].restQuota -= bookingInfo.personNum
      MockService.dataPreferences.putSync('userCard', JSON.stringify(MockService.userCardList))
    }
    MockService.createBookingRecord(bookingInfo.courseBookingInfo.id, BookState.TO_BE_USE,
      bookingInfo.phone, bookingInfo.name, bookingInfo.personNum, bookingInfo.remark,
      bookingInfo.courseBookingInfo.date, this.userCardList[this.selectedCardIndex].id)
    MockService.getCourseBookingById(bookingInfo.courseBookingInfo.id).restQuota -= bookingInfo.personNum;
    MockService.dataPreferences.putSync('courseBooking', JSON.stringify(MockService.courseBookingList))
    MockService.lastUsedCardId = this.userCardList[this.selectedCardIndex].cardId
    MockService.dataPreferences.putSync('lastUsedCardId', MockService.lastUsedCardId)
    MockService.dataPreferences.flush()
  }
}
