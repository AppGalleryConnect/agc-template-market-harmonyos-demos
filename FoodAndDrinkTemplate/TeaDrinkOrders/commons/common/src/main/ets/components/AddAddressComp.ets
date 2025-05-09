import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { sceneMap } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { permissionUtil } from '../utils/PermissionUtil';
import { AddressTagEnum, addressTagMap, Constants, HttpCode } from '../constants/Common';
import { getUserAddress, modifyUserAddress } from '../axiosHttpRequest/HttpRequestApi';
import { AddressInfo, BaseResponse } from '../models/ResponseModel';
import { common } from '@kit.AbilityKit';
import { getAnonymousTel } from '../utils/Utils';

@ComponentV2
export struct AddAddressComp {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Param addressId: number = 0
  @Local addressPre: string = ''
  @Local addressNum: string = ''
  @Local addressUser: string = ''
  @Local addressSex: boolean = true
  @Local addressTel: string = ''
  @Local addressTag: number = 0
  @Local latitude: number = 0
  @Local longitude: number = 0
  @Local myLocation?: geoLocationManager.Location
  @Event callback: () => void = () => {
  }

  aboutToAppear(): void {
    permissionUtil.getLocation().then(res => {
      this.myLocation = res
    })
    if (this.addressId) {
      this.getAddressInfo()
    }
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .borderRadius(12)
    .padding(12)
    .backgroundColor(Color.White);
  }

