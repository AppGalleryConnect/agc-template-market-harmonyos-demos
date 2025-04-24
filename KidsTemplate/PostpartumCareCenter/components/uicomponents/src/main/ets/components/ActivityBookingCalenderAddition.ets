import { calendarManager } from '@kit.CalendarKit';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { StoreBookingRecordItem } from '../model/StoreBookingRecordItem';
import { ActivityBookingRecordModel,
  ActivityBookingStates,
  StoreBookingStatusMap } from '@ohos_agcit/postpartum_care_center_utils';

@Preview
@ComponentV2
export struct ActivityBookingCalenderAddition {
  vm: MainEntryVM = MainEntryVM.instance;
  @Param @Require activityBookingRecord: ActivityBookingRecordModel ;
  @Param fontSize: string = 'app.string.font_size_14';
  @Param fontWeight: FontWeight = FontWeight.Regular;

  build() {
    if (this.activityBookingRecord.state === ActivityBookingStates.BOOKING_SUCCESS) {
      Column() {
        Row() {
          Image(this.activityBookingRecord.addToCalender ? $r('app.media.calendar_add_success') :
          $r('app.media.calendar_addition'))
            .height(16)
            .width(16)
            .margin({ right: $r('app.string.margin_xxs') });
          Text(this.activityBookingRecord.addToCalender ? $r('app.string.booking_calendar_add_success') :
          $r('app.string.booking_add_calendar'))
            .fontSize($r(this.fontSize))
            .fontWeight(this.fontWeight)
            .fontColor('rgba(0,0,0,0.90)');
        };
      }
      .onClick(() => {
        if (!this.activityBookingRecord.addToCalender) {
          let event: calendarManager.Event = {
            type: calendarManager.EventType.NORMAL,
            startTime: this.activityBookingRecord!.activity!.startTime!.getTime(),
            endTime: this.activityBookingRecord!.activity!.endTime!.getTime(),
            title: '月子中心活动预约',
            description: `手机号【${this.activityBookingRecord.phone}】已成功预约` +
              `【${this.activityBookingRecord.activity?.name}】活动，请于 ${this.activityBookingRecord!.activity!.startTime}
              前往门店【${this.activityBookingRecord.activity?.supportStoreName}参加，谢谢！`,
            reminderTime: [10],
          };

          this.vm.requestCalendarPermission(event, () => {
            for (let i = 0; i < this.vm.activityBookingList.length; i++) {
              if (this.vm.activityBookingList[i].id === this.activityBookingRecord.id ) {
                this.activityBookingRecord.addToCalender = true;
                this.vm.activityBookingList[i].addToCalender = true;
              }
            }
          });
        }
      });
    }
  }
}