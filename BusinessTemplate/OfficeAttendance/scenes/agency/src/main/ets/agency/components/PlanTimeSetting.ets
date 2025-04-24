import { DialogMap, FormatUtil, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { DateTimeElement } from '@ohos_agcit/office_attendance_component_lib';

/**
 * 待办任务
 */
@ComponentV2
export struct PlanTimeSetting {
  @Consumer() planDatetime: string = '';
  @Consumer() planTime: DateTimeElement | undefined;
  @Event onDateChange: (d: DateTimeElement) => void = (d: DateTimeElement) => {
  };

  build() {
    Row() {
      Row() {
        Row() {
          Text($r('app.string.select_plan_time'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .opacity(0.9)
        }.alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)

        Row() {
          Text(this.planDatetime === '' ? $r('app.string.new_agency_time_tip') : this.planDatetime)
            .height(30)
            .fontWeight(FontWeight.Regular)
            .fontSize(14)
            .opacity(0.6)

          Image($r('app.media.ic_public_small_right'))
            .height(12)
            .width(12)
        }.layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          RouterModule.openDialog(DialogMap.AGENCY_TASK_CALENDER, {
            param: this.planTime,
            onPop: (data: PopInfo) => {
              this.planTime = (data.result as ESObject).param.dateTime as DateTimeElement;
              this.planDatetime = FormatUtil.formatDate(this.planTime.getDate(), FormatUtil.DATE_YYYY_MM_DD_24H_mm);
              this.onDateChange(this.planTime);
            }
          });
        })
      }
      .borderRadius(5)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height(48)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
  }
}