import { DateElement, TitleBar } from '@ohos_agcit/office_attendance_component_lib';
import { Constants } from '../../constants/Constants';
import { ScheduleInfo } from '../../types/Types';
import { FunctionalButton, functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants, FormatUtil } from '@ohos_agcit/office_attendance_common_lib';
import { ReminderDialog } from './ReminderDialog';
import { i18n } from '@kit.LocalizationKit';

@ComponentV2
export struct ScheduleForm {
  @Consumer() schedule: ScheduleInfo = { title: '', startTime: '', endTime: '' };
  @Consumer() selectedDay: DateElement | undefined;
  private repeatTypeKeys: number[] = Array.from(Constants.REPEAT_TYPE.keys()).sort();
  @Local title: string = '';
  @Local isAllDay: boolean = false;
  @Local startTime: string | undefined;
  @Local endTime: string | undefined;
  @Local recurrenceRule: number = 0;
  @Local reminderTime: number[] = [30];
  @Local location: string | undefined;
  @Local latitude: number | undefined;
  @Local longitude: number | undefined;
  @Local desc: string | undefined;
  @Local reminderTimeDesc: string = '';
  @Param titleResID: string = 'app.string.edit_schedule';
  @Event hide: () => void = () => {
  };
  @Event save: () => void = () => {
  };
  startDate: Date | undefined;
  endDate: Date | undefined;

  aboutToAppear(): void {
    this.init();
  }

  init() {
    this.title = this.schedule.title;
    if (this.schedule.isAllDay) {
      this.isAllDay = this.schedule.isAllDay;
    }
    if (this.schedule.recurrenceRule) {
      this.recurrenceRule = this.schedule.recurrenceRule;
    }
    if (this.schedule.reminderTime) {
      this.reminderTime = this.schedule.reminderTime;
    }
    this.location = this.schedule.location;
    this.latitude = this.schedule.latitude;
    this.longitude = this.schedule.longitude;
    this.desc = this.schedule.desc;
    this.initStartTime();
    this.initEndTime();
    this.initReminderTimeDesc();
  }

  private reminderController: CustomDialogController = new CustomDialogController({
    builder: ReminderDialog({
      reminderTypes: this.schedule.isAllDay ? Constants.REMINDER_TYPE_4DAY : Constants.REMINDER_TYPE,
      callback: (value: Set<number>) => {
        let reminderTime: number[] = [];
        value.forEach(t => {
          reminderTime.push(t);
        })
        this.schedule.reminderTime = reminderTime;
        this.reminderTime = reminderTime;
        this.initReminderTimeDesc();
      },
      selectedItems: new Set(this.reminderTime)
    }),
    alignment: DialogAlignment.Center,
    customStyle: false
  })

  private initStartTime() {
    if (this.schedule.startTime) {
      this.startTime = this.schedule.startTime;
      this.startDate = new Date(this.startTime)
      return;
    }

    let calender = this.getStartCalender();
    let date = new Date(calender.getTimeInMillis())
    if (this.schedule.isAllDay) {
      this.schedule.startTime = FormatUtil.formatDate(date, FormatUtil.DATE_YYYY_MM_DD);
    } else {
      this.schedule.startTime = FormatUtil.formatDate(date, FormatUtil.DATE_YYYY_MM_DD_24H_mm);
    }
    this.startTime = this.schedule.startTime;
    this.startDate = new Date(this.startTime)
  }

  getStartCalender() {
    let calender = i18n.getCalendar(CommonConstants.EN_LOCALE);
    if (this.selectedDay) {
      calender.set(this.selectedDay.year, this.selectedDay.month, this.selectedDay.day);
    }
    if (calender.get(CommonConstants.FIELD_MINUTE) <= 30) {
      calender.set(calender.get(CommonConstants.FIELD_YEAR), calender.get(CommonConstants.FIELD_MONTH),
        calender.get(CommonConstants.FIELD_DAY), calender.get(CommonConstants.FIELD_HOUR), 30, 0);
    } else {
      calender.add(CommonConstants.FIELD_HOUR, 1);
      calender.set(calender.get(CommonConstants.FIELD_YEAR), calender.get(CommonConstants.FIELD_MONTH),
        calender.get(CommonConstants.FIELD_DAY), calender.get(CommonConstants.FIELD_HOUR), 0, 0);
    }
    return calender;
  }

