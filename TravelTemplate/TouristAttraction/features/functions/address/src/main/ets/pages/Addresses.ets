import { AddressCardComponent, DeleteConfirmDialog, TitleBar } from 'components';
import { Constant } from 'common';
import { AddressInfo } from 'types';
import { AddressVM } from '../viewmodel/AddressVM';

@Builder
export function AddressesBuilder() {
  Addresses();
}

@ComponentV2
export struct Addresses {
  vm: AddressVM = AddressVM.instance;
  @Local addressId: string = '';
  @Local isFromReserve: boolean = false;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: DeleteConfirmDialog({
      delete: () => {
        this.vm.deleteItemInfo(this.addressId);
      },
      type: 1,
    }),
    customStyle: true,
    autoCancel: true,
  });

  aboutToAppear(): void {
    this.vm.getAddressList();
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TitleBar({
            isShowBack: true, title: '地址管理', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          List({ space: 12 }) {
            ForEach(this.vm.addressList, (item: AddressInfo) => {
              ListItem() {
                AddressCardComponent({
                  address: item,
                  editAddress: () => {
                    this.mainPathStack.pushPathByName('Address', item);
                  },
                  deleteAddress: () => {
                    this.addressId = item.id;
                    if (this.dialogController != null) {
                      this.dialogController.open();
                    }
                  },
                });
              }.onClick(() => {
                if (this.isFromReserve) {
                  this.mainPathStack.popToName('CommodityReserve', item);
                }
              });
            }, (item: AddressInfo) => JSON.stringify(item));
          }.alignListItem(ListItemAlign.Start).scrollBar(BarState.Off).padding({ left: 12, right: 12 });
        }.height('80%');

        Row() {
          Button('新增地址')
            .width(Constant.FULL_PERCENT)
            .fontSize(14)
            .fontWeight(500)

            .backgroundColor('#64BB5C')
            .onClick(() => {
              this.mainPathStack.pushPathByName('Address', null);
            });
        }.padding({ left: 12, right: 12 }).height('10%').position({ y: '90%' });
      }
      .height(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#F1F3F5')
      .padding({ bottom: this.windowBottomHeight });
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.isFromReserve = context.pathInfo.param as boolean;
    });
  }
}