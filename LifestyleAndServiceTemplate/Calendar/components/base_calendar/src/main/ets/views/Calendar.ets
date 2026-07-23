import dayjs from 'dayjs';
import { baseActionSheet, BaseDatePicker } from 'base_apis';
import CalendarVM from '../viewModel/CalendarVM';
import HolidayVM from '../viewModel/HolidayVM';
import { CalendarHeaderItem, DateModel, DateModelList } from '../models/DateModel';

@ComponentV2
export struct BaseCalendar {
  vm: CalendarVM = CalendarVM.instance;
  holidayVM: HolidayVM = HolidayVM.instance;
  swiperController: SwiperController = new SwiperController();
  @Local selectedDay: DateModel | null = null
  /**
   * 当前选择时间
   * */
  @Event onCurrentDateSelected: (date: string) => void = () => {
  }
  /**
   * 当前时间
   * */
  @Param currentDate: string = ''
  /**
   * 自定义选中颜色
   */

  @Param selectedColor: ResourceStr | Color = '#C4272B'
  /**
   * 图标形状
   * */
  @Param selectedStyle: 'circle' | 'squares' = 'circle'
  /**
   * 周首日 0=周日, 1=周一
   * */
  @Param startWeekday: 'sunday' | 'monday' = 'monday'
  /**
   * 是否展示休息日
   * */
  @Param showHoliday: boolean = false
  /**
   * 是否展示农历
   * */
  @Param isShowLunar: boolean = false
  /**
   * 是否显示头部
   */
  @Param isShowHeader: boolean = true
  /**
   * 自定义头部项插槽
   */
  @BuilderParam calendarHeaderBuilder?: (item: CalendarHeaderItem) => void
  /**
   * 节日、节气展示颜色
   */
  @Param festivalColor: ResourceStr | Color = Color.Red
  context: UIContext = this.getUIContext()

  aboutToAppear() {
    this.initCalendar()
  }

  @Monitor('startWeekday')
  onStrChange() {
    const week = this.startWeekday === 'sunday' ? 0 : 1 // 0=周日, 1=周一
    this.vm.updateWeekdayStart(week)
  }

  initCalendar() {
    this.vm.festivalColor = this.festivalColor
    const week = this.startWeekday === 'sunday' ? 0 : 1 // 0=周日, 1=周一
    this.vm.updateWeekdayStart(week)
    this.vm.getCurDateList()
    this.vm.changeDate(new Date(this.currentDate))
    if (this.showHoliday) {
      this.holidayVM.getHolidayMonthDetail();
    }
    if (this.calendarHeaderBuilder) {
      this.selectedDay = this.vm.todayInfo
    }
  }

  @Builder
  datePickerBuilder() {
    BaseDatePicker({
      datePicker: new Date(this.vm.selectDate.format('YYYY-MM-DD')),
      selectColor: this.selectedColor,
      confirm: (date: Date) => {
        this.vm.changeDate(date);
        this.onCurrentDateSelected(dayjs(date).format('YYYY-MM-DD'))
        baseActionSheet.close(this.context, 'datePickerBuilder')
      },
      cancel: () => {
        baseActionSheet.close(this.context, 'datePickerBuilder')
      },
    })
  }

  @Builder
  calendarHeader() {
    Row() {
      Row() {
        Text(this.vm.getDateLabel())
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Medium)
        Image($r('app.media.ic_bottom'))
          .width(24).height(24)
          .margin({ left: 8 })
          .fillColor('#000000')
      }
      .height(24)
      .onClick(() => {
        baseActionSheet.show(this.context, {
          id: 'datePickerBuilder',
          detents: [300, 301],
          showClose: false,
          customContent: () => {
            this.datePickerBuilder()
          },
        })
      });

      Image(this.selectedColor === '#4f616d' ? $r('app.media.ic_jin_str_blue') : $r('app.media.ic_jin_str'))
        .width(32)
        .height(32)
        .onClick(() => {
          let targetIndex = this.vm.changeDateAnimated(dayjs().toDate())
          if (targetIndex >= 0) {
            setTimeout(() => {
              this.vm.animationTargetIndex = targetIndex
              this.swiperController.changeIndex(targetIndex, true)
            }, 50)
          }
          this.onCurrentDateSelected(dayjs(this.vm.selectDate).format('YYYY-MM-DD'))
        })
    }
    .width('100%')
    .margin({ top: 16, bottom: 16 })
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
      Column() {
        if (this.calendarHeaderBuilder) {
          this.calendarHeaderBuilder({
            dateStr: this.selectedDay?.dateStr as string,
            day: this.selectedDay?.day.toString() as string,
            lunarDay: this.selectedDay?.lunarDay as string,
          })
        } else {
          this.calendarHeader()
        }
      }
      .visibility(this.isShowHeader ? Visibility.Visible : Visibility.None)

