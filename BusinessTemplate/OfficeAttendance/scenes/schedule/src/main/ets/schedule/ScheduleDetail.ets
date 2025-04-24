import { DialogMap, FormatUtil, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { ConfirmView, TitleBar } from '@ohos_agcit/office_attendance_component_lib';
import { RequestProxy } from '../api/RequestProxy';
import { Constants } from '../constants/Constants';
import { ScheduleInfo } from '../types/Types';
import { ScheduleUtils } from '../utils/ScheduleUtils';


@Builder
export function scheduleDetailBuilder() {
  ScheduleDetail();
}

@ComponentV2
export struct ScheduleDetail {
  private scheduleID: string | undefined;
  defSchedule: ScheduleInfo = {
    title: '',
    startTime: '',
    endTime: '',
  };
  @Local schedule: ScheduleInfo = this.defSchedule;

  aboutToAppear(): void {
    this.init();
  }

  init(): void {
    this.scheduleID = RouterModule.getNavParam({ url: DialogMap.SCHEDULE_DETAIL }).param;
    this.load();
  }

  load() {
    if (this.scheduleID) {
      RequestProxy.queryByID(this.scheduleID).then(data => {
        this.schedule = this.defSchedule;
        if (data) {
          this.schedule = data;
        }
      })
    }
  }

  hide() {
    animateTo({
      duration: 300,
      curve: Curve.Friction,
      onFinish: () => {
        RouterModule.popWithParam([], true);
      },
    }, () => {
    });
  }

  getReminderDesc() {
    let desc: string = '';
    let reminderTypes = this.schedule.isAllDay ? Constants.REMINDER_TYPE_4DAY : Constants.REMINDER_TYPE;
    this.schedule.reminderTime?.forEach(t => {
      desc = desc + getContext().resourceManager.getStringSync(reminderTypes.get(t)?.id) + ';';
    })
    return desc;
  }

  private dController: CustomDialogController = new CustomDialogController({
    builder: ConfirmView({
      titleResID: $r('app.string.delete_schedule_title'),
      contentResID: $r('app.string.delete_schedule_content'),
      confirm: () => {
        if (this.schedule.id) {
          RequestProxy.delete(this.schedule.id).then(() => {
            if(this.schedule.eventId){
              ScheduleUtils.deleteEvent(this.schedule.eventId);
            }
          });
        }
        this.hide();
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: false
  })

  gotoEdit() {
    RouterModule.openDialog(DialogMap.EDIT_SCHEDULE, {
      param: this.schedule,
      onPop: () => {
        this.load();
      }
    });
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Column().width('4%')

            TitleBar({
              leftImgResID: 'app.media.ic_public_small_left',
              rightImgResID: '',
              bgColor: Color.White,
              titleResID: 'app.string.schedule_detail_title',
              hide: () => {
                this.hide()
              }
            })
          }.backgroundColor(Color.White)

          Column().height('2%').width('100%').backgroundColor(Color.White)

          Column({ space: 8 }) {
            Row() {
              Column().width('4%')
              /**标题 + 地点 + **/
              Column() {
                Column() {
                  Column().height('14%')

                  TextArea({ text: $$this.schedule.title })
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .opacity(0.6)
                    .backgroundColor(Color.White)
                    .fontColor('#000000')
                    .width('100%')
                    .padding({ left: 0, right: 0 })
                    .enabled(false)
                    .layoutWeight(1)
                  Column().height('14%')
                }.height(96)
                .width('100%')

                Divider().width('100%').height(1)

                /****地点****/

                Column() {
                  Row() {
                    Column() {
                      Text($r('app.string.location_desc'))
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .opacity(0.9)
                        .width(60)
                    }.width(60)
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Start)

                    Column() {
                      Text(this.schedule.location)
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .opacity(0.6)
                    }.layoutWeight(1)
                    .alignItems(HorizontalAlign.End)
                  }.height(21)
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                }
                .layoutWeight(1)
                .width('100%')
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
              }.layoutWeight(1)

              Column().width('4%')
            }
            .width('100%')
            .height(152)
            .backgroundColor(Color.White)


            /****时间****/
            Row() {
              Column().width('4%')

              Column() {
                Row() {
                  Row() {
                    Text($r('app.string.whole_day')).fontSize(16).fontWeight(FontWeight.Medium).opacity(0.9)
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                  .width(80)

                  Row() {
                    Toggle({ type: ToggleType.Switch, isOn: this.schedule.isAllDay })
                      .enabled(false)
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                }.width('100%')
                .height(48)

                Divider().width('90%').height(1)

                Row() {
                  Row() {
                    Text($r('app.string.schedule_begin_time')).fontSize(16).fontWeight(FontWeight.Medium).opacity(0.9)
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                  .width(80)

                  Row() {
                    Row() {
                      Text(FormatUtil.formatDate(new Date(this.schedule.startTime),
                        this.schedule.isAllDay ? FormatUtil.DATE_YYYY_MM_DD : FormatUtil.DATE_YYYY_MM_DD_24H_mm))
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .opacity(0.6)
                    }.justifyContent(FlexAlign.End).width('50%')
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                }.width('100%')
                .height(48)

                Divider().width('90%').height(1)

                Row() {
                  Row() {
                    Text($r('app.string.schedule_end_time')).fontSize(16).fontWeight(FontWeight.Medium).opacity(0.9)
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                  .width(80)

                  Row() {
                    Text(FormatUtil.formatDate(new Date(this.schedule.endTime),
                      this.schedule.isAllDay ? FormatUtil.DATE_YYYY_MM_DD : FormatUtil.DATE_YYYY_MM_DD_24H_mm))
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .opacity(0.6)
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                }.width('100%')
                .height(48)
              }.layoutWeight(1)

              Column().width('4%')
            }
            .width('100%')
            .height(152)
            .backgroundColor(Color.White)


            Row() {
              Column().width('4%')

              Column() {
                Row() {
                  Row() {
                    Text($r('app.string.schedule_repeat'))
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                  .width('50%')

                  Row() {
                    Text(this.schedule.recurrenceRule ? Constants.REPEAT_TYPE.get(this.schedule.recurrenceRule) : '')
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .opacity(0.6)
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .width('50%')
                }.height(48)

                Divider().width('90%').height(1)

                Row() {
                  Row() {
                    Text($r('app.string.schedule_reminder'))
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                  .width('40%')

                  Row() {
                    Text(this.getReminderDesc())
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .opacity(0.6)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)
                      .textAlign(TextAlign.End)
                  }.alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .layoutWeight(1)
                }.height(48)
              }.layoutWeight(1)

              Column().width('4%')
            }.width('100%')
            .backgroundColor(Color.White)


            /****备注****/
            Row() {
              Column().width('4%')

              Column() {
                Column().height('10%')
                Column() {
                  TextArea({ text: this.schedule.desc })
                    .fontSize(16)
                    .fontWeight(FontWeight.Regular)
                    .opacity(0.6)
                    .padding({ left: 0, right: 0 })
                    .backgroundColor(Color.White)
                    .width('100%')
                    .enabled(false)
                }.layoutWeight(1)
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
              }.layoutWeight(1)
              .height('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Start)

              Column().width('4%')
            }
            .width('100%')
            .backgroundColor(Color.White)
            .height('16%')


            Column() {
              Row().height('44%')
                .width('100%')
                .backgroundColor($r('app.color.window_background'))

              Row() {
                Row().height('100%').width('21%')

                Column() {
                  Column() {
                    Image($r('app.media.ic_delete')).width(24).height(24)
                    Row().height('7%')
                    Text($r('app.string.delete_desc')).fontSize(10).fontWeight(FontWeight.Regular).opacity(0.9)
                  }
                  .onClick(() => {
                    this.dController.open();
                  })
                }
                .width('29%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Start)

                Column() {
                  Column() {
                    Image($r('app.media.ic_edit')).width(24).height(24)
                    Row().height('7%')
                    Text($r('app.string.edit_desc')).fontSize(10).fontWeight(FontWeight.Regular).opacity(0.9)
                  }
                  .onClick(() => {
                    this.gotoEdit();
                  })
                }
                .width('29%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.End)

                Row().height('100%').width('21%')
              }.width('100%')
              .alignItems(VerticalAlign.Center)
              .height('36%')
            }
            .width('100%')
            .backgroundColor(Color.White)
            .alignItems(HorizontalAlign.Center)
            .layoutWeight(1)
          }.layoutWeight(1)
        }
      }.height('100%')
      .backgroundColor($r('app.color.window_background'))
    }
    .padding({ top: 35 })
    .mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .backgroundColor(Color.White)
  }
}