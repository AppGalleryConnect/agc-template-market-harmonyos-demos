import { AddAddressComp, AddressInfo, Constants, SheetHeaderComp, WindowModel } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function AddAddressSheetBuilder(selectAddress: AddressInfo, close: () => void) {
  AddAddressSheet({
    selectAddress,
    close: () => {
      close()
    },
  })
}

@ComponentV2
struct AddAddressSheet {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Param @Require selectAddress: AddressInfo;
  @Event close: () => void = () => {
  }

  build() {
    Column() {
      SheetHeaderComp({
        title: $r('app.string.add_address'),
        close: () => {
          this.close()
        },
      }).margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
      AddAddressComp({
        addressId: this.selectAddress.id, callback: () => {
          this.close()
        },
      })
        .padding({
          top: 8,
          bottom: this.windowModel.getWindowBottomHeight(),
        })
    }.width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
    .height(736)
    .borderRadius({ topLeft: 32, topRight: 32 })
  }
}