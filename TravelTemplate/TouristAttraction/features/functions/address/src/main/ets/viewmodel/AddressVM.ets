import { shippingAddress } from '@kit.AccountKit';
import { doRandBySync, LazyDataSource, Logger, verifyPhoneNo } from 'common';
import { AddressInfo, TouristInfo } from 'types';
import { AddressRequest, https } from 'network';
import { mapAddressInfo } from '../mapper/Index';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class AddressVM {
  @Trace addressList: AddressInfo[] = [];
  @Trace touristList: LazyDataSource<TouristInfo> = new LazyDataSource();
  public static _instance: AddressVM;

  public static get instance() {
    if (!AddressVM._instance) {
      AddressVM._instance = new AddressVM();
    }
    return AddressVM._instance;
  }

  validate(address: AddressInfo) {
    return !address.name.length || !address.phone.length || !address.district.length || !address.detail.length ||
      !verifyPhoneNo(address.phone);
  }

  editItemInfo(item: AddressInfo,
    isEdit: boolean) {
    let params: AddressRequest = {
      id: isEdit ? item.id : doRandBySync(2),
      name: item.name,
      phone: item.phone,
      district: item.district,
      detail: item.detail,
      type: item.type,
    };

    if (isEdit) {
      https.modifyAddress(params).then((res) => {
        if (res.code === 0) {
          Logger.info('modify tourist success');
        }
      });
    } else {
      https.createAddress(params).then((res) => {
        if (res.code === 0) {
          item.id = params.id;
          this.addressList.push(item);
          Logger.info('create tourist success');
        }
      });
    }
  }

  getAddressList() {
    https.getAddressList().then((res) => {
      this.addressList = mapAddressInfo(res.data);
      Logger.info('getAddress list success ' + this.addressList.length);
    });
  }

  deleteItemInfo(id: string) {
    https.deleteAddress(id).then((res) => {
      if (res.code === 0) {
        this.addressList = this.addressList.filter(item => item.id !== id);
        Logger.info('delete address success');
      }
    });
  }

  mapDistrict(systemAddress: shippingAddress.AddressInfo): string {
    return systemAddress.provinceName + `省` + systemAddress.cityName + systemAddress.districtName +
    systemAddress.streetName;
  }
}