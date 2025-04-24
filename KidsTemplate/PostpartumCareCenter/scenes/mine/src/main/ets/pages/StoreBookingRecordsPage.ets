import { MainEntryVM, StoreBookingRecordItem } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { StoreBookingStatusMap } from '@ohos_agcit/postpartum_care_center_utils';
import { cancelledImage, noRecordView } from '../view/CommonView';

@Builder
export function StoreBookingRecordsPageBuilder() {
  StoreBookingRecordsPage();
}

@Preview
@ComponentV2
struct StoreBookingRecordsPage {
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    NavDestination() {
      List() {
        ForEach(this.vm.storeBookingRecord, (item: StoreBookingRecordItem) => {
          ListItem() {
            Row() {

              Stack({ alignContent: Alignment.TopStart }){
                Image(this.vm.storeList.storeList.find(store => store.name === item.storeName)?.image)
                  .width('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius($r('app.string.border_radius_8'))
                  .padding({ right: $r('app.string.margin_xs') })

                if (item.status === StoreBookingStatusMap.BOOKING_SUCCESS){
                  Image($r('app.media.booking_store_success'))
                    .width('58%')
                    .height('28%')
                    .objectFit(ImageFit.Cover)
                } else{
                  cancelledImage('big')
                }

              }
              .width(96)
              .height(54)
              .margin({ right: 8})

              Column(){
                Text(item.storeName)
                  .fontColor('rgba(0,0,0,0.90)')
                  .fontSize('app.string.font_size_16')
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Start)
                  .height(21)
                  .margin({ bottom: 4 })

                Text(item.address)
                  .fontColor('rgba(0,0,0,0.60)')
                  .fontSize('app.string.font_size_14')
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Regular)
                  .textAlign(TextAlign.Start)
                  .maxLines(2)
                  .height(38)
                  .margin({ bottom: 9 })

               Divider()
                  .color('rgba(0,0,0,0.20)')
                  .padding({ right: 16 })
                  .strokeWidth(1);

              }
              .margin({right: $r('app.string.margin_ms')})
              .alignItems(HorizontalAlign.Start)
            }
            .width('90%')
            .height(87)
            .padding({ left: $r('app.string.margin_ms'), right: $r('app.string.margin_ms'), top: 8})
            .onClick(() => {
              this.vm.navStack.pushPathByName('StoreBookingDetail',item);
            });
          }
          .padding({right: $r('app.string.margin_ms')})
          .margin({right: $r('app.string.margin_ms')})

        }, (item: StoreBookingRecordItem) => JSON.stringify(item));
      }
      .backgroundColor('#FFFFFF').width('100%')

      if (this.vm.storeBookingRecord.length === 0) {
        noRecordView()
      }

    }
    .title('门店预约')

  }

}