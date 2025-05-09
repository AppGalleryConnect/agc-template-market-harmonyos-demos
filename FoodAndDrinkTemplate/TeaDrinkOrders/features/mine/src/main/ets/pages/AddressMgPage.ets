import {
  AddressInfo,
  AddressTagEnum,
  addressTagMap,
  BaseResponse,
  Constants,
  EmptyComp,
  HttpCode,
  HttpRequestApi,
  NavHeaderBar,
  RouterMap,
  Utils,
} from 'common/Index';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Builder
export function AddressMgPageBuilder() {
  AddressMgPage()
}

@ComponentV2
struct AddressMgPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local addressList: Array<AddressInfo> = []

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.address_mg') })
      Column() {
        Row() {
          Image($r('app.media.ic_plus')).width(28).height(28).onClick(() => {
            this.pageStack?.pushPathByName(RouterMap.ADD_ADDRESS_PAGE, null)
          })
        }
        .width(Constants.FULL_SIZE)
        .margin({ top: 16, right: Constants.BORDER_WIDTH })
        .justifyContent(FlexAlign.End)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })

        Column() {
          List({ space: 8 }) {
            ForEach(this.addressList, (address: AddressInfo) => {
              ListItem() {
                Row() {
                  Column() {
                    Row() {
                      if (address.tag) {
                        Text(addressTagMap[address.tag])
                          .fontSize(10)
                          .fontColor(this.getTagFontColor(address.tag))
                          .borderRadius(4)
                          .padding({
                            top: 2,
                            bottom: 2,
                            left: 8,
                            right: 8,
                          })
                          .backgroundColor(this.getTagBgColor(address.tag))
                          .margin({ right: 4 })
                      }

                      Text(`${address.addressPre}${address.addressNum}`)
                        .fontSize(14)
                        .fontColor($r('sys.color.font_primary'))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                    }

                    Row() {
                      Text(address.name).fontSize(12).fontColor($r('sys.color.mask_secondary'))
                      Text(Utils.getAnonymousTel(address.tel))
                        .fontSize(12)
                        .fontColor($r('sys.color.mask_secondary'))
                        .margin({ left: 12 })
                    }.margin({ top: 9 })
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                  Image($r('app.media.ic_modify')).width(32).margin({ left: 8 })
                }
                .width(Constants.FULL_SIZE)
                .justifyContent(FlexAlign.SpaceBetween)
                .borderRadius(16)
                .backgroundColor(Color.White)
                .constraintSize({ maxWidth: Constants.FULL_SIZE })
                .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
                .padding({
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                })
                .onClick(() => {
                  this.pageStack?.pushPathByName(RouterMap.ADD_ADDRESS_PAGE, address.id)
                })
              }
              .swipeAction({
                end: {
                  builder: () => {
                    this.deleteCard(address.id)
                  },
                },
              })
            }, (address: AddressInfo) => JSON.stringify(address))
          }.width(Constants.FULL_SIZE).scrollBar(BarState.Off).margin({ bottom: 16 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 16 })
        .layoutWeight(1)
        .visibility(this.addressList.length ? Visibility.Visible : Visibility.None)

        // 空数据展示
        Column() {
          EmptyComp()
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .visibility(this.addressList.length ? Visibility.None : Visibility.Visible)
      }
      .width(Constants.FULL_SIZE)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true).onShown(() => {
      this.getUserAddressList()
    })
  }

  @Builder
  deleteCard(id: number) {
    Column() {
      Image($r('app.media.ic_delete')).width(16)
      Text($r('app.string.delete'))
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.white'))
        .margin({ top: 8 })
    }
    .backgroundColor('#FF0000')
    .width(78)
    .height(Constants.FULL_SIZE)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .margin({ right: Constants.BORDER_WIDTH })
    .onClick(() => {
      HttpRequestApi.deleteUserAddress(id).then((resp: BaseResponse) => {
        if (resp.code === HttpCode.SUCCESS) {
          this.getUserAddressList()
        } else {
          promptAction.showToast({ message: $r('app.string.deleteFailed') })
        }
      }).catch((e: BusinessError) => {
        promptAction.showToast({ message: $r('app.string.deleteFailed') })
        console.error(`deleteUserAddress error: ${JSON.stringify(e)}.`);
      })
    })
  }

  getUserAddressList() {
    HttpRequestApi.getUserAddressList().then((resp: BaseResponse<Array<AddressInfo>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        this.addressList = resp.data
      }
    }).catch((e: BusinessError) => {
      console.error(`getUserAddressList error: ${JSON.stringify(e)}.`);
    })
  }

  getTagFontColor(tag: number) {
    if (tag === AddressTagEnum.DEFAULT) {
      return '#486602'
    } else {
      return '#FFC62F'
    }
  }

  getTagBgColor(tag: number) {
    if (tag === AddressTagEnum.DEFAULT) {
      return '#6686AD2B'
    } else {
      return '#33FFC62F'
    }
  }
}
