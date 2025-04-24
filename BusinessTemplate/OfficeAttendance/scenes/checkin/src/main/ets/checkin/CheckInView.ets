import { curves } from '@kit.ArkUI';
import { DialogMap, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { RequestProxy } from '../api/RequestProxy';
import { CheckInHistoryDetailDataItem } from '../types/Types';
import { CheckInComponent } from './components/CheckInComponent';

@ComponentV2
export struct CheckInView {
  @Local checkinFirstTime: string = '';
  @Local checkinLastTime: string = '';
  @Local imageOpacity: number = 1;
  @Local timerId: number = 0;

  aboutToAppear() {
    this.refreshCheckDetail();
    this.timerId = setInterval(() => {
      this.imageOpacity = this.imageOpacity === 1 ? 0 : 1; // 切换透明度
    }, 800);
  }

  private refreshCheckDetail() {
    RequestProxy.getTodayCheckInDetail().then((value: CheckInHistoryDetailDataItem[]) => {
      this.checkinFirstTime = value[0].time;
      this.checkinLastTime = value[value.length - 1].time;
    });
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId); // 页面退出时，取消定时器
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
      CheckInComponent({
        onCheckIn: () => {
          this.refreshCheckDetail()
        }
      }).flexGrow(1)

      Column() {
        Image($r('app.media.double_arrow_up'))
          .height(16)
          .width(80)
          .opacity(this.imageOpacity)
          .animation({ duration: 800, curve: curves.springMotion() })
          .margin({ top: 4 })
          .onClick(() => {
            RouterModule.openDialog(DialogMap.CHECK_IN_HISTORY)
          })
        Row() {
          Column() {
            Text($r('app.string.checkin_first_time')).fontSize(14).fontColor($r('app.string.white_60')).height(20)
            Text(this.checkinFirstTime).fontSize(18).fontColor(Color.White).height(24)
          }.alignItems(HorizontalAlign.Start)

          Column() {
            Text($r('app.string.checkin_last_time')).fontSize(14).fontColor($r('app.string.white_60')).height(20)
            Text(this.checkinLastTime).fontSize(18).fontColor(Color.White).height(24)
          }.alignItems(HorizontalAlign.Start)
        }
        .margin({ top: 24 })
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')
      }
      .flexShrink(0)
      .height(113)
      .width('100%')
      .borderRadius({ topLeft: 36, topRight: 36 })
      .backgroundColor($r('app.color.checkin_background'))
      .align(Alignment.Top)
      .gesture(
        PanGesture({ direction: PanDirection.Up }).onActionEnd(() => {
          RouterModule.openDialog(DialogMap.CHECK_IN_HISTORY)
        })
      )
    }.height('100%')
  }
}