      Row() {
        ForEach(this.vm.weekDayList, (item: string) => {
          Text(item)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center);
        }, (item: string) => item);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround);

      Swiper(this.swiperController) {
        LazyForEach(this.vm.dateListSource, (item: DateModelList) => {
          Grid() {
            ForEach(item, (item: DateModel) => {
              GridItem() {
                Stack() {
                  Column() {
                    Text(item.day.toString())
                      .textStyle(item)
                      .fontSize(14)
                      .lineHeight(20)
                      .fontWeight(700)
                      .fontColor(this.vm.isTodaySelected(item) ?
                        $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
                    Row() {
                      Text('休')
                        .fontColor(this.vm.isTodaySelected(item) ?
                          $r('sys.color.font_on_primary') : Color.White)
                        .fontSize(10);
                    }
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)
                    .backgroundColor('#64BB5C')
                    .width(16)
                    .height(16)
                    .borderRadius(6)
                    .position({
                      top: 2,
                      right: 2,
                    })
                    .visibility(this.showHoliday && this.holidayVM.isHoliday(item.dateStr) ? Visibility.Visible :
                      Visibility.None)

                    Text(item.lunarDay)
                      .textStyle(item)
                      .fontSize(12)
                      .lineHeight(16)
                      .fontColor(this.vm.isTodaySelected(item) ? $r('sys.color.font_on_primary') : item.lunarColor)
                      .visibility(this.isShowLunar ? Visibility.Visible : Visibility.None)
                  }
                  .dateItemStyle()
                  .backgroundColor(this.vm.isTodaySelected(item) ?
                    this.selectedColor : (this.vm.isNonTodaySelected(item) ? '#00000000' : '#00ffffff'))
                  .border({
                    width: this.vm.isNonTodaySelected(item) ? 2 : 0,
                    color: this.selectedColor
                  })
                  .borderRadius(this.selectedStyle === 'squares' ? 0 : 24);
                }
                .onClick(() => {
                  if (!item.isToMonth) {
                    this.vm.monthDate = item.dayjsObj
                    this.vm.isSwiperChange(item, this.swiperController)
                  } else {
                    this.vm.selectDate = item.dayjsObj;
                    this.selectedDay = item
                  }
                  this.onCurrentDateSelected(dayjs(item.dayjsObj).format('YYYY-MM-DD'))
                });
              }
            }, (item: DateModel) => JSON.stringify(item));
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .maxCount(7)
          .columnsGap(0)
          .rowsGap(0)
          .padding({ bottom: 20 })
        }, (item: DateModelList) => JSON.stringify(item));
      }
      .cachedCount(0)
      .indicator(false)
      .index(this.vm.curIndex)
      .loop(false)
      .itemSpace(0)
      .effectMode(EdgeEffect.None)
      .onChange((index: number) => {
        this.vm.handleSwiper(index, index - this.vm.curIndex, this.swiperController);
        this.onCurrentDateSelected(dayjs(this.vm.selectDate).format('YYYY-MM-DD'))
        if (this.showHoliday) {
          this.holidayVM.getHolidayMonthDetail();
        }
        this.vm.curIndex = index;
      });
    }
    .borderRadius({
      bottomLeft: 16,
      bottomRight: 16,
    })
    .backgroundColor($r('app.color.background_color_light'))
  }
}

@Extend(Text)
function textStyle(item: DateModel) {
  .width(48)
  .textAlign(TextAlign.Center)
  .opacity(item.isToMonth ? 1 : 0.4);
}

@Extend(Column)
function dateItemStyle() {
  .width(48)
  .height(48)
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
}