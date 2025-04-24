import { DateUtils, RouterModule, WindowUtil } from '@ohos_agcit/office_attendance_common_lib';
import { BlankBackground } from '@ohos_agcit/office_attendance_component_lib';
import { RequestProxy } from '../../api/RequestProxy';
import { CheckInHistoryDataItem } from '../../types/Types';
import { CheckInHistoryItem } from './CheckInHistoryItem';

@Builder
export function checkinHistoryBuilder() {
  CheckInHistory();
}

@Preview
@ComponentV2
export struct CheckInHistory {
  private checkInHistories: CheckInHistoryDataItem[] = []
  @Local month: string | Resource = '';
  @Local checkInHistoryHeight: number = 520;
  private controller: Scroller = new Scroller();

  build() {
    NavDestination() {
      Stack() {
        BlankBackground();
        Column() {
          Row() {
            Divider()
              .height(4)
              .width(48)
              .borderRadius(2)
              .backgroundColor($r('app.string.black_20'))
              .color($r('app.string.black_20'))
              .margin({ top: 8 })
          }.height(16).width(96).justifyContent(FlexAlign.Center)

          Row() {
            Text($r('app.string.checkin_history'))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.string.black_90'))
            Blank()

            Stack() {
              Circle().height('100%').width('100%').fill('rgba(0,0,0,0.05)')
              Image($r('app.media.xmark')).height(18).width(18)
            }.height(40).width(40).onClick(() => RouterModule.pop())
          }.height(40).width('100%')

          Row() {
            Text(this.month)
              .fontColor($r('app.string.black_90'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ top: 16 })
          }

          List({ scroller: this.controller }) {
            ForEach(this.checkInHistories, (item: CheckInHistoryDataItem, index) => {
              ListItem() {
                CheckInHistoryItem({
                  'dayDesc': this.getDayDesc(item.dayOfWeek, item.day),
                  'day': this.getDayNumber(item.day),
                  'index': index,
                  'details': item.details
                })
              }
            })
          }
          .width('100%')
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Off)
        }
        .height(this.checkInHistoryHeight)
        .borderRadius({ topLeft: 32, topRight: 32 })
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.string.white_90'))
        .backdropBlur(54.3656005859375)
      }.align(Alignment.Bottom)
      .onAreaChange((oldValue, newValue) => {
        this.calculateDialogHeight();
      })
    }.mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }

  getDayDesc(dayOfWeek: number, day: string): Resource {
    if (DateUtils.isToday(day)) {
      return $r('app.string.today')
    }
    const dayOfWeekDesc = 'app.string.day_of_week_' + dayOfWeek;
    return $r(dayOfWeekDesc);
  }

  getDayNumber(day: string): string {
    return day.split('-')[2];
  }

  aboutToAppear() {
    this.calculateDialogHeight();
    RequestProxy.queryCheckInHistories().then((value: CheckInHistoryDataItem[]) => {
      this.checkInHistories = value;
      this.month = this.getMothDesc(value[0].day)
    })
  }

  getMothDesc(day: string): Resource {
    const month: string = day.split('-')[1];
    const monthDesc = 'app.string.month_desc_' + month;
    return $r(monthDesc);
  }

  private calculateDialogHeight() {
    const height = WindowUtil.getInstance()?.getAppStorageData().windowHeightVp as number;
    if (height - 56 - 36 > 520) { // 如何实际显示内容区域高于高保真设计的高度435，则按百分之百显示，否则按高保真高度显示
      this.checkInHistoryHeight = 520
      return;
    }

    this.checkInHistoryHeight = height - 56 - 36;
  }
}