import {
  CalenderAddition,
  callDialog,
  callPhone,
  MainEntryVM,
  StoreBookingRecordItem,
} from '@ohos_agcit/postpartum_care_center_uicomponents';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  Logger,
  PromptActionClass,
  StoreBookingProjectMap,
  StoreBookingStatusMap,
} from '@ohos_agcit/postpartum_care_center_utils';
import { cancelledImage } from '../view/CommonView';

@Builder
export function StoreBookingDetailBuilder() {
  StoreBookingDetail();
}

const NOT_FOUND = -1;

@Preview
@ComponentV2
struct StoreBookingDetail {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local storeBookingRecord: StoreBookingRecordItem = new StoreBookingRecordItem(1, '', '', '', '', 0, 0, '', false);
  private contentNode: ComponentContent<object> =
    new ComponentContent(this.getUIContext(), wrapBuilder(callDialog), callPhone);

  aboutToAppear(): void {
    this.storeBookingRecord = this.vm.navStack.getParamByName('StoreBookingDetail')[0] as StoreBookingRecordItem;
    Logger.debug(JSON.stringify(this.storeBookingRecord));
  }

  build() {
    NavDestination() {
      Column() {

        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Image(this.vm.storeList.storeList.find(store => store.name === this.storeBookingRecord.storeName)?.image)
              .width('100%')
              .height('100%')
              .borderRadius($r('app.string.border_radius_8'))
              .margin({ bottom: $r('app.string.margin_l') });

            if (this.storeBookingRecord.status === StoreBookingStatusMap.BOOKING_SUCCESS) {
              Image($r('app.media.booking_store_success'))
                .width('13%')
                .height('8%')
                .objectFit(ImageFit.Cover);
            } else {
              cancelledImage('small');
            }
          }
          .width('100%')
          .height(170);

          Text('预约信息')
            .fontSize($r('app.string.font_size_18'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Bold)
            .fontColor('rgba(0,0,0,0.90)')
            .textAlign(TextAlign.Start)
            .margin({ top: $r('app.string.margin_l'), bottom: $r('app.string.margin_xs') });

          Row() {
            Text('预约门店')
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.60)')
              .margin({ right: $r('app.string.margin_xs') });
            Text(this.storeBookingRecord.storeName)
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
            Text(this.storeBookingRecord.telephoneNum)
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.90)');
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: $r('app.string.margin_xs') });

          Row() {
            Text('门店地址')
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.60)')
              .margin({ right: $r('app.string.margin_xs') });
            Row() {
              Text();
              Text(this.storeBookingRecord.address)
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
              this.vm.queryLocation(
                this.vm.storeList.storeList.find(
                  store => store.name === this.storeBookingRecord.storeName)!);
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
            Text(this.storeBookingRecord.status === StoreBookingStatusMap.BOOKING_SUCCESS ?
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
              this.vm.storeBookingRecord.findIndex(
                data => data.id === this.storeBookingRecord.id &&
                  data.status === StoreBookingStatusMap.BOOKING_SUCCESS,
              );
            if (index > -1) {
              this.vm.storeBookingRecord[index].status = StoreBookingStatusMap.BOOKING_CANCEL;
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
      this.storeBookingRecord = context.pathInfo.param as StoreBookingRecordItem;
    });
  }
}