import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { ActivityBookingRecordModel, ActivityBookingStates } from '@ohos_agcit/postpartum_care_center_utils';
import { BorderRadiuses } from '@ohos.arkui.node';
import { noRecordView, cancelledImage } from '../view/CommonView';

@Builder
export function ActivityBookingListPageBuilder() {
  ActivityBookingListPage();
}

@ComponentV2
export struct ActivityBookingListPage {
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    NavDestination() {
      List() {
        ForEach(this.vm.activityBookingList, (item: ActivityBookingRecordModel) => {
          ListItem() {
            Row() {

              Stack({ alignContent: Alignment.TopStart }){
                Image(item.activity?.picDescUrl)
                  .width('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius($r('app.string.border_radius_8'))
                  .padding({ right: $r('app.string.margin_xs') })

                if (item.state === ActivityBookingStates.BOOKING_SUCCESS){
                  Image($r('app.media.booking_success'))
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
                Text(item.activity?.name)
                  .fontColor('rgba(0,0,0,0.90)')
                  .fontSize('app.string.font_size_16')
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Start)
                  .height(37)
                  .margin({ bottom: 4 })

                Text(item.activity?.supportStoreName)
                  .fontColor('rgba(0,0,0,0.60)')
                  .fontSize('app.string.font_size_14')
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Regular)
                  .textAlign(TextAlign.Start)
                  .height(16)
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
            .height(80)
            .padding({ left: $r('app.string.margin_ms'), right: $r('app.string.margin_ms'), top: 13})
            .onClick(() => {
              this.vm.navStack.pushPathByName('ActivityBookingDetailPage',item);
            });
          }
          .padding({right: $r('app.string.margin_ms')})
          .margin({right: $r('app.string.margin_ms')})

        }, (item: ActivityBookingRecordModel) => JSON.stringify(item));
      }
      .backgroundColor('#FFFFFF').width('100%')

      if (this.vm.activityBookingList.length === 0) {
        noRecordView()
      }
    }
    .title('活动预约')

  }

}