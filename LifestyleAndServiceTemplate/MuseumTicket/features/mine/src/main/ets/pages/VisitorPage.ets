import { RouterModule, RouterMap, CommonConstants } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';
import { Contacts } from '../types/Index';
import { AlertDialog } from '@kit.ArkUI';

@Builder
export function VisitorPageBuilder() {
  VisitorPage();
}


@ComponentV2
struct VisitorPage {
  vm: MinePageVM = MinePageVM.instance;
  private scrollerForList: ListScroller = new ListScroller();
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要删除该参观人吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.scrollerForList.closeAllSwipeActions();
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.scrollerForList.closeAllSwipeActions();
          this.vm.delContacts();
        },
      },
    }),
  });

  @Builder
  itemEnd(personID: string) {
    Row() {
      Text('删除')
        .padding(5)
        .fontSize(16)
        .backgroundColor($r('sys.color.ohos_id_color_palette8'))
        .fontColor(Color.White)
        .borderRadius(CommonConstants.FONT_SIZE_M)
        .textAlign(TextAlign.Center)
        .width(84)
        .height(84)
        .onClick(() => {
          this.vm.delPersonId = personID;
          this.dialogControllerConfirm.open();
        });
    }.padding(4).justifyContent(FlexAlign.SpaceEvenly);
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        List({ space: 10, scroller: this.scrollerForList }) {
          ForEach(this.vm.contactList, (item: Contacts) => {
            ListItem() {
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
                RouterModule.push({ url: RouterMap.EDIT_VISITOR, param: { contactInfo: item } });
              });
            }.swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(item.personID);
                },
              }, edgeEffect: SwipeEdgeEffect.Spring,
            });
          }, (item: Contacts) => item.personID + item.name + item.phone + item.cardID);

          ListItem() {
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

        }.scrollBar(BarState.Off);

      }
      .width('100%')
      .height(CommonConstants.FULL_HEIGHT)
      .padding(10)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'));

    }.title('常用参观人').onShown(() => {
      this.vm.getContactsList();
    }).onReady(() => {
      this.vm.getContactsList();
    });

  }
}