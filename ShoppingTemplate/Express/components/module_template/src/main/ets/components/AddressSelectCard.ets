import { AddressController, AddressDTO, AddressVM, goToAddressListPage } from 'address_management';
import { AddressBook, EmitterUtils, HttpApi } from 'lib_foundation';
import { AddressInfoModel } from '../models/Model';

@ComponentV2
export struct AddressSelectCard {
  @Param stack: NavPathStack = new NavPathStack();
  @Param isEdit: boolean = true
  @Param userId: number = 0;
  @Param senderInfo: AddressInfoModel = new AddressInfoModel();
  @Param receiverInfo: AddressInfoModel = new AddressInfoModel();
  @Event onChangeSender: () => void = () => {
  }
  @Event onChangeReceiver: () => void = () => {
  }
  @Event onExchangeAddress: () => void = () => {
  }

  controller: AddressController = new AddressController();

  aboutToAppear(): void {
    this.initAddressController();
  }

  initAddressController() {
    // 注入查询逻辑
    this.controller.onLoadAddress = async () => {
      const resp = await HttpApi.queryAddressList(this.userId);
      let addressList: AddressVM[] = [];
      if (resp.length > 0) {
        addressList = resp.map((item) => new AddressVM(item as AddressDTO))
      }
      return addressList;
    };

    // 注入新增地址逻辑
    this.controller.onAddAddress = async (address: AddressDTO) => {
      const time: number = new Date().getTime();
      address.createdAt = time;
      address.updatedAt = time;
      address.userId = this.userId;
      const resp = await HttpApi.addAddressBook(address as AddressBook)
      return resp > 0;
    };

    // 注入删除逻辑
    this.controller.onDeleteAddress = async (addressId: number) => {
      const resp = HttpApi.deleteAddress(addressId);
      const tempAddress = {
        addressId,
      } as AddressDTO
      EmitterUtils.emit('refreshAddressInfo', { address: tempAddress });
      return resp;
    };

    // 注入修改地址逻辑
    this.controller.onModifyAddress = async (address: AddressDTO, isSetDefault: boolean = false) => {
      const time = Date.now();
      address.updatedAt = time;
      const resp = await HttpApi.updateAddressBook(address as AddressBook, isSetDefault);
      EmitterUtils.emit('refreshAddressInfo', { address: address });
      return resp;
    }
  }

  // 地址交换
  onExchange() {
    if (this.receiverInfo.addressId) {
      const tempId = this.receiverInfo.addressId;
      const tempName = this.receiverInfo.name;
      const tempPhone = this.receiverInfo.phone;
      const tempFullAddress = this.receiverInfo.fullAddress;
      const tempProvince = this.receiverInfo.province;
      const tempCity = this.receiverInfo.city;
      this.receiverInfo.addressId = this.senderInfo.addressId;
      this.receiverInfo.name = this.senderInfo.name;
      this.receiverInfo.phone = this.senderInfo.phone;
      this.receiverInfo.fullAddress = this.senderInfo.fullAddress;
      this.receiverInfo.province = this.senderInfo.province;
      this.receiverInfo.city = this.senderInfo.city;
      this.senderInfo.addressId = tempId;
      this.senderInfo.name = tempName;
      this.senderInfo.phone = tempPhone;
      this.senderInfo.fullAddress = tempFullAddress;
      this.senderInfo.province = tempProvince;
      this.senderInfo.city = tempCity;

      this.onExchangeAddress();
    }
  }

  build() {
    Column() {
      // 寄件人信息
      AddressInfoRow({
        icon: $r('app.media.ic_send_address'),
        name: this.senderInfo.name || '请填写寄件人信息',
        phone: this.senderInfo.phone,
        fullAddress: this.senderInfo.fullAddress,
        onJumpToAddressBook: () => {
          goToAddressListPage(this.stack, {
            controller: this.controller,
            onAddressSelected: (dto: AddressDTO): void => {
              this.senderInfo.addressId = dto.addressId;
              this.senderInfo.name = dto.name;
              this.senderInfo.phone = dto.phone;
              this.senderInfo.fullAddress = `${dto.province}${dto.city}${dto.district}${dto.street}${dto.detail}`;
              this.senderInfo.province = dto.province;
              this.senderInfo.city = dto.city;
              this.onChangeSender();
              this.stack.pop();
            }
          });
        }
      })

      Row() {
        SymbolGlyph($r('sys.symbol.mobiledata_circle'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_tertiary')])
          .onClick(() => {
            if (this.isEdit) {
              this.onExchange()
            }
          })

        Divider().strokeWidth(1).color($r('sys.color.comp_divider'))
          .margin({ left: 12, right: 12 })
      }
      .margin({ top: 5, bottom: 12, right: 12 })

      // 收件人信息
      AddressInfoRow({
        icon: $r('app.media.ic_receiver_address'),
        name: this.receiverInfo.name || '请填写收件人信息',
        phone: this.receiverInfo.phone,
        fullAddress: this.receiverInfo.fullAddress,
        onJumpToAddressBook: () => {
          goToAddressListPage(this.stack, {
            controller: this.controller,
            onAddressSelected: (dto: AddressDTO): void => {
              this.receiverInfo.addressId = dto.addressId;
              this.receiverInfo.name = dto.name;
              this.receiverInfo.phone = dto.phone;
              this.receiverInfo.fullAddress = `${dto.province}${dto.city}${dto.district}${dto.street}${dto.detail}`;
              this.receiverInfo.province = dto.province;
              this.receiverInfo.city = dto.city;
              this.onChangeReceiver();
              this.stack.pop();
            }
          });
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}

@ComponentV2
struct AddressInfoRow {
  // 图标
  @Param icon: ResourceStr = '';
  // 姓名
  @Param name: string = '';
  // 手机号
  @Param phone: string = '';
  // 地址
  @Param fullAddress: string = '';
  // 跳转到地址簿页面
  @Event onJumpToAddressBook: () => void = () => {
  }

  build() {
    Row() {
      Image(this.icon)
        .width(24)
        .height(28)
        .flexShrink(0)

      Column({ space: 8 }) {
        Row() {
          Text(this.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ right: 10 })
          Text(this.phone)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')

        Row() {
          Text(this.fullAddress || '支持智能识别地址')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
            .lineHeight(19)
        }
        .width('100%')
      }
      .padding({ left: 12, right: 12 })
      .layoutWeight(1)

      Row() {
        Text('地址簿')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .height(24)
      .padding({ left: 12 })
      .borderWidth({ left: 1 })
      .borderColor($r('sys.color.comp_divider'))
      .onClick(() => {
        this.onJumpToAddressBook();
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
  }
}


