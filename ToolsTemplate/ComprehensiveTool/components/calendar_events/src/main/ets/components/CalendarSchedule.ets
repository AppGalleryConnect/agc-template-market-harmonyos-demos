import dayjs from 'dayjs'
import { BaseDatePicker } from '../base/BaseDatePicker';
import { BaseTimerPicker } from '../base/BaseTimerPicker';
import { reminderMenuList } from '../constants/Constants';
import { DividerTmp } from '../model/DividerTmp';
import { BaseTextStyleModifier } from '../model/TextStyleModifier';
import {
  CalendarEvent,
  CalendarStartDate,
  reminderList,
  ReminderType,
  UserEventItem,
} from '../model/UserEventModel';
import { RemindEventDispatcher } from '../utils/EventDispatcher';
import { solarToLunar } from '../utils/Utils';
import CalendarEventVM from '../viewModel/ViewModel';
import { CalendarReminder } from './CalendarReminder'

@ComponentV2
export struct CalendarSchedule {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Local calendarEventList: CalendarEvent = new CalendarEvent()
  @Local isLunarShow: boolean = false
  @Local isLunar: boolean = true
  @Local reminderList: ReminderType[] = reminderList
  @Param userEventInfo: UserEventItem = new UserEventItem()
  @Param readonly: boolean = false

  aboutToAppear(): void {
    RemindEventDispatcher.scheduleCallback = () => {
      this.creatUserEventInfo();
    };
  }

  creatUserEventInfo() {
    this.calendarEventVM.saveEventData(this.userEventInfo, this.getUIContext())
  }

  @Builder
  calendarEventContent() {
    TextArea({ placeholder: '请输入日程内容', text: this.userEventInfo.content })
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .enabled(!this.readonly)
      .onChange((value) => {
        this.userEventInfo.content = value
      })
      .constraintSize({ minHeight: 56 })
      .maxLength(50)
      .showCounter(true, { thresholdPercentage: 1, highlightBorder: true })
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

  setDateLunar(isOn:boolean) {

    this.userEventInfo.date.forEach(item => item.isLunar = isOn)
  }

  @Builder
  calendarEventTime() {
    List({ space: 16 }) {
      ForEach(this.userEventInfo.date, (item: CalendarStartDate, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Text(index ? '结束' : '开始')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
              Row({ space: 5 }) {
                Row() {
                  Text(item.isLunar ? item.lunarDate : dayjs(item.date).format('YYYY年MM月DD日'))
                    .attributeModifier(new BaseTextStyleModifier(`${this.readonly ? 'font_secondary' :
                      this.calendarEventList.calendarEventList[index].localDateSelected ? '#C4272B' :
                        'font_primary'}/Body_M/Regular`))
                }
                .onClick(() => {
                  if (this.readonly) {
                    return
                  }
                  this.calendarEventList.calendarEventList[index].localDateTimeSelected = false
                  this.calendarEventList.calendarEventList[index].localDateSelected =
                    !this.calendarEventList.calendarEventList[index].localDateSelected
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
                  Text(item.time)
                    .attributeModifier(new BaseTextStyleModifier(`${this.readonly ? 'font_secondary' :
                      this.calendarEventList.calendarEventList[index].localDateTimeSelected ? '#C4272B' :
                        'font_primary'}/Body_M/Regular`))
                }
                .onClick(() => {
                  if (this.readonly) {
                    return
                  }
                  this.calendarEventList.calendarEventList[index].localDateTimeSelected =
                    !this.calendarEventList.calendarEventList[index].localDateTimeSelected
                  this.calendarEventList.calendarEventList[index].localDateSelected = false
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
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .justifyContent(FlexAlign.SpaceBetween)

            BaseDatePicker({
              datePicker: new Date(item.date),
              isOperationShow: true,
              isBottom: true,
              isLunar: true,
              isLunarDate: item.isLunar,
              confirm: (value: Date) => {
                item.lunarDate = solarToLunar(value)
                item.date = value
                this.calendarEventList.calendarEventList[index].localDateSelected = false
              },
              cancel: () => {
                this.calendarEventList.calendarEventList[index].localDateSelected = false
              },
              onLunarChange: (value: boolean) => {
                this.setDateLunar(value)
              },
            })
              .visibility(
                this.calendarEventList.calendarEventList[index].localDateSelected ? Visibility.Visible :
                Visibility.None)
            BaseTimerPicker({
              selectedTime: new Date(`${dayjs(this.userEventInfo.date[index].date)
                .format('YYYY-MM-DD')}T${this.userEventInfo.date[index].time}`),
              confirm: (value: TimePickerResult) => {
                if (value) {
                  item.time = this.dateTimeFormat(value)
                }
                this.calendarEventList.calendarEventList[index].localDateTimeSelected = false
              },
              cancel: () => {
                this.calendarEventList.calendarEventList[index].localDateTimeSelected = false
              },
            })
              .visibility(
                this.calendarEventList.calendarEventList[index].localDateTimeSelected ? Visibility.Visible :
                Visibility.None,
              )
          }
        }
      }, (item: CalendarStartDate) => JSON.stringify(item))

    }
    .scrollBar(BarState.Off)
    .divider(this.egDivider)
    .edgeEffect(EdgeEffect.None)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  reminderMenu() {
    Menu() {
      ForEach(reminderMenuList, (item: string) => {
        MenuItem({ content: item })
          .onClick(() => {
            this.userEventInfo.repeatType = item
          })
          .enabled(!this.readonly)
      }, (item: string) => item)
    }
    .width(224)
  }

  @Builder
  calendarEventReminder() {
    List() {
      ListItem() {
        Row() {
          Text('重复').fontWeight(FontWeight.Medium)
          Row() {
            Text(this.userEventInfo.repeatType)
              .fontSize(14)
              .fontColor(this.readonly ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
            Image(this.readonly ? $r('app.media.chevron_up_grey') : $r('app.media.chevron_up')).width(12).height(24)
          }
          .bindMenu(this.reminderMenu)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 12, bottom: 12 })
      }

      ListItem() {
        CalendarReminder({
          userEventInfo: this.userEventInfo,
          readonly: this.readonly,
        })
      }
    }
    .scrollBar(BarState.Off)
    .divider(this.egDivider)
    .borderRadius(16)
    .edgeEffect(EdgeEffect.None)
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  calendarEventRemarks() {
    TextArea({ placeholder: '请输入备注', text: this.userEventInfo.remarks })
      .backgroundColor($r('sys.color.background_primary'))
      .enabled(!this.readonly)
      .borderRadius(16)
      .constraintSize({ minHeight: 56 })
      .maxLength(100)
      .showCounter(true, { thresholdPercentage: 1, highlightBorder: true })
      .onChange((value) => {
        this.userEventInfo.remarks = value
      })
  }

  build() {
    Column() {
      List({ space: 16 }) {
        ListItem() {
          this.calendarEventContent()
        }

        ListItem() {
          this.calendarEventTime()
        }

        ListItem() {
          this.calendarEventReminder()
        }

        ListItem() {
          this.calendarEventRemarks()
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .margin({ top: 16 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
  }
}
