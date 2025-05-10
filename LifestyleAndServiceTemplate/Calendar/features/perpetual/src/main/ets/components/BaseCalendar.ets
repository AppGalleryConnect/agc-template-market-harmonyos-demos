import {
  Constants,
  DateModel,
  DateModelList,
  CalendarVM,
  HolidayVM,
  TextStyleModifier,
  commonActionSheet,
  DatePickerDialog,
  ThemeModel,
} from 'common';
import dayjs from 'dayjs';
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct BaseCalendar {
  vm: CalendarVM = CalendarVM.instance;
  holidayVM: HolidayVM = HolidayVM.instance;
  @Param showHoliday: boolean = false;
  swiperController: SwiperController = new SwiperController();
  @Local disableSwiper: boolean = false;
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;

  @Builder
  datePickerBuilder() {
    DatePickerDialog({
      confirm: (date: Date) => {
        this.vm.changeDate(date);
        commonActionSheet.close('datePickerBuilder')
      },
      cancel: () => {
        commonActionSheet.close('datePickerBuilder')
      },
    })
  }

  @Builder
  calendarHeader() {
    Row() {
      Row() {
        Text(this.vm.getDateLabel())
          .attributeModifier(new TextStyleModifier('font_primary/Subtitle_L/Medium'))
        Image($r('app.media.ic_bottom'))
          .width(24).height(24)
          .margin({ left: 8 })
          .fillColor('#000000')
      }
      .height(24)
      .onClick(() => {
        commonActionSheet.show({
          id: 'datePickerBuilder',
          height: 300,
          showClose: false,
          customContent: () => {
            this.datePickerBuilder()
          },
        })
      });

      Image(this.theme.themeState.id === 'blue' ? $r('app.media.ic_jin_str_blue') : $r('app.media.ic_jin_str'))
        .width(32)
        .height(32)
        .onClick(() => {
          this.vm.getCurDateList();
          this.vm.changeDate(dayjs().toDate());
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
        this.calendarHeader()
      }

      Row() {
        ForEach(Constants.weekList, (item: string) => {
          Text(item)
            .attributeModifier(new TextStyleModifier('font_primary/Body_S/Regular'))
            .textAlign(TextAlign.Center);
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround);

      Swiper(this.swiperController) {
        LazyForEach(this.vm.dateListSource, (item: DateModelList) => {
          Grid() {
            ForEach(item, (item: DateModel) => {
              GridItem() {
                Stack() {
                  if (this.showHoliday) {
                    if (this.holidayVM.isHoliday(item.dateStr)) {
                      Image($r('app.media.ic_rest_str_bg'))
                        .width(48)
                        .height(48)
                        .borderRadius(24);
                      Row() {
                        Text('休')
                          .fontColor($r('app.color.font_color_white'))
                          .fontSize(10);
                      }
                      .justifyContent(FlexAlign.Center)
                      .alignItems(VerticalAlign.Center)
                      .backgroundColor($r('app.color.font_color_red'))
                      .width(16)
                      .height(16)
                      .borderRadius(6)
                      .position({
                        top: 2,
                        left: 2,
                      });
                    } else if (this.holidayVM.isWorkday(item.dateStr)) {
                      Text('班')
                        .fontSize(12)
                        .fontColor($r('app.color.font_color_grey'))
                        .position({
                          x: 0,
                          y: 0,
                        })
                        .zIndex(99);
                    }
                    Column() {
                      Text(item.day.toString())
                        .textStyle(item)
                        .fontSize(14)
                        .lineHeight(20)
                        .fontWeight(700)
                        .fontColor($r('app.color.font_color_black'));
                      Text(item.lunarDay)
                        .textStyle(item)
                        .fontSize(12)
                        .lineHeight(16)
                        .fontWeight(this.vm.isDateSelect(item) ? 700 : 600)
                        .fontColor($r('app.color.font_color_black'));
                    }
                    .dateItemStyle()
                    .backgroundColor(this.vm.isDateSelect(item) ?
                      '#ccc' : '#00ffffff')
                    .borderRadius(24);
                  } else {
                    Column() {
                      Text(item.day.toString())
                        .textStyle(item)
                        .fontSize(14)
                        .lineHeight(20)
                        .fontWeight(700)
                        .fontColor(this.vm.isDateSelect(item) ?
                        $r('app.color.font_color_white') : $r('app.color.font_color_black'));
                      Text(item.lunarDay)
                        .textStyle(item)
                        .fontSize(12)
                        .lineHeight(16)
                        .fontColor(this.vm.isDateSelect(item) ? $r('app.color.font_color_white') : item.lunarColor);
                    }
                    .dateItemStyle()
                    .backgroundColor(this.vm.isDateSelect(item) ?
                    this.theme.themeState.buttonColor : '#00ffffff')
                    .borderRadius(24);
                  }

                }
                .onClick(() => {
                  this.vm.selectDate = item.dayjsObj;
                  this.vm.getTodayYiJi()
                });
              }

            });
          }
          .height('50%')
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
          .columnsGap(0)
          .rowsGap(0);
        });
      }
      .cachedCount(0)
      .indicator(false)
      .index(this.vm.curIndex)
      .loop(false)
      .itemSpace(0)
      .duration(100)
      .disableSwipe(this.disableSwiper)
      .onAnimationStart(() => this.disableSwiper = true)
      .onAnimationEnd(() => this.disableSwiper = false)
      .effectMode(EdgeEffect.None)
      .onChange((index: number) => {
        console.log('touch on change');
        this.vm.handleSwiper(index, index - this.vm.curIndex, this.swiperController);
        if (this.showHoliday) {
          this.holidayVM.updateHolidayInfo(this.vm.selectDate);
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
  .borderRadius(24);
}