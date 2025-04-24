import { promptAction, window } from '@kit.ArkUI';
import {
  CommonConstants,
  createAppointmentInfo,
  ICreateAppointmentRequest,
  GoodInfo,
  Logger,
  PopViewUtils,
  RouterMap,
  RouterModule,
  PHONE_REG,
} from 'utils';
import { ConstantsHome } from '../common/Constant';
import { DayModel, get7Days, getAllowTimes } from '../common/Utils';
import { BookSuccessParam, DialogBookSuccessBuilder } from '../components/DialogBookSuccess';

@Builder
export function BookGoodBuilder() {
  BookGood()
}

@Extend(Text)
function subTitle() {
  .fontSize(14)
  .fontColor('#212121')
  .fontWeight(FontWeight.Bold)
  .alignSelf(ItemAlign.Start)
}

@Extend(TextInput)
function inputItem() {
  .constraintSize({ maxWidth: '60%' })
  .placeholderColor('#C7C7C7')
  .backgroundColor(Color.Transparent)
  .textAlign(TextAlign.End)
  .padding(0)
  .borderRadius(0)
}

@Extend(Row)
function itemContainer() {
  .padding({ top: 12, bottom: 12 })
  .width(CommonConstants.FULL_PERCENT)
  .justifyContent(FlexAlign.SpaceBetween)
}

@Extend(Button)
function buttonCircle() {
  .type(ButtonType.Circle)
  .width(24)
  .height(24)
  .backgroundColor('#F5F5F5')
}

@Builder
function customDivider() {
  Divider()
}

