import { RouterModule, RouterMap, CommonConstants } from 'commonlib';
import { OrderTicketVM } from '../viewModels/OrderTicketVM';
import { Contacts } from '../types/Index';

@Builder
export function ContactsPageBuilder() {
  ContactsPage();
}


@ComponentV2
struct ContactsPage {
  vm: OrderTicketVM = OrderTicketVM.instance;

  aboutToDisappear(): void {
    this.vm.selectContacts = [];
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.vm.contactList, (item: Contacts) => {
              Row() {
                Row() {
                  Image($r('app.media.icon_public_teams')).width(24);
                }.width(84).height(84).justifyContent(FlexAlign.Center).flexShrink(0);

                Column({ space: 6 }) {
                  Text(item.name)
                    .fontWeight(500)
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'));
                  Text(item.cardID.substring(0, 6) + '********' + item.cardID.substring(14))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body3'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'));
                }.alignItems(HorizontalAlign.Start).flexGrow(1);

                Checkbox()
                  .mark({
                    size: 20,
                  })
                  .selectedColor(CommonConstants.FONT_COLOR_GREEN)
                  .margin({ right: 26 })
                  .flexShrink(0)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.vm.addContacts(item);
                    } else {
                      this.vm.removeContacts(item);
                    }
                  });
              }
              .width('100%')
              .height(84)
              .backgroundColor($r('sys.color.ohos_id_color_background'))
              .justifyContent(FlexAlign.SpaceBetween)
              .borderRadius(8)
              .onClick(() => {
                RouterModule.push({ url: RouterMap.EDIT_VISITOR, param: { contactInfo: item } });
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
          }.constraintSize({ minHeight: CommonConstants.FULL_HEIGHT });
        }.scrollBar(BarState.Off).height('calc(100% - 75vp)');

        Column() {
          Button('预约')
            .type(ButtonType.Normal)
            .borderRadius(20)
            .backgroundColor($r('app.color.font_color_green'))
            .width('calc(100% - 12vp)')
            .onClick(() => {
              this.vm.confirmContacts = JSON.parse(JSON.stringify(this.vm.selectContacts));
              RouterModule.pop();
            });
        }.height(75).justifyContent(FlexAlign.Center).backgroundColor(CommonConstants.BG_COLOR_GRAY);

      }
      .width('100%')
      .height(CommonConstants.FULL_HEIGHT)
      .padding(10)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'));

    }.title('常用参观人')
    .onShown(() => {
      // 编辑后刷新
      this.vm.getContactsList();
    })
    .onReady(() => {
      this.vm.getContactsList();
    });
  }
}