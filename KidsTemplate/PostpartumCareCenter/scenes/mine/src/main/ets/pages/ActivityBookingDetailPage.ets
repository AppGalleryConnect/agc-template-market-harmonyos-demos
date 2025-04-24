import { callDialog, callPhone, MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import {
  ActivityBookingRecordModel,
  ActivityBookingStates,
  Logger,
  PromptActionClass,
} from '@ohos_agcit/postpartum_care_center_utils';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { cancelledImage } from '../view/CommonView';

@Builder
export function ActivityBookingDetailPageBuilder() {
  ActivityBookingDetailPage();
}

const TAG: string = '[ActivityBookingDetailPage]';

@ComponentV2
export struct ActivityBookingDetailPage {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local activityBookingRec: ActivityBookingRecordModel = ActivityBookingRecordModel.createEmptyRec();
  private contentNode: ComponentContent<object> =
    new ComponentContent(this.getUIContext(), wrapBuilder(callDialog), callPhone);

  aboutToAppear(): void {
    this.activityBookingRec =
      this.vm.navStack.getParamByName('ActivityBookingDetailPage')[0] as ActivityBookingRecordModel;
    Logger.debug(JSON.stringify(this.activityBookingRec));
  }

  // 活动地址通过活动支持门店名从门店地址中关联
  build() {
    NavDestination() {
      Column() {

        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Image(this.activityBookingRec.activity?.picDescUrl)
              .width('100%')
              .height('100%')
              .borderRadius($r('app.string.border_radius_8'))
              .margin({ bottom: $r('app.string.margin_l') });

            if (this.activityBookingRec.state === ActivityBookingStates.BOOKING_SUCCESS) {
              Image($r('app.media.booking_success'))
                .width('13%')
                .height('8%')
                .objectFit(ImageFit.Cover);
            } else {
              cancelledImage('small');
            }
          }
          .width('100%')
          .height(170);

          Text($r('app.string.activity_info'))
            .fontSize($r('app.string.font_size_18'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Bold)
            .fontColor('rgba(0,0,0,0.90)')
            .textAlign(TextAlign.Start)
            .margin({ top: $r('app.string.margin_l'), bottom: $r('app.string.margin_xs') });

          Row() {
            Text($r('app.string.activity_name'))
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.60)')
              .margin({ right: $r('app.string.margin_xs') });
            Text(this.activityBookingRec.activity?.name)
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.90)');
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: $r('app.string.margin_xs') });

          Row() {
            Text($r('app.string.activity_booking_phone'))
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.60)')
              .margin({ right: $r('app.string.margin_xs') });
            Text(this.activityBookingRec.phone)
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.90)');
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: $r('app.string.margin_xs') });

          Row() {
            Text($r('app.string.activity_address'))
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.60)')
              .margin({ right: $r('app.string.margin_xs') });
            Row() {
              Text();
              Text(this.vm.storeList.storeList.find(
                store => store.name === this.activityBookingRec.activity?.supportStoreName)?.address)
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.90)')
                .decoration({
                  type: TextDecorationType.Underline,
                  style: TextDecorationStyle.SOLID,
                })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1);
              Image($r('app.media.ic_navigation'))
                .width(16)
                .height(16)
                .margin({ left: $r('app.string.margin_xxs') });
            }
            .width('75%')
            .onClick(() => {
              Logger.debug(TAG, this.activityBookingRec.activity?.supportStoreName!);
              this.vm.queryLocation(
                this.vm.storeList.storeList.find(
                  store => store.name === this.activityBookingRec.activity?.supportStoreName)!);
            });
          }
          .width('100%')
          .justifyContent(FlexAlign.Start);

        }
        .backgroundColor('#FFFFFF')
        .borderRadius($r('app.string.border_radius_16'))
        .padding({
          top: $r('app.string.margin_s'),
          bottom: $r('app.string.margin_14'),
          left: $r('app.string.margin_s'),
          right: $r('app.string.margin_s'),
        })
        .alignItems(HorizontalAlign.Start)
        .margin({ left: $r('app.string.margin_ms'), right: $r('app.string.margin_ms') });

        Column() {

          Row() {
            Image($r('app.media.ic_public_telephone'))
              .width(56)
              .height(56);
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .margin({ bottom: $r('app.string.margin_34') })
          .onClick(() => {
            PromptActionClass.openDialog(this.getUIContext(), this.contentNode);
          });

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Text(this.activityBookingRec.state === ActivityBookingStates.BOOKING_SUCCESS ?
            $r('app.string.booking_cancel_button') : $r('app.string.back'))
              .fontSize($r('app.string.font_size_16'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(0,0,0,0.90)');
          }
          .padding({
            top: $r('app.string.padding_10'),
            bottom: $r('app.string.padding_9'),
          })
          .borderRadius($r('app.string.border_radius_20'))
          .backgroundColor('rgba(0,0,0,0.05)')
          .width('100%')
          .onClick(() => {
            const index =
              this.vm.activityBookingList.findIndex(
                data => data.id === this.activityBookingRec.id &&
                  data.state === ActivityBookingStates.BOOKING_SUCCESS,
              );
            if (index > -1) {
              this.vm.activityBookingList[index].state = ActivityBookingStates.CANCELED;
              this.vm.navStack.pop();
              promptAction.showToast({ message: '预约取消成功' });
            } else {
              this.vm.navStack.pop();
            }
          });

        }
        .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') });

      }
      .height('100%')
      .padding({ top: $r('app.string.padding_8'), bottom: $r('app.string.padding_8') })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .backgroundColor('#F1F3F5')
    .onReady((context: NavDestinationContext) => {
      this.vm.navStack = context.pathStack;
      this.activityBookingRec = context.pathInfo.param as ActivityBookingRecordModel;
    });
  }
}