@ComponentV2
export struct BookGood {
  @Local goodInfo: GoodInfo = new GoodInfo();
  @Local dates: DayModel[] = [];
  @Local times: string[] = [];
  @Local selectDateIndex: number = 0;
  @Local selectTimeIndex: number = 0;
  @Local contactUserName: string = '';
  @Local contactPhone: string = '';
  @Local inputNum: number = 1;
  @Local remark: string = '';
  @Local isSubmitLoading: boolean = false;
  @Local keyHeight: number = 0;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.dates = get7Days();
    this.getTodayTimes();
    const paramList: Array<GoodInfo> = RouterModule.getNavParam({ url: RouterMap.BOOK_GOOD });
    if (paramList.length) {
      this.goodInfo = paramList[paramList.length - 1];
    }
    // 监听软键盘的隐藏和显示
    this.onKeyBoard();
  }

  aboutToDisappear(): void {
    // 取消监听软键盘的隐藏和显示
    this.offKeyBoard();
  }

  onKeyBoard() {
    window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('avoidAreaChange', this.onKeyBoardCB);
    })
  }

  offKeyBoard() {
    window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.off('avoidAreaChange', this.onKeyBoardCB);
    })
  }

  onKeyBoardCB: (data: window.AvoidAreaOptions) => void = (data: window.AvoidAreaOptions) => {
    if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
      this.keyHeight = px2vp(data.area.bottomRect.height);
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 10);
    }
  };

  getTodayTimes() {
    const today = new Date();
    const startTime = today.getTime();
    today.setHours(19);
    today.setMinutes(30);
    today.setSeconds(0);
    const endTime = today.getTime();
    this.times = getAllowTimes(startTime, endTime);

    if (this.times.length) {
      this.selectTimeIndex = 0;
    } else {
      this.selectTimeIndex = -1;
    }
  }

  getOtherDayTimes() {
    const date = this.dates[this.selectDateIndex].date;
    date.setHours(8);
    date.setMinutes(0);
    date.setSeconds(0);
    const startTime = date.getTime();

    date.setHours(19);
    date.setMinutes(30);
    date.setSeconds(0);
    const endTime = date.getTime();
    this.times = getAllowTimes(startTime, endTime);
  }

  isInValid(): boolean {
    // 当天无可选时间
    if (this.selectTimeIndex === -1) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_time') });
      return true;
    }
    // 联系人未填
    if (!this.contactUserName) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_name') });
      return true;
    }
    // 手机号未填写
    if (!this.contactPhone) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_phone') });
      return true;
    }
    // 手机号格式不正确
    if (!PHONE_REG.test(this.contactPhone)) {
      promptAction.showToast({ message: $r('app.string.book_good_toast_phone_correct') });
      return true;
    }

    return false;
  }

  buildParams() {
    const selectedDate = this.dates[this.selectDateIndex].date;
    const selectTime = this.times[this.selectTimeIndex].split(':').map(v => Number(v));
    selectedDate.setHours(selectTime[0]);
    selectedDate.setMinutes(selectTime[1]);
    selectedDate.setSeconds(0);

    const selectedDateTime = selectedDate;

    const data: ICreateAppointmentRequest = {
      // 联系人姓名
      name: this.contactUserName,
      // 联系人手机号
      phone: this.contactPhone,
      // 预约时间，时间戳类型
      reserveTime: selectedDateTime.getTime().toString(),
      // 预约的项目ID
      goodId: this.goodInfo.id.toString(),
      // 预约备注
      remarks: this.remark,
      // 预约人数
      numbers: this.inputNum.toString(),
    };
    Logger.info('appoint data:' + JSON.stringify(data));
    return data;
  }

  openBookSuccessDialog() {
    PopViewUtils.showPopView<BookSuccessParam>(wrapBuilder(DialogBookSuccessBuilder), new BookSuccessParam(),
      { alignment: DialogAlignment.Center });
  }

  onSubmit: () => void = () => {
    if (this.isInValid()) {
      return;
    }
    this.isSubmitLoading = true;
    const data = this.buildParams();
    createAppointmentInfo(data).then(() => {
      this.openBookSuccessDialog();
      this.isSubmitLoading = false;
    }).catch(() => {
      this.isSubmitLoading = false;
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.book_error_tip') });
    })
  };

  onSelectDate(index: number) {
    this.selectDateIndex = index;
    if (this.selectDateIndex === 0) {
      this.getTodayTimes();
    } else {
      this.getOtherDayTimes();
    }
    if (this.times.length) {
      this.selectTimeIndex = 0;
    } else {
      this.selectTimeIndex = -1;
    }
  }

  dateUpFgColor(index: number) {
    return this.selectDateIndex === index ? $r('app.color.common_theme_color') : '#434343';
  }

  dateDownFgColor(index: number) {
    return this.selectDateIndex === index ? $r('app.color.common_theme_color') : '#999999';
  }

  dateBgColor(index: number) {
    return this.selectDateIndex === index ? '#FDE9E7' : '#F7F7F9';
  }

  timeFgColor(index: number) {
    return this.selectTimeIndex === index ? $r('app.color.common_theme_color') : '#434343';
  }

  timeBgColor(index: number) {
    return this.selectTimeIndex === index ? '#FDE9E7' : '#F7F7F9';
  }

  @Builder
  SelectDateTime() {
    Column() {
      Text($r('app.string.book_good_appoint_time')).subTitle()
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.dates, (v: DayModel, index) => {
            Column({ space: 2 }) {
              Text(v.weekDesc).fontSize(14).fontColor(this.dateUpFgColor(index))
              Text(v.dateDesc).fontSize(14).fontColor(this.dateDownFgColor(index))
            }
            .padding({
              top: 7,
              bottom: 7,
              left: 21,
              right: 21,
            })
            .backgroundColor(this.dateBgColor(index))
            .borderRadius(22)
            .onClick(() => {
              this.onSelectDate(index);
            })
          }, (item: DayModel) => JSON.stringify(item))
        }
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .margin({ top: 10, bottom: 10 })

      customDivider()

      if (this.times.length) {
        Grid() {
          ForEach(this.times, (v: string, index: number) => {
            GridItem() {
              Text(v)
                .fontSize(14)
                .fontColor(this.timeFgColor(index))
                .backgroundColor(this.timeBgColor(index))
                .width(CommonConstants.FULL_PERCENT)
                .padding({ top: 14, bottom: 14 })
                .borderRadius(20)
                .textAlign(TextAlign.Center)
            }.onClick(() => {
              this.selectTimeIndex = index;
            })
          }, (day: string) => day)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .width(CommonConstants.FULL_PERCENT)
        .height(160)
        .margin({ top: 10 })
        .scrollBar(BarState.Off)
        .nestedScroll({
          scrollForward: NestedScrollMode.SELF_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        })
      } else {
        Image($r('app.media.empty_time')).width(50).height(50).margin({ top: 32, bottom: 14 })
        Text($r('app.string.book_good_times_empty')).fontSize(14).fontColor('#B6B6B6').margin({ bottom: 32 })
      }
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      top: 10,
      bottom: 10,
      left: 10,
      right: 10,
    })
    .borderRadius(9)
  }

  @Builder
  AppointmentInfo() {
    Column() {
      Text($r('app.string.book_good_appoint_info')).subTitle()
      Row() {
        Text($r('app.string.book_good_appoint_project')).fontSize(16).fontColor('#212121')
        Text(this.goodInfo.title)
          .fontSize(16)
          .fontColor('#212121')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '60%' })
      }
      .itemContainer()
      .margin({ top: 10 })

      customDivider()

      Row() {
        Row({ space: 4 }) {
          Text($r('app.string.book_good_appoint_contact_name')).fontSize(16).fontColor('#212121')
          Text($r('app.string.common_required')).fontSize(11).fontColor($r('app.color.common_theme_color'))
        }

        TextInput({ placeholder: $r('app.string.book_contact_name_place'), text: $$this.contactUserName })
          .id('userNameId')
          .inputItem()
          .onWillInsert(() => {
            if (this.contactUserName.length >= ConstantsHome.MAX_CONTACT_NAME_LENGTH) {
              return false;
            }
            return true;
          })

      }
      .itemContainer()

      customDivider()

      Row() {
        Row({ space: 4 }) {
          Text($r('app.string.book_good_appoint_phone')).fontSize(16).fontColor('#212121')
          Text($r('app.string.common_required')).fontSize(11).fontColor($r('app.color.common_theme_color'))
        }

        TextInput({ placeholder: $r('app.string.book_phone_place'), text: $$this.contactPhone })
          .type(InputType.PhoneNumber)
          .inputItem()
      }
      .id('phoneId')
      .itemContainer()

      customDivider()

      Row() {
        Text($r('app.string.book_good_appoint_nums')).fontSize(16).fontColor('#212121')
        Row({ space: 10 }) {
          Button() {
            Image($r('app.media.ic_minus')).width(14)
          }
          .buttonCircle()
          .enabled(this.inputNum >= ConstantsHome.MIN_NUMS + 1)
          .onClick(() => {
            this.inputNum -= 1;
          })

          Text(this.inputNum.toString()).fontSize(16).fontColor('#212121').fontWeight(FontWeight.Bold)

          Button() {
            Image($r('app.media.ic_plus')).width(14)
          }
          .buttonCircle()
          .enabled(this.inputNum <= ConstantsHome.MAX_NUMS - 1)
          .onClick(() => {
            this.inputNum += 1;
          })
        }
      }
      .itemContainer()

      customDivider()

      Column() {
        Text($r('app.string.book_good_appoint_remark')).fontSize(16).fontColor('#212121').alignSelf(ItemAlign.Start)
        TextArea({ placeholder: $r('app.string.book_remark_place'), text: $$this.remark })
          .maxLines(3)
          .height(60)
          .placeholderColor('#C7C7C7')
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding(0)
          .margin({ top: 10 })
          .onWillInsert(() => {
            if (this.remark.length >= ConstantsHome.MAX_REMARK_LENGTH) {
              return false;
            }
            return true;
          })
      }
      .id('remarkId')
      .margin({ top: 12 })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      top: 15,
      bottom: 10,
      left: 10,
      right: 10,
    })
    .borderRadius(8)
  }

  @Computed
  get leftH() {
    return 10 + 56 + this.keyHeight;
  }

  build() {
    NavDestination() {
      Column() {
        Scroll(this.scroller) {
          Column({ space: 10 }) {
            // 预约时间卡片
            this.SelectDateTime()
            // 预约信息卡片
            this.AppointmentInfo()
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(`calc(100% - ${this.leftH}vp)`)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)

        Column() {
          Text($r('app.string.book_good_tip')).fontSize(12).lineHeight(16).fontColor($r('app.color.common_theme_color'))
          Button($r('app.string.book_good_btn'))
            .width(CommonConstants.FULL_PERCENT)
            .backgroundColor($r('app.color.common_theme_color'))
            .enabled(!this.isSubmitLoading)
            .onClick(this.onSubmit)
        }
        .margin({ top: 10 })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding(10)
      .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .title('预约', { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
