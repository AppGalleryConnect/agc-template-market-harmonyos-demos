import { promptAction } from '@kit.ArkUI';
import { Constants } from 'constant';
import { DateModel, Price } from '../model/DateModel';
import { getMonthDate, getRealTimeDate } from '../utils/Time';
import { MonthDataSource, Month, DayInfo } from '../data/MonthDataSource';
import { CalenderUtil } from '../utils/CalenderUtil';

@CustomDialog
export struct CustomCalendarPickerDialog {
  @State contentData: MonthDataSource = new MonthDataSource();
  @State daysInfo: DayInfo[] = [];
  @State nextMonth: number = 1;
  @State nextYear: number = 1;
  @State nextMonthDay: number[] = [];
  @State currentMonthDay: number[] = [];
  @State initialIndex: number = 0;
  @Link currentMonth: number;
  @Link currentDay: number;
  @Link currentYear: number;
  @Link endDate: DateModel;
  @Link startDate: DateModel;
  @Link night: number;
  @Link priceList: Price[];
  @Link isShowPrice: boolean;
  @Link @Watch('readyToClose') readyCloseDialog: boolean;
  controller: CustomDialogController;
  cancel: () => void = () => {
  };
  @State customY: number = 0;

  readyToClose() {
    setTimeout(() => {
      this.controller.close();
      // 未选择离店日期时重置
      if (this.endDate.day === 0) {
        let selectedStartDate = CalenderUtil.getStartDate();
        // 开始时间被单独重置情况处理
        if (selectedStartDate?.day ?? this.currentDay > this.currentDay) {
          AppStorage.setOrCreate('startDate', new DateModel(this.currentDay, 0, this.currentMonth, this.currentYear));
        }

        this.startDate =
          CalenderUtil.getStartDate() ?? new DateModel(this.currentDay, 0, this.currentMonth, this.currentYear);
        this.endDate =
          CalenderUtil.getEndDate() ?? new DateModel(this.currentDay + 1, 0, this.currentMonth, this.currentYear);
      }
    }, Constants.TRANSITION_DURATION);
    animateTo({
      duration: Constants.TRANSITION_DURATION,
    }, () => {
      this.customY = 800;
    });
  }

  isApplySelected(day: number, month: number | string) {
    return (day === this.startDate.day && month ===
    this.startDate.month) || (day === this.endDate.day && month ===
    this.endDate.month);
  }

  // 获取当前月和下个月的日期数据
  aboutToAppear() {
    let currentDate: DateModel = getRealTimeDate() ?? new DateModel(0, 0, 0, 0);
    this.currentMonth = currentDate.month;
    this.currentDay = currentDate.day;
    this.currentYear = currentDate.year;

    this.currentMonthDay = getMonthDate(this.currentMonth, this.currentYear);
    // 如果下个月是在下一年，则下个月是1月份，年份要+1
    if (this.currentMonth === Constants.MONTHS) {
      this.nextMonth = Constants.JANUARY;
      this.nextYear = this.currentYear + 1;
    } else {
      this.nextMonth = this.currentMonth + 1;
      this.nextYear = this.currentYear;
    }
    this.nextMonthDay = getMonthDate(this.nextMonth, this.nextYear);
    let months: Month[] = [this.getCurrentMonthData(), this.getNextMonthData()];

    this.contentData.pushData(months);

    this.initialIndex = this.startDate.month > this.currentMonth ? 1 : 0;
  }

  getCurrentMonthData() {
    return new Month(`${this.currentYear}年 ${this.currentMonth}月`, this.currentMonth,
      this.currentMonthDay,
      this.getDaysInfo(this.currentMonthDay, this.currentMonth, this.currentYear));
  }

  getNextMonthData() {
    return new Month(`${this.nextYear}年 ${this.nextMonth}月`, this.nextMonth,
      this.nextMonthDay,
      this.getDaysInfo(this.nextMonthDay, this.nextMonth, this.nextYear));
  }

  getDaysInfo(day: number[], month: number, year: number): DayInfo[] {
    let daysInfo: DayInfo[] = [];

    day.forEach((item: number) => {
      let dayInfo = new DayInfo();
      let priceItem = this.priceList.find((priceItem: Price) => priceItem.date ===
        `${year}-${month < 10 ? month.toString().padStart(2, '0') : month}-${item < 10 ?
        item.toString().padStart(2, '0') : item}`);

      if (priceItem) {
        dayInfo.day = item;
        dayInfo.price = priceItem.price;
      } else {
        dayInfo.day = item;
        dayInfo.price = 0;
      }
      daysInfo.push(dayInfo);
    });

    return daysInfo;
  }

  getValidDay(days: number[]) {
    return days.filter((item) => item !== 0);
  }

