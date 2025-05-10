import {
  CalendarVM,
  commonActionSheet,
  DividerTmp,
  TextStyleModifier,
  ThemeModel,
  DatePickerDialog,
  calculateDaysLater,
  LuckyDays,
  TextPickerDialog,
} from 'common';
import { PersistenceV2 } from '@kit.ArkUI';
import dayjs from 'dayjs';

@ComponentV2
export struct CalculationDate {
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  vm: CalendarVM = CalendarVM.instance;
  @Local datePicker: Date = new Date()
  @Local dayCount: string = '3'
  @Local dayList: string[] = ['1', '2', '3', '4', '5', '6', '7']
  @Local startDate: string = ''
  @Local betweenDates: number = 0
  @Local calculateInfo: LuckyDays = new LuckyDays()
  @Local forwardOrBack: boolean = true

  aboutToAppear(): void {
    this.startDate = this.vm.getDateAllLabel()
    this.calculateInfo = calculateDaysLater(this.startDate, Number(this.dayCount),this.forwardOrBack)
  }

  @Builder
  textPickerBuilder() {
    TextPickerDialog({
      dayList: this.dayList,
      selected: this.dayList.findIndex(item => item === this.dayCount),
      confirm: (value: number) => {
        this.dayCount = this.dayList[value]
        commonActionSheet.close()
      },
      cancel: () => {
        commonActionSheet.close()
      },
    })
  }

  @Builder
  datePickerBuilder(type: string) {
    DatePickerDialog({
      datePicker: this.datePicker,
      confirm: (date: Date) => {
        this.startDate = dayjs(date).format('YYYY-MM-DD')
        commonActionSheet.close('datePickerBuilder')
      },
      cancel: () => {
        commonActionSheet.close('datePickerBuilder')
      },
    })
  }

  build() {
    Column() {
      Text('某日期前后几天是什么日子')
        .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))

      List({ space: 16 }) {
        ListItem() {
          Row() {
            Text('起始日')
              .attributeModifier(new TextStyleModifier(`font_primary/Subtitle_M/Medium`))
            Row({ space: 5 }) {
              Text(dayjs(this.startDate).format('YYYY年MM月DD日'))
                .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
              Image($r('app.media.right')).width(24).height(24)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.datePicker = new Date(this.startDate)
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
            Text('天数')
              .attributeModifier(new TextStyleModifier(`font_primary/Subtitle_M/Medium`))
            Row({ space: 5 }) {
              Text(this.dayCount.toString())
                .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
              Image($r('app.media.right')).width(24).height(24)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            commonActionSheet.show({
              id: 'datePickerBuilder',
              height: 300,
              showClose: false,
              customContent: () => {
                this.textPickerBuilder()
              },
            })
          });
        }

        ListItem() {
          Row({ space: 18 }) {
            Row({ space: 5 }) {
              Radio({ value: 'Radio1', group: 'radioGroup' })
                .checked(true)
                .radioStyle({
                  checkedBackgroundColor: this.theme.themeState.current,
                })

              Text('向前')
                .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
            }

            Row({ space: 5 }) {
              Radio({ value: 'Radio1', group: 'radioGroup' })
                .checked(true)
                .radioStyle({
                  checkedBackgroundColor: this.theme.themeState.current,
                })
                .onChange((value) => {
                  this.forwardOrBack = value
                })
              Text('向后')
                .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .onClick(() => {
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
      .divider(this.egDivider)
      .margin({ bottom: 16, top: 16 })

      Button('查询')
        .backgroundColor(this.theme.themeState.current)
        .fontColor(this.theme.themeState.titleColor)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .margin({ top: 48 })
        .onClick(() => {
          this.calculateInfo = calculateDaysLater(this.startDate, Number(this.dayCount),this.forwardOrBack)
        })
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 12 }) {
          Column({ space: 12 }) {
            Text(dayjs(this.calculateInfo.solarDate).format('YYYY.MM-DD').split('-')[0])
              .attributeModifier(new TextStyleModifier(`#C4272B/Body_S/Regular`))
            Text(dayjs(this.calculateInfo.solarDate).format('YYYY.MM-DD').split('-')[1])
              .attributeModifier(new TextStyleModifier(`#C4272B/Title_L/Regular`))
            Text(this.calculateInfo.weekday)
              .attributeModifier(new TextStyleModifier(`#C4272B/Body_S/Regular`))
          }
          .border({
            width: { right: 1 },
            color: { right: '#ccc' },
          })
          .padding({ right: 16 })

          Column({ space: 5 }) {
            Text(this.calculateInfo.lunarDate)
              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
            Row({ space: 5 }) {
              Text(this.calculateInfo.ganZhiYear)
                .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
              Text(this.calculateInfo.ganZhiMonth)
                .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
              Text(this.calculateInfo.ganZhiDay)
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
          Text(this.calculateInfo.daysFromNow.toString())
            .attributeModifier(new TextStyleModifier('font_primary/Body_L/Bold'))
          Text(this.forwardOrBack?'天后':'天前')
            .attributeModifier(new TextStyleModifier('font_secondary/Body_S/Regular'))
        }
      }
      .padding({
        top: 14,
        bottom: 14,
        left: 12,
        right: 12,
      })
      .margin({ top: 24 })
      .backgroundColor('#FDF7EE')
      .borderRadius(16)
    }
    .height('100%')
    .margin({ top: 18 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}