  build() {
    Column({ space: 12 }) {
      Column() {
        Row() {
          Row() {
            Text($r('app.string.address'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .width(50)
            Text(this.addressPre || $r('app.string.select_address'))
              .fontSize(12)
              .fontColor('#486602')
              .margin({ left: 4 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }.layoutWeight(1)

          Image($r('app.media.ic_right2')).width(16).margin({ left: 8 })
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
          if (this.myLocation) {
            let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
              location: {
                latitude: this.latitude || this.myLocation?.latitude,
                longitude: this.longitude || this.myLocation?.longitude,
              },
              language: 'zh',
              searchEnabled: true,
              showNearbyPoi: true,
            };
            sceneMap.chooseLocation(getContext(this) as common.UIAbilityContext, locationChoosingOptions)
              .then((data) => {
                this.addressPre = data.name || ''
                this.latitude = data.location.latitude
                this.longitude = data.location.longitude
                console.info('ChooseLocation', 'Succeeded in choosing location.');
              })
              .catch((err: BusinessError) => {
                console.error('ChooseLocation',
                  `Failed to choose Location, code: ${err.code}, message: ${err.message}`);
              });
          }
        })

        Divider().margin({ top: 10, bottom: 10 })
        Row() {
          Row() {
            Text($r('app.string.house_number'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .width(50)
            TextInput({ text: $$this.addressNum, placeholder: $r('app.string.address_num_tip') })
              .placeholderFont({ size: 12 })
              .placeholderColor($r('sys.color.mask_secondary'))
              .fontSize(12)
              .showUnderline(true)
              .underlineColor({
                normal: '#00000000',
                typing: '#00000000',
                error: '#00000000',
                disable: '#00000000',
              })
              .borderWidth(0)
              .fontColor($r('sys.color.mask_secondary'))
              .padding({
                top: 2,
                bottom: 2,
              })
              .layoutWeight(1)
              .margin({ left: 4 })
          }.layoutWeight(1)

          Image($r('app.media.ic_right2')).width(16).margin({ left: 8 })
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

        Divider().margin({ top: 10, bottom: 10 })
        Row() {
          Row() {
            Text($r('app.string.address_user'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .width(50)
            TextInput({ text: $$this.addressUser })
              .placeholderFont({ size: 12 })
              .placeholderColor($r('sys.color.mask_secondary'))
              .fontSize(12)
              .fontColor($r('sys.color.mask_secondary'))
              .showUnderline(true)
              .underlineColor({
                normal: '#00000000',
                typing: '#00000000',
                error: '#00000000',
                disable: '#00000000',
              })
              .padding({
                top: 2,
                bottom: 2,
              })
              .layoutWeight(1)
              .margin({ left: 4 })
              .cancelButton({
                style: CancelButtonStyle.CONSTANT,
                icon: {
                  size: 16,
                  src: $r('app.media.ic_close'),
                },
              })
          }.layoutWeight(1)

          Row() {
            Radio({ value: '1', group: 'sexGroup', indicatorType: RadioIndicatorType.DOT })
              .checked(this.addressSex)
              .radioStyle({
                checkedBackgroundColor: $r('app.color.mainColor'),
              })
              .height(14)
              .width(14)
            Text($r('app.string.man')).fontSize(12).fontColor($r('sys.color.font_primary')).margin({ left: 8 })
            Radio({ value: '2', group: 'sexGroup', indicatorType: RadioIndicatorType.DOT })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: $r('app.color.mainColor'),
              })
              .height(14)
              .width(14)
              .margin({ left: 20 })
            Text($r('app.string.woman')).fontSize(12).fontColor($r('sys.color.font_primary')).margin({ left: 8 })
          }.margin({ left: 8 })
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

        Divider().margin({ top: 10, bottom: 10 })
        Row() {
          Text($r('app.string.address_tel'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .width(50)
          TextInput({ text: $$this.addressTel, placeholder: $r('app.string.address_tel_tip') })
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.mask_secondary'))
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
            .showUnderline(true)
            .underlineColor({
              normal: '#00000000',
              typing: '#00000000',
              error: '#00000000',
              disable: '#00000000',
            })
            .padding({
              top: 2,
              bottom: 2,
            })
            .layoutWeight(1)
            .margin({ left: 4 })
            .cancelButton({
              style: CancelButtonStyle.CONSTANT,
              icon: {
                size: 16,
                src: $r('app.media.ic_close'),
              },
            })
        }
      }.cardStyle().margin({ top: 12, left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })

      Column() {
        Row() {
          Text($r('app.string.address_tag'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .width(50)
          Row({ space: 8 }) {
            Text($r('app.string.address_home'))
              .fontSize(10)
              .fontColor(this.addressTag === AddressTagEnum.HOME ? '#486602' : $r('sys.color.font_primary'))
              .padding({
                left: 12,
                right: 12,
                top: 2,
                bottom: 2,
              })
              .backgroundColor(this.addressTag === AddressTagEnum.HOME ? '#339DC540' : Color.White)
              .border({
                width: 1,
                color: this.addressTag === AddressTagEnum.HOME ? '#486602' : '#80000000',
                radius: 4,
              })
              .onClick(() => {
                this.addressTag = AddressTagEnum.HOME
              })
            Text($r('app.string.address_company'))
              .fontSize(10)
              .fontColor(this.addressTag === AddressTagEnum.COMPANY ? '#486602' : $r('sys.color.font_primary'))
              .padding({
                left: 12,
                right: 12,
                top: 2,
                bottom: 2,
              })
              .backgroundColor(this.addressTag === AddressTagEnum.COMPANY ? '#339DC540' : Color.White)
              .border({
                width: 1,
                color: this.addressTag === AddressTagEnum.COMPANY ? '#486602' : '#80000000',
                radius: 4,
              })
              .onClick(() => {
                this.addressTag = AddressTagEnum.COMPANY
              })
            Text($r('app.string.address_school'))
              .fontSize(10)
              .fontColor(this.addressTag === AddressTagEnum.SCHOOL ? '#486602' : $r('sys.color.font_primary'))
              .padding({
                left: 12,
                right: 12,
                top: 2,
                bottom: 2,
              })
              .backgroundColor(this.addressTag === AddressTagEnum.SCHOOL ? '#339DC540' : Color.White)
              .border({
                width: 1,
                color: this.addressTag === AddressTagEnum.SCHOOL ? '#486602' : '#80000000',
                radius: 4,
              })
              .onClick(() => {
                this.addressTag = AddressTagEnum.SCHOOL
              })
          }
        }.width(Constants.FULL_SIZE)

        Row() {
          Text($r('app.string.save_address'))
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .padding({ top: 6, bottom: 6 })
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .margin({ left: 4, right: 4, top: 32 })
        .backgroundColor('#486602')
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (!this.addressPre) {
            promptAction.showToast({ message: $r('app.string.select_address_pre') })
            return
          } else if (!this.addressNum) {
            promptAction.showToast({ message: $r('app.string.input_address_num') })
            return
          } else if (!this.addressUser) {
            promptAction.showToast({ message: $r('app.string.input_address_user') })
            return
          } else if (!this.addressTel) {
            promptAction.showToast({ message: $r('app.string.input_address_tel') })
            return
          } else if (this.addressTel.length < Constants.TELEPHONE_LENGTH) {
            promptAction.showToast({ message: $r('app.string.address_tel_error') })
            return
          }
          this.modifyAddressInfo()
        })

      }.cardStyle()
    }
    .layoutWeight(1)
    .margin({ top: 8 })
  }

  getAddressInfo() {
    getUserAddress(this.addressId).then((resp: BaseResponse<AddressInfo>) => {
      if (resp.code === HttpCode.SUCCESS) {
        this.addressPre = resp.data.addressPre
        this.addressNum = resp.data.addressNum
        this.addressUser = resp.data.name
        this.addressSex = resp.data.sex
        this.addressTel = resp.data.tel
        this.addressTag = resp.data.tag
        this.latitude = resp.data.latitude
        this.longitude = resp.data.longitude
      } else {
        console.info(`getUserAddress failed. Error:${resp.msg}`);
      }
    })
  }

  modifyAddressInfo() {
    let address = new AddressInfo()
    address.addressPre = this.addressPre
    address.addressNum = this.addressNum
    address.name = this.addressUser
    address.sex = this.addressSex
    address.tel = this.addressTel
    address.tag = this.addressTag
    address.latitude = this.latitude
    address.longitude = this.longitude
    if (this.addressId) {
      address.id = this.addressId
    }
    modifyUserAddress(address).then((resp: BaseResponse) => {
      if (resp.code === HttpCode.SUCCESS) {
        this.callback()
      } else {
        console.info(`modifyUserAddress failed. Error:${resp.msg}`);
        promptAction.showToast({ message: $r('app.string.save_address_failed') })
      }
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

@ComponentV2
export struct AddressComp {
  @Param @Require address: AddressInfo

  build() {
    Column() {
      Row() {
        if (this.address.tag) {
          Text(addressTagMap[this.address.tag])
            .fontSize(10)
            .fontColor(this.getTagFontColor(this.address.tag))
            .borderRadius(4)
            .padding({
              top: 2,
              bottom: 2,
              left: 8,
              right: 8,
            })
            .backgroundColor(this.getTagBgColor(this.address.tag))
            .margin({ right: 4 })
        }

        Text(`${this.address.addressPre}${this.address.addressNum}`)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }

      Row() {
        Text(this.address.name).fontSize(12).fontColor($r('sys.color.mask_secondary'))
        Text(getAnonymousTel(this.address.tel))
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))
          .margin({ left: 12 })
      }.margin({ top: 9 })
    }.alignItems(HorizontalAlign.Start).layoutWeight(1)
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