import { AddressManage } from 'module_address';
import { getAddressData, IAddrInfo, RouterMap, sendAddressData } from 'module_base';

export interface IAddressParam {
  type: OrderType,
  address: IAddrInfo,
}

export enum OrderType {
  ALL = '全部',
  SEND = '寄快递',
  RECEIVE = '收快递',
}

@ComponentV2
export struct CommonAddress {
  @Param stack: NavPathStack = new NavPathStack();
  @Param isEdit: boolean = true
  @Param sendAddress: IAddrInfo = sendAddressData
  @Param getAddress: IAddrInfo = getAddressData
  @Event onSelect: (value: IAddressParam) => void = (value: IAddressParam) => {
  }
  @Event onChange: () => void = () => {
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_send_address'))
          .width(24)
          .height(28)
          .flexShrink(0)
        AddressManage({
          navPathStack: this.stack,
          route: RouterMap.ADDRESS_EDIT_PAGE,
          address: this.sendAddress,
          isSelectMode: true,
          onBeforeNavigate: () => {
            if (this.isEdit) {
              return true
            } else {
              return false
            }
          },
          onSelect: (data) => {
            const param: IAddressParam = {
              type: OrderType.SEND,
              address: {
                id: data.id,
                name: data.name,
                phone: data.phone,
                countryCode: data.countryCode,
                country: data.country,
                province: data.province,
                city: data.city,
                district: data.district,
                street: data.street,
                detail: data.detail,
                isDefault: data.isDefault,
                createdAt: data.createdAt,
                updatedAt: data.updatedAt,
              },
            }
            this.onSelect(param)
          },
        }) {
          this.addressContentBuilder({
            id: this.sendAddress.id,
            name: this.sendAddress.name ? this.sendAddress.name : '请填写寄件人信息',
            phone: this.sendAddress.phone,
            countryCode: this.sendAddress.countryCode,
            country: this.sendAddress.country,
            province: this.sendAddress.province,
            city: this.sendAddress.city,
            district: this.sendAddress.district,
            street: this.sendAddress.street,
            detail: this.sendAddress.detail,
            isDefault: this.sendAddress.isDefault,
            createdAt: this.sendAddress.createdAt,
            updatedAt: this.sendAddress.updatedAt,
          })
        }

        this.addressBookBuilder(OrderType.SEND)
      }

      Row() {
        Image($r('app.media.ic_change'))
          .width(24)
          .height(24)
          .onClick(() => {
            if (this.isEdit) {
              this.onChange()
            }
          })

        Divider().strokeWidth(1).color('rgba(0,0,0,0.20)')
          .margin({ left: 12, right: 12 })
      }
      .margin({ top: 5, bottom: 12, right: 12 })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_get_address'))
          .width(24)
          .height(28)
          .flexShrink(0)
        AddressManage({
          navPathStack: this.stack,
          route: RouterMap.ADDRESS_EDIT_PAGE,
          address: this.getAddress,
          isSelectMode: true,
          onBeforeNavigate: () => {
            if (this.isEdit) {
              return true
            } else {
              return false
            }
          },
          onSelect: (data) => {
            const param: IAddressParam = {
              type: OrderType.RECEIVE,
              address: {
                id: data.id,
                name: data.name,
                phone: data.phone,
                countryCode: data.countryCode,
                country: data.country,
                province: data.province,
                city: data.city,
                district: data.district,
                street: data.street,
                detail: data.detail,
                isDefault: data.isDefault,
                createdAt: data.createdAt,
                updatedAt: data.updatedAt,
              },
            }
            this.onSelect(param)
          },
        }) {
          this.addressContentBuilder({
            id: this.getAddress.id,
            name: this.getAddress.name ? this.getAddress.name : '请填写收件人信息',
            phone: this.getAddress.phone,
            countryCode: this.getAddress.countryCode,
            country: this.getAddress.country,
            province: this.getAddress.province,
            city: this.getAddress.city,
            district: this.getAddress.district,
            street: this.getAddress.street,
            detail: this.getAddress.detail,
            isDefault: this.getAddress.isDefault,
            createdAt: this.getAddress.createdAt,
            updatedAt: this.getAddress.updatedAt,
          })
        }

        this.addressBookBuilder(OrderType.RECEIVE)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 14,
      bottom: 12,
      left: 12,
      right: 12,
    })
    .borderRadius(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 16 })
  }

  @Builder
  addressBookBuilder(type: OrderType) {
    Row() {
      AddressManage({
        navPathStack: this.stack,
        isSelectMode: true,
        onBeforeNavigate: () => {
          if (this.isEdit) {
            return true
          } else {
            return false
          }
        },
        onSelect: (data) => {
          const param: IAddressParam = {
            type,
            address: {
              id: data.id,
              name: data.name,
              phone: data.phone,
              countryCode: data.countryCode,
              country: data.country,
              province: data.province,
              city: data.city,
              district: data.district,
              street: data.street,
              detail: data.detail,
              isDefault: data.isDefault,
              createdAt: data.createdAt,
              updatedAt: data.updatedAt,
            },
          }
          this.onSelect(param)
        },
      }) {
        Row() {
          Text('地址簿')
            .width(42)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }
        .height(24)
        .padding({ left: 12 })
        .borderWidth({ left: 1 })
        .borderColor('rgba(0,0,0,0.40)')
      }
    }
    .width(54)
    .flexShrink(0)
  }

  @Builder
  addressContentBuilder($$: IAddrInfo) {
    Column() {
      Row() {
        Text($$.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ right: 10 })
        Text($$.phone)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text($$.province + $$.city + $$.district + $$.street + $$.detail ?
          $$.province + $$.city + $$.district + $$.street + $$.detail : '支持智能识别文字与图片中的地址')
          .fontSize(11)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
    }
    .padding({ left: 12, right: 12 })
    .flexGrow(1)
  }
}