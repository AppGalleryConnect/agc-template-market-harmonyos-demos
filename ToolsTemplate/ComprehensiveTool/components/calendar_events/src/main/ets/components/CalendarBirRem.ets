import dayjs from 'dayjs'
import { baseActionSheet } from '../base/ActionSheet';
import { BaseDatePicker } from '../base/BaseDatePicker';
import { EVENT_TYPE } from '../constants/Constants';
import { UserEventItem } from '../model/UserEventModel';
import { RemindEventDispatcher } from '../utils/EventDispatcher';
import { solarToLunar } from '../utils/Utils';
import CalendarEventVM from '../viewModel/ViewModel';
import { CalendarReminder } from './CalendarReminder'

@ComponentV2
export struct CalendarBirRem {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Param type: string = ''
  @Param readonly: boolean = false
  @Param userEventInfo: UserEventItem = new UserEventItem()

  isBirthDay() {
    return this.type === EVENT_TYPE.BIRTHDAY
  }

  aboutToAppear(): void {
    if (this.type === EVENT_TYPE.BIRTHDAY) {
      RemindEventDispatcher.birCallback = () => {
        this.creatUserEventInfo();
      }
    } else {
      RemindEventDispatcher.remCallback = () => {
        this.creatUserEventInfo();
      }
    }
  }

  creatUserEventInfo() {
    this.calendarEventVM.saveEventData(this.userEventInfo, this.getUIContext())
  }

  @Builder
  datePickerBuilder() {
    BaseDatePicker({
      datePicker: this.userEventInfo.date[0].date,
      isShowDateTitle: true,
      datePickerModeIndex: 2,
      isBottom: true,
      isLunar: true,
      isLunarDate: this.userEventInfo.date[0].isLunar,
      cancel: () => {
        baseActionSheet.close('datePickerBuilder')
      },
      confirm: (date: Date) => {
        this.userEventInfo.date[0].lunarDate = solarToLunar(date)
        this.userEventInfo.date[0].date = date
        baseActionSheet.close('datePickerBuilder')
      },
      onLunarChange: (value: boolean) => {
        this.userEventInfo.date[0].isLunar = value
      },
    })
  }

  @Builder
  eventTarget() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text('标题')
          .fontWeight(FontWeight.Medium)
          .width(50)
        TextArea({
          placeholder: this.isBirthDay() ? '生日标题' : '纪念日标题',
          text: this.userEventInfo.content,
        })
          .placeholderColor($r('sys.color.font_secondary'))
          .enabled(!this.readonly)
          .maxLength(50)
          .showCounter(true, { thresholdPercentage: 50, highlightBorder: true })
          .backgroundColor($r('sys.color.background_primary'))
          .placeholderFont({
            size: 14,
          })
          .textAlign(TextAlign.End)
          .onChange((value) => {
            this.userEventInfo.content = value
          })
          .flexGrow(1)
      }
      .width('100%')
      .padding({ top: 5, bottom: 5 })

      Divider()
      Row() {
        Text(this.isBirthDay() ? '生日日期' : '日期')
          .fontWeight(FontWeight.Medium)
        Row() {
          Text(this.userEventInfo.date[0].isLunar ? this.userEventInfo.date[0].lunarDate.split('年')[1] :
          dayjs(this.userEventInfo.date[0].date).format('MM月DD日'))
            .fontSize(14)
            .fontColor(this.readonly ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
          Image(this.readonly ? $r('app.media.chevron_up_grey') : $r('app.media.chevron_up')).width(12).height(24)
        }
      }
      .onClick(() => {
        if (this.readonly) {
          return
        }
        baseActionSheet.show({
          id: 'datePickerBuilder',
          detents: [400, 401],
          showClose: false,
          customContent: () => {
            this.datePickerBuilder()
          },
        }, this.getUIContext())
      })
      .padding({ top: 12, bottom: 12 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
    })
    .margin({ top: 12 })
  }

  @Builder
  eventReminder() {
    Column() {
      CalendarReminder({
        userEventInfo: this.userEventInfo,
        readonly: this.readonly,
      })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
    })
  }

  @Builder
  eventRemarks() {
    TextArea({ placeholder: '请输入备注', text: this.userEventInfo.remarks })
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .enabled(!this.readonly)
      .onChange((value) => {
        this.userEventInfo.remarks = value
      })
      .onFocus(() => {
        RemindEventDispatcher.dispatchInputFocus()
      })
      .onBlur(() => {
        RemindEventDispatcher.dispatchInputBlur()
      })
      .constraintSize({ minHeight: 114 })
      .maxLength(100)
      .showCounter(true, { thresholdPercentage: 1, highlightBorder: true })
  }

  @Builder
  topShow() {
    Row() {
      Text('首页置顶')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: this.userEventInfo.isTop })
        .onChange((value) => {
          this.userEventInfo.isTop = value
        })
        .enabled(!this.readonly)
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .padding(12)
    .borderRadius(16)
  }

  build() {
    Column() {
      List({ space: 12 }) {
        ListItem() {
          this.eventTarget()
        }

        ListItem() {
          this.topShow()
        }

        ListItem() {
          this.eventReminder()
        }

        ListItem() {
          this.eventRemarks()
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
  }
}