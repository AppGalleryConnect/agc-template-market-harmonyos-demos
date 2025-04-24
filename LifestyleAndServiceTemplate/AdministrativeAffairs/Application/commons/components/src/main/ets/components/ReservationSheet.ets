import { Calendar, Constants, getNextWeekCalendar, InstitutionsItem, ReservationRecord } from 'common';
import { calendarEventAdd } from '../utils/CalendarUtils';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct ReservationSheet {
  @Param institutionsItem: InstitutionsItem = new InstitutionsItem()
  private calendarList: Calendar[] = []
  @Local currentIndex: number = 0
  @Local reservationIndex: number = 0
  @Local reservationTime: string[] =
    ['9:30-10:30', '10:30-11:30', '11:30-12:30', '14:30-15:30', '15:30-16:30', '16:30-17:30']
  @Event closeSheet: () => void =
    () => {
    };
  @Event recordCommit: (recordList: ReservationRecord) => void =
    (recordList: ReservationRecord) => {
    };

  aboutToAppear(): void {
    this.calendarList = getNextWeekCalendar()
  }

  build() {
    Column() {
      Text(this.institutionsItem.name)
        .fontSize(Constants.FONT_SIZE_LARGE)
        .fontWeight(Constants.FONT_WEIGHT_MEDIUM)
        .margin($r('app.float.institutionsItem_name_margin'))
      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        ForEach(this.calendarList, (item: Calendar, index: number) => {
          Column() {
            Text(item.week).fontColor(this.currentIndex === index ? $r('app.color.record_sheet_color') : Color.Black)
            Text(item.date).fontColor(this.currentIndex === index ? $r('app.color.record_sheet_color') : Color.Black)
          }
          .margin($r('app.float.institutionsItem_name_margin'))
          .borderRadius(Constants.RADIUS_FIVE)
          .border({
            width: { bottom: this.currentIndex === index ? 5 : 0 },
            color: { bottom: this.currentIndex === index ? $r('app.color.record_sheet_color') : Color.White },
          })
          .onClick(() => {
            this.currentIndex = index
          })
        },(item: Calendar) => item.date)
      }

      Divider()
      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        ForEach(this.reservationTime, (item: string, index: number) => {
          Row() {
            Text(item).fontColor(this.reservationIndex === index ? Color.White : Color.Black)
          }
          .padding($r('app.float.institutionsItem_name_padding'))
          .border({
            width: {
              left: $r('app.float.institutionsItem_name_border_size'),
              right: $r('app.float.institutionsItem_name_border_size'),
              top: $r('app.float.institutionsItem_name_border_size'),
              bottom: $r('app.float.institutionsItem_name_border_size'),
            },
            color: this.reservationIndex === index ? $r('app.color.record_sheet_color') : $r('app.color.color_grey'),
          })
          .backgroundColor(this.reservationIndex === index ? $r('app.color.record_sheet_color') :
          $r('sys.color.background_primary'))
          .margin($r('app.float.institutionsItem_name_margin'))
          .borderRadius(Constants.RADIUS_FIVE)
          .onClick(() => {
            this.reservationIndex = index
          })
        }, (item: string) => item)
      }

      Row() {
        Button($r('app.string.common_cancel'))
          .width(Constants.FORTY_PERCENT_WIDTH)
          .backgroundColor($r('app.color.record_sheet_cancel'))
          .fontColor($r('app.color.record_sheet_cancel_color'))
          .onClick(() => {
            this.closeSheet()
          })
        Button($r('app.string.common_submit'))
          .width(Constants.FORTY_PERCENT_WIDTH)
          .backgroundColor($r('app.color.record_sheet_submit_color'))
          .fontColor(Color.White)
          .onClick(() => {
            /*
            * 转化成时间戳之后添加到日历
             * */
            let startTime = this.reservationTime[this.reservationIndex].split('-')[0]
            let endTime = this.reservationTime[this.reservationIndex].split('-')[1]
            let date = this.calendarList[this.currentIndex].date
            let calendarStartTime = new Date(date + ' ' + startTime).valueOf()
            let calendarEndTime = new Date(date + ' ' + endTime).valueOf()
            calendarEventAdd(this.institutionsItem, calendarStartTime, calendarEndTime).then(res => {
              if (res.status === 'Succeeded') {
                promptAction.showToast({ message: $r('app.string.record_success') })
                /*
                 * 返回预约信息
                 * */
                let record: ReservationRecord = {
                  recordName: this.institutionsItem.name,
                  calendarStartTime: calendarStartTime,
                  calendarEndTime: calendarEndTime,
                  eventId: res.data as number,
                }
                this.recordCommit(record)
              } else {
                promptAction.showToast({ message: $r('app.string.record_failed') })
              }
            })
          })
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin($r('app.float.record_sheet_margin'))
      .padding({ right: $r('app.float.record_sheet_padding') })
    }.width(Constants.FULL_PERCENT_WIDTH).alignItems(HorizontalAlign.Start)
  }
}