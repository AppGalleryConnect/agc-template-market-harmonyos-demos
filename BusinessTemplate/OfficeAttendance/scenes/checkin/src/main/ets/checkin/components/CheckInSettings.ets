import { RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { BlankBackground } from '@ohos_agcit/office_attendance_component_lib';
import { BaseResponse } from '@ohos_agcit/office_attendance_network';
import { RequestProxy } from '../../api/RequestProxy';

@Builder
export function checkinSettingBuilder() {
  CheckInSettings();
}

@ComponentV2
export struct CheckInSettings {
  @Local isQuickCheckIn: boolean = false;

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
            Text($r('app.string.settings'))
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
            Column() {
              Text($r('app.string.quick_checkin'))
                .fontColor($r('app.string.black_90'))
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .height(24)
                .margin({ top: 6 })
              Text($r('app.string.quick_checkin_desc'))
                .fontColor($r('app.string.black_60'))
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .height(16)
                .margin({ top: 2 })
            }.alignItems(HorizontalAlign.Start)

            Toggle({ type: ToggleType.Switch, isOn: this.isQuickCheckIn })
              .onChange((isOn: boolean) => {
                RequestProxy.saveIsQuickCheckIn(isOn).then((value: BaseResponse<undefined>) => {
                })
              })

          }.height(56).width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
        }
        .height(200)
        .borderRadius({ topLeft: 32, topRight: 32 })
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.string.white_90'))
        .backdropBlur(54.3656005859375)
      }.alignContent(Alignment.Bottom)
    }
    .mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .onShown(() => {
      RequestProxy.isQuickCheckIn().then((value : boolean) => {
        this.isQuickCheckIn = value;
      })
    });
  }
}