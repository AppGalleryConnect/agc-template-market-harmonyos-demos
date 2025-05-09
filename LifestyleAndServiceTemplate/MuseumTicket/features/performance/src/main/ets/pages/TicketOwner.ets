import { RouterModule, RouterMap, CommonConstants } from 'commonlib';
import { BuyVM } from '../viewModels/BuyVM';
import { Contacts } from '../types/Index';

@Builder
export function TicketOwnerBuilder() {
  TicketOwner();
}


@ComponentV2
struct TicketOwner {
  vm: BuyVM = BuyVM.instance;

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.vm.contactList, (item: Contacts) => {
              Row() {
                Row() {
                  Image($r('app.media.icon_public_teams')).width(24);
                }.width(84).height(84).justifyContent(FlexAlign.Center);

                Column({ space: 6 }) {
                  Text(item.name)
                    .fontWeight(500)
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'));
                  Text(item.cardID.substring(0, 6) + '********' + item.cardID.substring(14))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body3'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'));
                }.alignItems(HorizontalAlign.Start);
              }
              .width('100%')
              .height(84)
              .backgroundColor($r('sys.color.ohos_id_color_background'))
              .borderRadius(8)
              .onClick(() => {
                this.vm.bindTicketOwner(item);
              });
            }, (item: Contacts) => item.personID);
            Row({ space: 10 }) {
              Image($r('app.media.icon_public_plus')).width(16).height(16);
              Text('常用参观人')
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'));
            }
            .width('100%')
            .height(84)
            .backgroundColor($r('sys.color.ohos_id_color_background'))
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.ADD_VISITOR });
            });
          };
        }.align(Alignment.Top)
        .scrollBar(BarState.Off);

      }
      .width('100%')
      .height(CommonConstants.FULL_HEIGHT)
      .padding(10)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'));

    }.title('常用参观人')
    .onShown(() => {
      this.vm.getContactsList();
    }).onReady(() => {
      this.vm.getContactsList();
    });

  }
}