  reformatTime() {
    if (this.startTime) {
      this.startTime = FormatUtil.formatDate(new Date(this.startTime), FormatUtil.DATE_YYYY_MM_DD);
      this.schedule.startTime = this.startTime;
      this.startDate = new Date(this.startTime);
    }
    if (this.endTime) {
      this.endTime = FormatUtil.formatDate(new Date(this.endTime), FormatUtil.DATE_YYYY_MM_DD);
      this.schedule.endTime = this.endTime;
      this.endDate = new Date(this.endTime);
    }
    if (this.schedule.isAllDay) {
      return;
    }

    let startCalender = this.getStartCalender();
    this.startTime =
      this.startTime + ' ' + FormatUtil.formatDate(new Date(startCalender.getTimeInMillis()), FormatUtil.DATE_24H_mm);

    let endCalender = this.getEndCalender();
    this.endTime =
      this.endTime + ' ' + FormatUtil.formatDate(new Date(endCalender.getTimeInMillis()), FormatUtil.DATE_24H_mm);
    this.schedule.startTime = this.startTime;
    this.schedule.endTime = this.endTime;
    this.startDate = new Date(this.startTime);
    this.endDate = new Date(this.endTime);
  }

  private initEndTime() {
    if (this.schedule.endTime) {
      this.endTime = this.schedule.endTime;
      this.endDate = new Date(this.endTime)
      return;
    }

    let calender = this.getEndCalender();
    let date = new Date(calender.getTimeInMillis());
    if (this.schedule.isAllDay) {
      this.schedule.endTime = FormatUtil.formatDate(date, FormatUtil.DATE_YYYY_MM_DD);
    } else {

      this.schedule.endTime = FormatUtil.formatDate(date, FormatUtil.DATE_YYYY_MM_DD_24H_mm);
    }
    this.endTime = this.schedule.endTime;
    this.endDate = new Date(this.endTime)
  }

  getEndCalender() {
    let calender = i18n.getCalendar(CommonConstants.EN_LOCALE);
    if (this.selectedDay) {
      calender.set(this.selectedDay.year, this.selectedDay.month, this.selectedDay.day);
    }
    if (calender.get(CommonConstants.FIELD_MINUTE) <= 30) {
      calender.add(CommonConstants.FIELD_HOUR, 1);
      calender.set(calender.get(CommonConstants.FIELD_YEAR), calender.get(CommonConstants.FIELD_MONTH),
        calender.get(CommonConstants.FIELD_DAY), calender.get(CommonConstants.FIELD_HOUR), 0, 0);
    } else {
      calender.add(CommonConstants.FIELD_HOUR, 1);
      calender.set(calender.get(CommonConstants.FIELD_YEAR), calender.get(CommonConstants.FIELD_MONTH),
        calender.get(CommonConstants.FIELD_DAY), calender.get(CommonConstants.FIELD_HOUR), 30, 0);
    }
    return calender;
  }

  initReminderTimeDesc() {
    let desc: string | undefined;
    let reminderTypes = this.isAllDay ? Constants.REMINDER_TYPE_4DAY : Constants.REMINDER_TYPE;
    this.reminderTime?.sort().forEach(t => {
      if (desc) {
        desc = desc + ';' + getContext().resourceManager.getStringSync(reminderTypes.get(t)?.id)
      } else {
        desc = getContext().resourceManager.getStringSync(reminderTypes.get(t)?.id)
      }
    })
    if (desc) {
      this.reminderTimeDesc = desc;
    } else {
      this.reminderTimeDesc = '';
    }
  }

  changePlanTimeType(v: boolean) {
    this.schedule.isAllDay = v;
    if (v) {
      this.reminderTime = [Constants.REMINDER_ON_DAY_9CLOCK];
    } else {
      this.reminderTime = [Constants.REMINDER_MINUTES_30];
    }
    this.schedule.reminderTime = this.reminderTime;
    this.initReminderTimeDesc();
    this.reformatTime();
  }

  @Builder
  repeatTypeBuilder() {
    Row() {
      Column().width('2%')
      Column() {
        ForEach(this.repeatTypeKeys, (key: number) => {
          Column() {
            Row() {
              Row() {
                Text(Constants.REPEAT_TYPE.get(key))
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width(60)
              .height('100%')

              Row() {
                if (this.recurrenceRule === key) {
                  Image($r('app.media.ic_check_mask')).width(24).height(16)
                }
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .height('100%')
              .layoutWeight(1)
            }.alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.schedule.recurrenceRule = key;
              this.recurrenceRule = key;
            })

            Divider().width('90%').height(1)
          }.height(45)
          .width('100%')
        })
      }.layoutWeight(1)

      Column().width('2%')
    }.width(240)

  }