  getPriceFontColor(dayInfo: DayInfo, monthItem: Month) {
    if (this.isSelectedDay(dayInfo, monthItem)) {
      return $r('app.color.normal_bg_color');
    }
    return $r('app.color.keyword_type_font_color');
  }

  getFontColor(dayInfo: DayInfo, monthItem: Month) {
    if (this.isSelectedDay(dayInfo, monthItem)) {
      return $r('app.color.normal_bg_color');
    }
    return '#000000';
  }

  isTransparent(dayInfo: DayInfo, monthItem: Month) {
    // 跨年情况，1月可选
    return this.isCruMonthAvailable(dayInfo, monthItem) || monthItem.num > this.currentMonth ||
      this.currentMonth === 12;
  }

  isEnable(dayInfo: DayInfo, monthItem: Month) {
    // 不展示日期不可点击
    if (dayInfo.day === 0) {
      return false;
    }

    // 跨年情况，1月可选
    if (monthItem.num > this.currentMonth || (this.currentMonth === 12 && monthItem.num === 1)) {
      return true;
    }
    return dayInfo.day >= this.currentDay && monthItem.num ===
    this.currentMonth;
  }

  isSelectedDay(dayInfo: DayInfo, monthItem: Month) {
    return (dayInfo.day === this.startDate.day && monthItem.num ===
    this.startDate.month) || (dayInfo.day === this.endDate.day && monthItem.num ===
    this.endDate.month);
  }

  isCruMonthAvailable(dayInfo: DayInfo, monthItem: Month) {
    return (dayInfo.day >= this.currentDay && monthItem.num ===
    this.currentMonth);
  }

  getBgColor(dayInfo: DayInfo, monthItem: Month): Resource {
    if (this.isSelectedDay(dayInfo, monthItem)) {
      return $r('app.color.keyword_type_font_color');
    } else if (this.isInTravel(dayInfo, monthItem)) {
      return $r('app.color.mid_bg_color');
    }
    return $r('app.color.normal_bg_color');
  }

  isInTravel(dayInfo: DayInfo, monthItem: Month) {
    let notInSameYear =
      ((this.endDate.month === 1 && this.startDate.month === 12) && dayInfo.day <= this.endDate.day && monthItem.num ===
      this.endDate.month && dayInfo.day !== 0) ||
        ((this.endDate.month === 1 && this.startDate.month === 12) && dayInfo.day >= this.startDate.day &&
          monthItem.num ===
          this.startDate.month && dayInfo.day !== 0);
    let inSameMonth = (dayInfo.day >= this.startDate.day && monthItem.num ===
    this.startDate.month) && (dayInfo.day <= this.endDate.day && monthItem.num ===
    this.startDate.month);
    let notInSameMonth =
      (this.endDate.month > this.startDate.month && dayInfo.day <= this.endDate.day && monthItem.num ===
      this.endDate.month && dayInfo.day !== 0) ||
        (this.endDate.month > this.startDate.month && dayInfo.day >= this.startDate.day && monthItem.num ===
        this.startDate.month && dayInfo.day !== 0);

    return inSameMonth || notInSameMonth || notInSameYear;
  }

  // 显示日历布局的每个月上方的年月信息
  @Builder
  itemHead(text: string) {
    Text(text)
      .backgroundColor(Color.White)
      .width(Constants.FULL_SCREEN)
      .fontSize(14)
      .textAlign(TextAlign.Center)
      .fontColor(Color.Black)
      .fontWeight(500);
  }

