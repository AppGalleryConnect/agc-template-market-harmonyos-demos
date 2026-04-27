import dayjs from 'dayjs'
import { BaseDatePicker } from '../base/BaseDatePicker';
import { BaseTimerPicker } from '../base/BaseTimerPicker';
import { BaseTextStyleModifier } from '../model/TextStyleModifier';
import { UserEventItem } from '../model/UserEventModel';
import { RemindEventDispatcher } from '../utils/EventDispatcher';
import { solarToLunar } from '../utils/Utils';
import CalendarEventVM from '../viewModel/ViewModel';

@ComponentV2
export struct CalendarTodo {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local localDateSelected: boolean = false
  @Local localDateTimeSelected: boolean = false
  @Param userEventInfo: UserEventItem = new UserEventItem()
  @Param readonly: boolean = false

  aboutToAppear(): void {
    RemindEventDispatcher.todoCallback = () => {
      this.creatUserEventInfo();
    };
  }

  creatUserEventInfo() {
    this.calendarEventVM.saveEventData(this.userEventInfo, this.getUIContext())
  }

  dateTimeFormat(value: TimePickerResult) {
    let hour: string = value.hour.toString()
    let minute: string = value.minute.toString()
    if (value.hour < 10) {
      hour = `0${value.hour}`
    }
    if (value.minute < 10) {
      minute = `0${value.minute}`
    }
    return `${hour}:${minute}`
  }

  build() {
    Column({ space: 12 }) {
      Column() {
        TextArea({ placeholder: '请输入待办内容', text: this.userEventInfo.content })
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(16)
          .enabled(!this.readonly)
          .constraintSize({ minHeight: 114 })
          .maxLength(100)
          .onChange(value => {
            this.userEventInfo.content = value
          })
          .showCounter(true, { thresholdPercentage: 1, highlightBorder: true })
      }
      .visibility(this.readonly ? Visibility.None : Visibility.Visible)
      .margin({ top: 12 })

      Row({ space: 18 }) {
        Checkbox({ name: 'checkbox2', group: 'checkboxGroup' })
          .select(this.userEventInfo.isDone)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .enabled(!this.readonly)
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .onChange((value: boolean) => {
            this.userEventInfo.isDone = !this.userEventInfo.isDone
          })
        Column({ space: 5 }) {
          Text(this.userEventInfo.content)
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .fontColor(this.userEventInfo.isDone ? '#969696' : $r('sys.color.font_primary'))
        }
        .width('80%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding(12)
      .margin({ top: 8 })
      .borderRadius(16)
      .width('100%')
      .backgroundColor($r('sys.color.background_primary'))
      .visibility(this.readonly ? Visibility.Visible : Visibility.None)

      Column() {
        Row() {
          Text('提醒时间')
            .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
          Row({ space: 5 }) {
            Row() {
              Text(this.userEventInfo.date[0].isLunar ?
              this.userEventInfo.date[0].lunarDate : dayjs(this.userEventInfo.date[0].date).format('YYYY年MM月DD日'))
                .attributeModifier(new BaseTextStyleModifier(`${this.localDateSelected ? '#C4272B' :
                  'font_primary'}/Body_M/Regular`))
            }
            .onClick(() => {
              if (this.readonly) {
                return
              }
              this.localDateTimeSelected = false
              this.localDateSelected = !this.localDateSelected
            })
            .padding({
              left: 12,
              right: 12,
              top: 5,
              bottom: 5,
            })
            .borderRadius(56)
            .backgroundColor($r('sys.color.background_secondary'))

            Row() {
              Text(this.userEventInfo.date[0].time)
                .attributeModifier(new BaseTextStyleModifier(`${this.localDateTimeSelected ? '#C4272B' :
                  'font_primary'}/Body_M/Regular`))
            }
            .onClick(() => {
              if (this.readonly) {
                return
              }
              this.localDateTimeSelected = !this.localDateTimeSelected
              this.localDateSelected = false
            })
            .padding({
              left: 12,
              right: 12,
              top: 5,
              bottom: 5,
            })
            .borderRadius(56)
            .backgroundColor($r('sys.color.background_secondary'))
          }
        }
        .backgroundColor($r('sys.color.background_primary'))
        .width('100%')

        .justifyContent(FlexAlign.SpaceBetween)

        BaseDatePicker({
          datePicker: new Date(this.userEventInfo.date[0].date),
          isOperationShow: true,
          isBottom: true,
          isLunar: true,
          isLunarDate: this.userEventInfo.date[0].isLunar,
          confirm: (value: Date) => {
            this.userEventInfo.date[0].lunarDate = solarToLunar(value)
            this.userEventInfo.date[0].date = value
            this.localDateSelected = false
          },
          cancel: () => {
            this.localDateSelected = false
          },
          onLunarChange: (value: boolean) => {
            this.userEventInfo.date[0].isLunar = value
          },
        })
          .visibility(this.localDateSelected ? Visibility.Visible : Visibility.None)
        BaseTimerPicker({
          selectedTime: new Date(`${dayjs(this.userEventInfo.date[0].date)
            .format('YYYY-MM-DD')} ${this.userEventInfo.date[0].time}`),
          confirm: (value: TimePickerResult) => {
            if (value) {
              dayjs(this.userEventInfo.date[0].time = this.dateTimeFormat(value))
            }
            this.localDateTimeSelected = false
          },
          cancel: () => {
            this.localDateTimeSelected = false
          },
        })
          .visibility(this.localDateTimeSelected ? Visibility.Visible : Visibility.None)
      }
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .padding(12)
    }
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}