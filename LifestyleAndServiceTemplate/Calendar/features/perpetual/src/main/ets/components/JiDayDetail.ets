import {
  CalendarVM,
  commonActionSheet,
  DividerTmp,
  getCurEndDate,
  getLuckyMarriageDaysInTwoMonths,
  LuckyDays,
  NavigationTitle,
  TextStyleModifier,
  ThemeModel,
  DatePickerDialog,
} from 'common'
import dayjs from 'dayjs'
import { PersistenceV2 } from '@kit.ArkUI'


@Builder
export function JiDayDetailBuilder() {
  JiDayDetail()
}

@ComponentV2
export struct JiDayDetail {
  @Local title: string = ' '
  @Local jiDayResult: LuckyDays[] = []
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  vm: CalendarVM = CalendarVM.instance;
  @Local datePicker: Date = new Date()
  @Local endDate: string = ''
  @Local startDate: string = ''

  isWeekDay(item: LuckyDays) {
    return ['星期日', '星期六'].includes(item.weekday)
  }

  getJiDayInWeek(isOn: boolean) {
    if (isOn) {
      this.jiDayResult = this.jiDayResult.filter(item => ['星期日', '星期六'].includes(item.weekday))
    } else {
      this.jiDayResult = getLuckyMarriageDaysInTwoMonths(this.title, new Date(this.vm.getCurDate()))
    }
  }

  getNavigationParams() {
    this.title =
      this.pageInfos.getParamByName('JiDayDetail')[0] as string
  }

  aboutToAppear(): void {
    this.getNavigationParams()
    this.jiDayResult = getLuckyMarriageDaysInTwoMonths(this.title, new Date(this.vm.getCurDate()))
    this.getJiDayEndDate()
    this.getJiDayStartDate()
  }

  getJiDayEndDate(date?: Date) {
    this.endDate = getCurEndDate(date ?? this.vm.getCurDate())
  }

  getJiDayStartDate(date?: Date) {
    this.startDate = this.vm.getCurSolarDate(date)
  }

  @Builder
  jiDayTips() {
    Column() {
      Text('宜嫁娶：男娶女嫁，举行结婚大典的吉日。宜嫁娶：男娶女嫁，举行结婚大典的吉日。')
        .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
    }
    .margin({ top: 16, bottom: 8 })
  }