  // 自定义日历选取器内容
  build() {
    Column() {
      Column() {
        Row() {
          Column() {
            Text('入住日期')
              .fontColor(Color.Gray)
              .fontSize(12);
            Text(`${this.startDate?.month}月${this.startDate?.day}日`)
              .margin(6)
              .fontSize(18);
          };

          Column() {
            Button(`${this.night}晚`)
              .height(24)
              .fontSize(12)
              .backgroundColor(Color.White)
              .border({ radius: 10, width: 1 })
              .fontColor(Color.Black)
              .padding({
                left: 12,
                right: 12,
                top: 4,
                bottom: 4,
              });
          }.justifyContent(FlexAlign.Center);

          Column() {
            Text('离店日期')
              .fontColor(Color.Gray)
              .fontSize(12);
            Text(`${this.endDate?.month}月${this.endDate?.day}日`)
              .margin(6)
              .fontSize(18);
          };
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .width(Constants.FULL_SCREEN)
        .backgroundColor('#F5F6FA')
        .borderRadius(8)
        .margin(16)
        .padding(16);
      }.width(Constants.FULL_SCREEN).padding(16);

      // 显示周信息，从周日开始到周六
      List() {
        ForEach(Constants.week, (weekInformation: string) => {
          ListItem() {
            Text(weekInformation)
              .textAlign(TextAlign.Center)
              .width(Constants.FULL_SCREEN)
              .fontSize(16)
              .height(20)
              .fontColor(Color.Black);
          }
          .width('14.3%');
        }, (item: string) => item);
      }
      .width(Constants.FULL_SCREEN)
      .height(20)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off);

      Divider().vertical(false).width(Constants.FULL_SCREEN).margin({ top: 16 });

      Scroll() {
        List({ initialIndex: this.initialIndex }) {
          LazyForEach(this.contentData, (monthItem: Month) => {
            ListItemGroup({ header: this.itemHead(monthItem.month) }) {
              ListItem() {
                Grid() {
                  ForEach(monthItem.daysInfo, (dayInfo: DayInfo) => {
                    GridItem() {
                      Column() {
                        if (dayInfo.day !== 0) {
                          Text(`${dayInfo.day.toString()}`)
                            .fontSize(14)
                            .fontColor(this.getFontColor(dayInfo, monthItem))
                            .opacity(this.isTransparent(dayInfo, monthItem) ? 1 : 0.2);
                        }

                        if (this.isShowPrice && dayInfo.price !== 0) {
                          Text(`￥${dayInfo.price.toString()}`)
                            .fontSize(10)
                            .fontColor(this.getPriceFontColor(dayInfo, monthItem));
                        }
                      };
                    }
                    .enabled(this.isEnable(dayInfo, monthItem))
                    .backgroundColor(this.getBgColor(dayInfo, monthItem))
                    .onClick(() => {
                      this.selectDate(dayInfo, monthItem);
                    });
                  }, (item: DayInfo) => item.day.toString());
                }
                .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
                .rowsTemplate(Math.floor(monthItem.daysInfo.length / 7) === 6 ? '1fr 1fr 1fr 1fr 1fr 1fr' :
                  '1fr 1fr 1fr 1fr 1fr')
                .padding(0);
              }.height(240);
            }.margin({ top: 24 });
          }, (item: Month) => item.month);
        }
        .edgeEffect(EdgeEffect.None)
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.Header);
      };
    }
    .width(Constants.FULL_SCREEN)
    .translate({ x: 0, y: this.customY })
    .transition(TransitionEffect.translate({ x: 0, y: 600 })
      .animation({ duration: Constants.TRANSITION_DURATION }))
    .borderRadius({
      topLeft: 16,
      topRight: 16,
    })
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Center);
  }

  selectDate(dayInfo: DayInfo, monthItem: Month) {
    let weekIndex = monthItem.days.indexOf(dayInfo.day) % Constants.WEEK_NUMBER;
    // 离店日期不为空
    if (this.endDate.day !== 0) {
      //清空离店日期
      this.startDate.day = dayInfo.day;
      this.startDate.month = monthItem.num;
      this.startDate.week = weekIndex;
      this.startDate.year = Number(monthItem.month.split('年')[0]);
      this.endDate = new DateModel(0, 0, 0, this.currentYear);
      promptAction.showToast({
        message: '请选择离店日期',
        duration: 500,
      });
    } else {
      let endYear = Number(monthItem.month.split('年')[0]);
      if (this.startDate.day === dayInfo.day && this.startDate.month === monthItem.num &&
        this.startDate.year === endYear) {
        promptAction.showToast({
          message: '入住日期与离店日期不能为同一天',
          duration: 500,
        });
        return;
      }

      this.endDate.day = dayInfo.day;
      this.endDate.month = monthItem.num;
      this.endDate.week = weekIndex;
      this.endDate.year = endYear;

      if ((this.startDate.month > this.endDate.month && this.startDate.year === this.endDate.year) ||
        (this.startDate.month === this.endDate.month && this.startDate.day > this.endDate.day) ||
        (this.startDate.year > this.endDate.year && this.startDate.month < this.endDate.month)) {
        this.swapDate(this.startDate, this.endDate);
      }

      this.calcNight();
      //写入应用内存
      AppStorage.setOrCreate('startDate', this.startDate);
      AppStorage.setOrCreate('endDate', this.endDate);

      setTimeout(() => {
        this.controller.close();
      }, 500);
      animateTo({
        duration: 100,
      }, () => {
        this.customY = 800;
      });
    }
  }

  swapDate(start: DateModel, end: DateModel) {
    let startInfo = [start.day, start.month, start.year];
    let endInfo = [end.day, end.month, end.year];

    end.set(startInfo[0], startInfo[1], startInfo[2]);
    start.set(endInfo[0], endInfo[1], endInfo[2]);
  }

  calcNight() {
    if (this.startDate.month === this.endDate.month) {
      this.night = this.endDate.day - this.startDate.day;
    } else {
      let curentMonthDays = getMonthDate(this.startDate.month, this.startDate.year).filter((item) => item !== 0).length;
      this.night = curentMonthDays - this.startDate.day + this.endDate.day;
    }
    AppStorage.setOrCreate('night', this.night);
  }
}