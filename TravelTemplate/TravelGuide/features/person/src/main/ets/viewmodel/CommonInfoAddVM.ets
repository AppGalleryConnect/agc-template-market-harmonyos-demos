import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { TValueType } from 'common';
import { AddressInfo, MyAddressList, MyPassengerList, PassengerInfo } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';

export enum PageType {
  PASSENGER = 0,
  ADDRESS = 1,
  INVOICE = 2,
}

export interface PageParam {
  passengerInfo?: PassengerInfo
  addressInfo?: AddressInfo
  pageType: PageType
}

@ObservedV2
class CommonInfoData {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace phone: string = ''
  @Trace area: string = ''
  @Trace detailAddress: string = ''
  @Trace idNumber: string = ''
}

@ObservedV2
export class CommonInfoAddVM {
  @Trace pageType: number = PageType.PASSENGER
  @Trace data: CommonInfoData = new CommonInfoData()
  @Trace mySelfId: string = ''
  @Trace passengerList: MyPassengerList = PersistenceV2.connect(MyPassengerList, () => new MyPassengerList())!
  @Trace addressList: MyAddressList = AppStorageV2.connect(MyAddressList, () => new MyAddressList())!
  pageName: string = ''

  getPageParam(param?: TValueType) {
    let pageParam = param as PageParam
    this.pageType = pageParam.pageType
    if (pageParam.passengerInfo) {
      this.data.id = pageParam.passengerInfo.id
      this.data.phone = pageParam.passengerInfo.phone
      this.data.name = pageParam.passengerInfo.name
      this.data.idNumber = pageParam.passengerInfo.idNumber
    }
    if (pageParam.addressInfo) {
      this.data.id = pageParam.addressInfo.id
      this.data.phone = pageParam.addressInfo.phone
      this.data.name = pageParam.addressInfo.name
      this.data.area = pageParam.addressInfo.area
      this.data.detailAddress = pageParam.addressInfo.detailAddress
    }
  }

  getPageName() {
    let name = this.pageType === PageType.PASSENGER ? '常用人' : '地址'
    let type = this.data.id ? '编辑' : '新增'
    this.pageName = type + name
  }

  saveData() {
    this.pageType === PageType.PASSENGER ? this.saveToPassenger() : this.saveToAddress()
    phoneRouterControl.popPage()
  }

  saveToPassenger() {
    let passengerInfo = new PassengerInfo()
    passengerInfo.name = this.data.name
    passengerInfo.phone = this.data.phone
    passengerInfo.idNumber = this.data.idNumber
    if (this.data.id) {
      passengerInfo.id = this.data.id
      this.passengerList.editData(passengerInfo)
      if (this.mySelfId) {
        this.passengerList.mySelfId = passengerInfo.id
      }
      if (this.passengerList.mySelfId && !this.mySelfId) {
        this.passengerList.mySelfId = ''
      }
    } else {
      this.passengerList.add(passengerInfo)
      if (this.mySelfId) {
        this.passengerList.mySelfId = passengerInfo.id
      }
    }
  }

  saveToAddress() {
    let addressInfo = new AddressInfo(this.data.name, this.data.phone, this.data.area, this.data.detailAddress)
    if (this.data.id) {
      addressInfo.id = this.data.id
      this.addressList.editData(addressInfo)
    } else {
      this.addressList.add(addressInfo)
    }
  }

  @Computed
  get allowSave() {
    if (this.pageType === PageType.PASSENGER) {
      if (this.data.name && this.data.phone && this.data.idNumber) {
        return true
      }
    }
    if (this.pageType === PageType.ADDRESS) {
      if (this.data.name && this.data.phone && this.data.area && this.data.detailAddress) {
        return true
      }
    }
    return false;
  }
}