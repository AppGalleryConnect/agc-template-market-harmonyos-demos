import { Logger } from '@ohos_agcit/postpartum_care_center_utils';
import { StoreBookingRecordItem } from '../model/StoreBookingRecordItem';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { StoreBookingCalenderAddition } from './CalenderAddition';

@Builder
export function BookingSuccessBuilder() {
  BookingSuccess();
}

const TAG: string = '[testTagBookingSuccess]';

@Entry
@Preview
@ComponentV2
struct BookingSuccess {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local storeBookingRecord: StoreBookingRecordItem = new StoreBookingRecordItem(1, '', '', '', '', 0, 0, '', false);

  build() {
    NavDestination() {
      Column() {
        Column() {
          Image($r('app.media.ic_success_lined'))
            .height(40)
            .width(40)
            .margin({ top: $r('app.string.margin_57'), bottom: $r('app.string.margin_ms') });
          Text($r('app.string.booking_success_message'))
            .fontSize($r('app.string.font_size_16'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0,0,0,0.90)');
        };

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          StoreBookingCalenderAddition({
            storeBookingRecord: this.storeBookingRecord,
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
      this.storeBookingRecord = context.pathInfo.param as StoreBookingRecordItem;
      Logger.debug(TAG, `Booking original storeName: ${this.storeBookingRecord}`);
    });
  }
}