  @Builder
  jiDayFilter() {
    List({ space: 12 }) {
      ListItem() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Text() {
              Span('近期')
              Span('宜')
              Span(this.title)
              Span('的日子共有')
              Span(this.jiDayResult.length.toString())
                .fontColor('#C4272B')
                .fontWeight(FontWeight.Bold)
                .fontSize($r('sys.float.Body_L'))
              Span('天')
            }
            .attributeModifier(new TextStyleModifier('#000000/Body_M/Regular'))
          }

          Row({ space: 5 }) {
            Text('只看周末')
              .attributeModifier(new TextStyleModifier('#000000/Body_M/Regular'))
            Toggle({ type: ToggleType.Switch, isOn: false })
              .switchPointColor('#FFFFFF')
              .selectedColor(this.theme.themeState.current)
              .onChange((isOn: boolean) => {
                this.getJiDayInWeek(isOn)
              })
          }
        }
      }

      ForEach(this.jiDayResult, (item: LuckyDays) => {
        ListItem() {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Row({ space: 12 }) {
              Column({ space: 12 }) {
                Text(dayjs(item.solarDate).format('YYYY.MM-DD').split('-')[0])
                  .attributeModifier(new TextStyleModifier(`${this.isWeekDay(item) ? '#C4272B' :
                    'font_primary'}/Body_S/Regular`))
                Text(dayjs(item.solarDate).format('YYYY.MM-DD').split('-')[1])
                  .attributeModifier(new TextStyleModifier(`${this.isWeekDay(item) ? '#C4272B' :
                    'font_primary'}/Title_L/Regular`))
                Text(item.weekday)
                  .attributeModifier(new TextStyleModifier(`${this.isWeekDay(item) ? '#C4272B' :
                    'font_primary'}/Body_S/Regular`))
              }
              .border({
                width: { right: 1 },
                color: { right: '#ccc' },
              })
              .padding({ right: 16 })

              Column({ space: 5 }) {
                Text(item.lunarDate)
                  .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
                Row({ space: 5 }) {
                  Text(item.ganZhiYear)
                    .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
                  Text(item.ganZhiMonth)
                    .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
                  Text(item.ganZhiDay)
                    .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
                }

                Row({ space: 5 }) {
                  Text('值神：天刑')
                    .attributeModifier(new TextStyleModifier('font_secondary/Body_S/Regular'))
                  Text('十二神：满日')
                    .attributeModifier(new TextStyleModifier('font_secondary/Body_S/Regular'))
                }


                Text('星宿：胃土雉宿星')
                  .attributeModifier(new TextStyleModifier('font_secondary/Body_S/Regular'))
              }
              .alignItems(HorizontalAlign.Start)
            }

            Row() {
              Text(item.daysFromNow.toString())
                .attributeModifier(new TextStyleModifier('font_primary/Body_L/Bold'))
              Text('天后')
                .attributeModifier(new TextStyleModifier('font_secondary/Body_S/Regular'))
            }
          }
          .padding({
            top: 14,
            bottom: 14,
            left: 12,
            right: 12,
          })
          .backgroundColor('#FDF7EE')
          .borderRadius(16)
        }
      }, (item: LuckyDays) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  datePickerBuilder(type: string) {
    DatePickerDialog({
      datePicker: this.datePicker,
      confirm: (date: Date) => {
        if (type === 'start') {
          this.vm.changeDate(date)
        }
        commonActionSheet.close('datePickerBuilder')
        this.jiDayResult = getLuckyMarriageDaysInTwoMonths(this.title, new Date(this.startDate.split(' ')[0]),
          new Date(this.endDate.split(' ')[0]))
      },
      cancel: () => {
        commonActionSheet.close('datePickerBuilder')
      },
      datePickerChange: (value: Date) => {
        if (type === 'end') {
          this.endDate = this.vm.getCurSolarDate(value)
        } else {
          this.getJiDayStartDate(value)
        }
      },
    })
  }

  @Builder
  jiDayOperation() {
    List({ space: 16 }) {
      ListItem() {
        Row() {
          Text('开始')
            .attributeModifier(new TextStyleModifier(`#C4272B/Subtitle_M/Medium`))
          Row({ space: 5 }) {
            Text(this.startDate)
              .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
            Image($r('app.media.right')).width(24).height(24)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.datePicker = new Date(dayjs(this.startDate.split(' ')[0]).format('YYYY-MM-DD'))
          commonActionSheet.show({
            id: 'datePickerBuilder',
            height: 300,
            showClose: false,
            customContent: () => {
              this.datePickerBuilder('start')
            },
          })
        });
      }

      ListItem() {
        Row() {
          Text('结束')
            .attributeModifier(new TextStyleModifier(`#C4272B/Subtitle_M/Medium`))
          Row({ space: 5 }) {
            Text(this.endDate)
              .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
            Image($r('app.media.right')).width(24).height(24)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.datePicker = new Date(dayjs(this.endDate.split(' ')[0]).format('YYYY-MM-DD'))
          commonActionSheet.show({
            id: 'datePickerBuilder',
            height: 300,
            showClose: false,
            customContent: () => {
              this.datePickerBuilder('end')
            },
          })
        });
      }

    }
    .padding({ left: 16, right: 16 })
    .divider(this.egDivider)
    .margin({ bottom: 16, top: 16 })
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: this.title,
      })
      this.jiDayTips()
      this.jiDayOperation()
      this.jiDayFilter()
    }
    .hideTitleBar(true)
  }
}