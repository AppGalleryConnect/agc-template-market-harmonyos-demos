import { calendarManager } from '@kit.CalendarKit';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { StoreBookingRecordItem } from '../model/StoreBookingRecordItem';
import { StoreBookingStatusMap } from '@ohos_agcit/postpartum_care_center_utils';

@Preview
@ComponentV2
export struct StoreBookingCalenderAddition {
  vm: MainEntryVM = MainEntryVM.instance;
  @Param @Require storeBookingRecord: StoreBookingRecordItem;
  @Param fontSize: string = 'app.string.font_size_14';
  @Param fontWeight: FontWeight = FontWeight.Regular;

  build() {
    if (this.storeBookingRecord.status === StoreBookingStatusMap.BOOKING_SUCCESS) {
      Column() {
        Row() {
          Image(this.storeBookingRecord.alreadyAddedToEvent ? $r('app.media.calendar_add_success') :
          $r('app.media.calendar_addition'))
            .height(16)
            .width(16)
            .margin({ right: $r('app.string.margin_xxs') });
          Text(this.storeBookingRecord.alreadyAddedToEvent ? $r('app.string.booking_calendar_add_success') :
          $r('app.string.booking_add_calendar'))
            .fontSize($r(this.fontSize))
            .fontWeight(this.fontWeight)
            .fontColor('rgba(0,0,0,0.90)');
        };
      }
      .onClick(() => {
        if (!this.storeBookingRecord.alreadyAddedToEvent) {
          let event: calendarManager.Event = {
            type: calendarManager.EventType.NORMAL,
            startTime: Date.parse(this.storeBookingRecord.date),
            endTime: Date.parse(this.storeBookingRecord.date) + 60 * 60 * 1000,
            title: '月子中心门店参观预约',
            description: `手机号【${this.storeBookingRecord.telephoneNum}】已成功预约` +
              `月子中心门店【${this.storeBookingRecord.storeName}】参观，请于 ${this.storeBookingRecord.date} 前往参观，谢谢！`,
            reminderTime: [10],
          };

          this.vm.requestCalendarPermission(event, () => {
            for (let i = 0; i < this.vm.storeBookingRecord.length; i++) {
              if (this.vm.storeBookingRecord[i].storeName === this.storeBookingRecord.storeName &&
                this.vm.storeBookingRecord[i].date === this.storeBookingRecord.date) {
                this.storeBookingRecord.alreadyAddedToEvent = true;
                this.vm.storeBookingRecord[i].alreadyAddedToEvent = true;
              }
            }
          });
        }
      });
    }
  }
}