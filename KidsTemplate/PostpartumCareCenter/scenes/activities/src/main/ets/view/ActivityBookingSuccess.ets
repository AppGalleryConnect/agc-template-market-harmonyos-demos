import { ActivityBookingCalenderAddition, MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { ActivityBookingRecordModel } from '@ohos_agcit/postpartum_care_center_utils';

@Builder
export function ActivityBookingSuccessBuilder() {
  ActivityBookingSuccess();
} // 全局自定义构建函数


@Preview
@ComponentV2
struct ActivityBookingSuccess {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local activityBookingRecord: ActivityBookingRecordModel = ActivityBookingRecordModel.createEmptyRec();;
  build() {
    NavDestination() {
      Column() {

        Column() {
          Image($r('app.media.success_flag'))
            .objectFit(ImageFit.Contain)
            .width(48)
            .height(48)
            .margin({
              top: ($r('app.string.border_radius_48'))
            })

          Text($r('app.string.activity_booking_success'))
            .width('100%')
            .fontSize($r('app.string.font_size_16'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0,0,0,0.90)')
            .lineHeight(22)
            .margin({
              top: ($r('app.string.border_radius_12'))
            })
            .textAlign(TextAlign.Center)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          ActivityBookingCalenderAddition({
            activityBookingRecord: this.activityBookingRecord,
            fontSize: 'app.string.font_size_16',
            fontWeight: FontWeight.Medium,
          });
        }
        .padding({
          top: $r('app.string.padding_10'),
          bottom: $r('app.string.padding_9'),
        }) // 设置文字内边距
        .borderRadius($r('app.string.border_radius_20'))
        .backgroundColor('rgba(0,0,0,0.05)')
        .width('100%');
      }
      .padding({
        left: $r('app.string.padding_16'),
        right: $r('app.string.padding_16'),
        bottom: $r('app.string.padding_8'),
      })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween);

    }
    .onReady((context: NavDestinationContext) => {
      this.vm.navStack = context.pathStack;
      this.activityBookingRecord = context.pathInfo.param as ActivityBookingRecordModel;
    })

  }

}