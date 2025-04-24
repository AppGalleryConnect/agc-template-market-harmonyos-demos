import { ScheduleInfo } from '../../types/Types'
import {
  AppStorageData,
  CommonConstants,
  DialogMap,
  FormatUtil,
  RouterModule
} from '@ohos_agcit/office_attendance_common_lib'
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ScheduleItem {
  @Local myStorage: AppStorageData =
    AppStorageV2.connect(AppStorageData, CommonConstants.APP_STORAGE_DATA_KEY, () => new AppStorageData())!;
  @Event refresh: () => void = () => {
  };
  @Param schedule: ScheduleInfo = { title: '', startTime: '', endTime: '' };

  toDetail() {
    RouterModule.openDialog(DialogMap.SCHEDULE_DETAIL, {
      param: this.schedule.id,
      onPop: () => {
        this.refresh();
      }
    });
  }

  getTime(time: string | undefined): string {
    if (time) {
      return FormatUtil.formatDate(new Date(time), FormatUtil.DATE_24H_mm);
    }
    return '';
  }

  isEnd() {
    if (this.schedule.isAllDay) {
      return false;
    }
    return new Date().getTime() > new Date(this.schedule.endTime).getTime();
  }

  getOpacity() {
    return this.isEnd() ? 0.4 : 1;
  }

  getLocationOpacity() {
    return this.isEnd() ? 0.4 : 0.9;
  }

  build() {
    Row() {
      Column() {
        if (this.schedule.isAllDay) {
          Blank()
          Row()
            .borderColor($r('app.color.purple'))
            .borderRadius($r('app.float.trip_schedule_icon_radius'))
            .borderWidth($r('app.float.trip_schedule_icon_width'))
            .height(CommonConstants.COMMON_FIVE)
            .width(CommonConstants.COMMON_FIVE)
            .margin({ bottom: CommonConstants.COMMON_FIVE })
          Text($r('app.string.whole_day'))
            .fontSize($r('app.float.trip_content_font'))
            .opacity(this.getOpacity())

          Blank()
        } else {
          Text(this.getTime(this.schedule.startTime))
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .opacity(this.getOpacity())
          Row()
            .border({
              style: { left: BorderStyle.Solid },
              color: { left: $r('sys.color.icon_fourth') },
              width: { left: CommonConstants.COMMON_ONE }
            })
            .margin({ left: $r('app.float.trip_icon_margin') })
            .height(CommonConstants.COMMON_SEVEN)
            .width(CommonConstants.COMMON_ONE)

          Row()
            .borderColor($r('app.color.purple'))
            .borderRadius($r('app.float.trip_schedule_icon_radius'))
            .borderWidth($r('app.float.trip_schedule_icon_width'))
            .height(CommonConstants.COMMON_FIVE)
            .width(CommonConstants.COMMON_FIVE)

          Row()
            .border({
              style: { left: BorderStyle.Solid },
              color: { left: $r('sys.color.icon_fourth') },
              width: { left: CommonConstants.COMMON_ONE }
            })
            .margin({ left: $r('app.float.trip_icon_margin') })
            .height(CommonConstants.COMMON_SEVEN)
            .width(CommonConstants.COMMON_ONE)

          Text(this.getTime(this.schedule.endTime))
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .opacity(this.getOpacity())
        }
      }
      .width($r('app.float.trip_icon_width'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height('100%')

      Column({ space: 8 }) {
        Text(this.schedule.title)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .opacity(this.getOpacity())
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(CommonConstants.FULL_PERCENT)

        Text(this.schedule.location)
          .fontSize($r('app.float.font_size_common'))
          .fontWeight(FontWeight.Regular)
          .maxLines(1)
          .opacity(this.getLocationOpacity())
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(CommonConstants.FULL_PERCENT)
      }
      .layoutWeight(CommonConstants.COMMON_ONE)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
      .margin({ right: 12 })
    }
    .backgroundColor($r('app.color.window_background'))
    .height(72)
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(8)
    .onClick(() => {
      this.toDetail();
    })
  }
}