import {
  CalendarVM,
  commonActionSheet,
  DividerTmp,
  TextStyleModifier,
  ThemeModel,
  DatePickerDialog,
  getCurEndAllDate,
  calculateDaysBetweenDates,
} from 'common';
import { PersistenceV2 } from '@kit.ArkUI';
import dayjs from 'dayjs';

@ComponentV2
export struct CalculationInterval {
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  vm: CalendarVM = CalendarVM.instance;
  @Local datePicker: Date = new Date()
  @Local endDate: string = ''
  @Local startDate: string = ''
  @Local betweenDates: number = 0

  aboutToAppear(): void {
    this.startDate = this.vm.getDateAllLabel()
    this.endDate = getCurEndAllDate(this.vm.getCurDate())
    this.calculateDaysBetweenDates()
  }

  calculateDaysBetweenDates() {
    this.betweenDates = calculateDaysBetweenDates(this.startDate, this.endDate)
  }

  @Builder
  datePickerBuilder(type: string) {
    DatePickerDialog({
      datePicker: this.datePicker,
      confirm: (date: Date) => {
        if (type === 'end') {
          this.endDate = dayjs(date).format('YYYY-MM-DD')
        } else {
          this.startDate = dayjs(date).format('YYYY-MM-DD')
        }
        this.calculateDaysBetweenDates()
        commonActionSheet.close('datePickerBuilder')
      },
      cancel: () => {
        commonActionSheet.close('datePickerBuilder')
      },
    })
  }

  build() {
    Column() {
      Text('查询两个日期的间隔天数')
        .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))

      List({ space: 16 }) {
        ListItem() {
          Row() {
            Text('日期1')
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
            Text('日期2')
              .attributeModifier(new TextStyleModifier(`font_primary/Subtitle_M/Medium`))
            Row({ space: 5 }) {
              Text(dayjs(this.endDate).format('YYYY年MM月DD日'))
                .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Regular`))
              Image($r('app.media.right')).width(24).height(24)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.datePicker = new Date(this.endDate)
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
      Column() {
        Text(`间隔${this.betweenDates.toString()}天`)
          .attributeModifier(new TextStyleModifier(`font_primary/Body_M/Medium`))
      }
      .width('100%')
      .margin({ top: 24 })
      .padding({ top: 12, bottom: 12 })
      .borderRadius(16)
      .backgroundColor('#FDF7EE')
    }
    .height('100%')
    .margin({ top: 18 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}