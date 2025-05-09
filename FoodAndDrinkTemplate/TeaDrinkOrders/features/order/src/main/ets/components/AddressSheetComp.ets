import {
  AddressComp,
  AddressInfo,
  Constants,
  HttpCode,
  HttpRequestApi,
  PermissionUtil,
  SheetHeaderComp,
  WindowModel,
} from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { map, mapCommon } from '@kit.MapKit';
import { AddAddressSheetBuilder } from './AddAddressSheetComp';

@Builder
export function AddressSheetBuilder(selectAddress: AddressInfo, close: (selectAddress?: AddressInfo) => void) {
  AddressSheet({
    selectAddress,
    close: (selectAddress?: AddressInfo) => {
      close(selectAddress)
    },
  })
}

@ComponentV2
struct AddressSheet {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Param @Require selectAddress: AddressInfo;
  @Local modifyAddress: AddressInfo = new AddressInfo()
  @Local addressList: Array<AddressInfo> = [];
  @Local addressOverList: Array<AddressInfo> = [];
  @Local addAddressSheetShow: boolean = false
  @Event close: (selectAddress?: AddressInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.getUserAddressList()
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12,
    })
  }

  build() {
    Stack() {
      Column() {
        Column() {
          SheetHeaderComp({
            title: $r('app.string.select_address'),
            close: () => {
              this.close()
            },
          })
          Column() {
            List({ space: 8 }) {
              ForEach(this.addressList, (address: AddressInfo) => {
                ListItem() {
                  Row() {
                    Row() {
                      Radio({ value: address.id.toString(), group: 'addressGroup' })
                        .checked(this.selectAddress.id === address.id)
                        .radioStyle({
                          checkedBackgroundColor: '#486602',
                        })
                        .height(20)
                        .width(20)
                        .onClick(() => {
                          this.close(address)
                        })
                      AddressComp({ address })
                    }.layoutWeight(1)

                    Image($r('app.media.ic_modify')).width(32).margin({ left: 8 }).onClick(() => {
                      this.modifyAddress = address
                      this.addAddressSheetShow = true
                    })
                  }
                  .cardStyle()
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              }, (address: AddressInfo) => JSON.stringify(address))
            }.width(Constants.FULL_SIZE).scrollBar(BarState.Off)

            Row() {
              Image($r('app.media.ic_add_address')).width(24)
              Text($r('app.string.add_address'))
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.fontMainColor'))
                .margin({ left: 8 })
            }
            .cardStyle()
            .height(56)
            .margin({ top: 24 })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.modifyAddress = new AddressInfo()
              this.addAddressSheetShow = true
            })
            .bindSheet($$this.addAddressSheetShow,
              AddAddressSheetBuilder(this.modifyAddress, () => {
                this.closeAddAddressSheet()
              }), {
                height: 736,
                blurStyle: BlurStyle.Thick,
                showClose: false,
              })

            // 超出配送范围
            Column() {
              Text($r('app.string.over_distance_address'))
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ bottom: 12 })
              List({ space: 8 }) {
                ForEach(this.addressOverList, (address: AddressInfo) => {
                  ListItem() {
                    Row() {
                      AddressComp({ address })
                      Image($r('app.media.ic_modify')).width(32).margin({ left: 8 })
                    }.layoutWeight(1)
                    .cardStyle()
                    .justifyContent(FlexAlign.SpaceBetween)
                  }
                }, (address: AddressInfo) => JSON.stringify(address))
              }.width(Constants.FULL_SIZE).scrollBar(BarState.Off).margin({ bottom: 16 }).opacity(0.4)
            }
            .margin({ top: 39 })
            .alignItems(HorizontalAlign.Start)
            .visibility(this.addressOverList.length ? Visibility.Visible : Visibility.None)

          }
          .layoutWeight(1)
          .margin({ top: 8 })
        }
        .width(Constants.FULL_SIZE)
        .padding({
          left: Constants.BORDER_WIDTH,
          right: Constants.BORDER_WIDTH,
          top: 8,
          bottom: this.windowModel.getWindowBottomHeight(),
        })
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }.width(Constants.FULL_SIZE)
    .height(736)
    .borderRadius({ topLeft: 32, topRight: 32 })
    .alignContent(Alignment.Bottom)
  }

  closeAddAddressSheet() {
    this.getUserAddressList()
    this.addAddressSheetShow = false
  }

  getUserAddressList() {
    Promise.all([PermissionUtil.getLocation(), HttpRequestApi.getUserAddressList()]).then(res => {
      let myLocation = res[0]
      if (res[1].code === HttpCode.SUCCESS && res[1].data) {
        res[1].data.forEach((item: AddressInfo) => {
          let fromLatLng: mapCommon.LatLng = {
            latitude: myLocation.latitude,
            longitude: myLocation.longitude,
          };

          let toLatLng: mapCommon.LatLng = {
            latitude: item.latitude,
            longitude: item.longitude,
          };
          let distance = map.calculateDistance(fromLatLng, toLatLng)
          if (distance > Constants.ADDRESS_OVER) {
            this.addressOverList.push(item)
          } else {
            this.addressList.push(item)
          }
        })
      }
    }).catch((e: BusinessError) => {
      console.error(`getUserAddressList error: ${JSON.stringify(e)}.`);
    })
  }
}