  build() {
    Row() {
      Column().width('4%').height('100%')

      Column() {
        Column() {
          Column()
            .width('48')
            .height(4)
            .backgroundColor($r('app.color.black'))
            .opacity(0.2)
            .borderRadius(2)
        }.alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(16)

        Row() {
          TitleBar({
            titleResID: this.titleResID,
            hide: () => {
              this.hide()
            },
            callback: () => {
              this.save()
            }
          })
        }.width('100%')

        Column().height('2%')

        Column() {
          /**标题 + 地点 + **/
          Column() {
            Column() {
              TextArea({ placeholder: $r('app.string.schedule_title'), text: $$this.title })
                .placeholderFont({ size: 16, weight: 'medium' })
                .backgroundColor(Color.White)
                .maxLength(50)
                .id('titleID')
                .showCounter(true)
                .padding({ left: 12 })
                .constraintSize({ minHeight: 48, maxHeight: 96 })
                .onChange((data) => {
                  this.schedule.title = data;
                })
            }
            .width('100%')
            .onClick(() => {
              this.getUIContext().getFocusController().requestFocus('titleID');
            })

            Divider().width('90%').height(1)

            /****地点****/
            Column() {
              Column().height('2%')
              Row() {
                Column() {
                  Text($r('app.string.location_desc')).fontSize(16).fontWeight(FontWeight.Medium).opacity(0.9).width(60)
                }.width(60)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Start)

                Row() {
                  Image($r('app.media.ic_location'))
                    .width(12)
                    .height(15)
                    .visibility(this.location ? Visibility.None : Visibility.Visible)
                  FunctionalButton({
                    params: {
                      openType: functionalButtonComponentManager.OpenType.CHOOSE_LOCATION,
                      label: this.location ? this.location : $r('app.string.location_label'),
                      styleOption: {
                        size: functionalButtonComponentManager.SizeType.DEFAULT,
                        plain: true,
                        disabled: false,
                        loading: false,
                        hoverClass: functionalButtonComponentManager.HoverClassType.HOVER_CLASS,
                        hoverStartTime: 0,
                        hoverStayTime: 0,
                        styleConfig: new functionalButtonComponentManager.ButtonConfig()
                          .fontSize(14)
                          .fontColor(this.location ? Color.Black : '#3093FA')
                          .borderWidth(0)
                      },
                    },
                    controller: new functionalButtonComponentManager.FunctionalButtonController()
                      .onChooseLocation((err, data) => {
                        if (err) {
                          hilog.error(0x0000, 'NewSchedule', 'error： %{public}d %{public}s', err.code, err.message);
                          return;
                        }
                        this.schedule.location = data.address;
                        this.location = data.address;
                        this.schedule.longitude = data.longitude;
                        this.schedule.latitude = data.latitude;
                        this.longitude = data.longitude;
                        this.latitude = data.latitude;
                      })
                  })
                }
                .layoutWeight(1)
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.End)
              }.height(21)
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)

              Column().height('2%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 12 })
          }
          .width('100%')
          .constraintSize({ minHeight: 80, maxHeight: 152 })
          .backgroundColor(Color.White)
          .borderRadius(16)

          Column().height('1%').width('100%')

          /****时间****/
          Column() {
            Row() {
              Row() {
                Text($r('app.string.whole_day')).fontSize(16).fontWeight(FontWeight.Medium).opacity(0.9)
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width(80)

              Row() {
                Toggle({ type: ToggleType.Switch, isOn: $$this.isAllDay }).onChange(isOn => {
                  this.changePlanTimeType(isOn);
                })
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .layoutWeight(1)
            }.width('100%')
            .height('34%')

            Divider().width('90%').height(1)

            Row() {
              Row() {
                Text($r('app.string.schedule_begin_time')).fontSize(16).fontWeight(FontWeight.Medium).opacity(0.9)
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width(80)

              Row() {
                Row() {
                  Text(this.startTime)
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .opacity(0.6)
                  Image($r('app.media.ic_public_small_right'))
                    .height(24)
                    .width(12)
                }.justifyContent(FlexAlign.End).width('50%')
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .layoutWeight(1)
            }.width('100%')
            .height('32%')
            .onClick(() => {
              DatePickerDialog.show({
                start: CommonConstants.DATE_START,
                end: CommonConstants.DATE_EDN,
                selected: new Date(this.startTime),
                showTime: !this.isAllDay,
                useMilitaryTime: true,
                cancelButtonStyle: { fontColor: $r('app.color.sys_default_blue') },
                acceptButtonStyle: { fontColor: $r('app.color.sys_default_blue') },
                disappearTextStyle: {
                  color: $r('app.color.date_picker_disappear'),
                  font: { size: '16', weight: FontWeight.Regular }
                },
                textStyle: { color: $r('app.color.date_picker_text'), font: { size: '16', weight: FontWeight.Normal } },
                selectedTextStyle: {
                  color: $r('app.color.sys_default_blue'),
                  font: { size: '18', weight: FontWeight.Bold }
                },
                onDateAccept: (value: Date) => {
                  let diff = 0;
                  if (this.startDate) {
                    diff = value.getTime() - this.startDate.getTime();
                  }
                  if (this.endDate) {
                    this.endDate = new Date(this.endDate.getTime() + diff);
                  }
                  if (this.isAllDay) {
                    this.schedule.startTime = FormatUtil.formatDate(value, FormatUtil.DATE_YYYY_MM_DD)
                    this.schedule.endTime = FormatUtil.formatDate(this.endDate, FormatUtil.DATE_YYYY_MM_DD)
                  } else {
                    this.schedule.startTime = FormatUtil.formatDate(value, FormatUtil.DATE_YYYY_MM_DD_24H_mm)
                    this.schedule.endTime = FormatUtil.formatDate(this.endDate, FormatUtil.DATE_YYYY_MM_DD_24H_mm)
                  }
                  this.startTime = this.schedule.startTime;
                  this.endTime = this.schedule.endTime;
                  this.startDate = value;
                }
              })
            })

            Divider().width('90%').height(1)

            Row() {
              Row() {
                Text($r('app.string.schedule_end_time')).fontSize(16).fontWeight(FontWeight.Medium).opacity(0.9)
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width(80)

              Row() {
                Text(this.endTime)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .opacity(0.6)
                Image($r('app.media.ic_public_small_right'))
                  .height(24)
                  .width(12)
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .layoutWeight(1)
            }.width('100%')
            .layoutWeight(1)
            .onClick(() => {
              DatePickerDialog.show({
                start: CommonConstants.DATE_START,
                end: CommonConstants.DATE_EDN,
                selected: new Date(this.endTime),
                showTime: !this.isAllDay,
                useMilitaryTime: true,
                cancelButtonStyle: { fontColor: $r('app.color.sys_default_blue') },
                acceptButtonStyle: { fontColor: $r('app.color.sys_default_blue') },
                disappearTextStyle: {
                  color: $r('app.color.date_picker_disappear'),
                  font: { size: '16', weight: FontWeight.Regular }
                },
                textStyle: { color: $r('app.color.date_picker_text'), font: { size: '16', weight: FontWeight.Normal } },
                selectedTextStyle: {
                  color: $r('app.color.sys_default_blue'),
                  font: { size: '18', weight: FontWeight.Bold }
                },
                onDateAccept: (value: Date) => {
                  let tmpEndDate = value;
                  if (this.startDate && tmpEndDate.getTime() < this.startDate.getTime()) {
                    tmpEndDate = new Date(this.startDate.getTime() + CommonConstants.HALF_HOUR)
                  }
                  if (this.isAllDay) {
                    this.schedule.endTime = FormatUtil.formatDate(tmpEndDate, FormatUtil.DATE_YYYY_MM_DD)
                  } else {
                    this.schedule.endTime = FormatUtil.formatDate(tmpEndDate, FormatUtil.DATE_YYYY_MM_DD_24H_mm)
                  }
                  this.endTime = this.schedule.endTime
                  this.endDate = tmpEndDate;
                },
              })
            })
          }
          .width('100%')
          .height(152)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .padding({ left: 12 })


          Column().height('1%').width('100%')

          Column() {
            Row() {
              Row() {
                Text($r('app.string.schedule_repeat'))
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width('50%')

              Row() {
                Text(Constants.REPEAT_TYPE.get(this.recurrenceRule))
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .opacity(0.6)
                Image($r('app.media.ic_public_small_right'))
                  .height(24)
                  .width(12)
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .width('50%')
            }.height('50%')
            .bindMenu(this.repeatTypeBuilder, { placement: Placement.Right })

            Divider().width('90%').height(1)

            Row() {
              Row() {
                Text($r('app.string.schedule_reminder'))
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width('40%')

              Row() {
                Text(this.reminderTimeDesc)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .opacity(0.6)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)

                Image($r('app.media.ic_public_small_right'))
                  .height(24)
                  .width(12)
              }.alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .width('60%')
            }.layoutWeight(1)
            .onClick(() => {
              this.reminderController.open();
            })
          }
          .width('100%')
          .height(104)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .padding({ left: 12 })

          Column().height('1%').width('100%')

          /****备注****/
          Row() {
            TextArea({ placeholder: $r('app.string.description'), text: $$this.desc })
              .placeholderFont({ size: 16, weight: 'medium' })
              .backgroundColor(Color.White)
              .maxLength(100)
              .constraintSize({ minHeight: 56, maxHeight: 112 })
              .showCounter(true)
              .onChange(data => {
                this.schedule.desc = data;
              })
              .padding({ left: 12, top: 12 })
              .id('description')
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Top)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            this.getUIContext().getFocusController().requestFocus('description');
          })
        }
      }.layoutWeight(1)
      .height('100%')

      Column().width('4%').height('100%')

    }
    .width('100%')
    .height('90%')
    .backgroundColor('#FAFAFA')
    .borderRadius({ topLeft: 32, topRight: 32 })
  }
}
