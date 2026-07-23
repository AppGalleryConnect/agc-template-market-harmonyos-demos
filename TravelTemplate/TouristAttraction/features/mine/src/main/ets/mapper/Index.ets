import { GetAddressListResp, GetTouristListResp } from 'network';
import { AddressInfo, TouristInfo } from 'types';

export function mapTouristInfo(getTouristListResp: GetTouristListResp) {
  let touristList: TouristInfo[] = [];
  getTouristListResp.forEach((item => {
    let tourist: TouristInfo = new TouristInfo();
    tourist.id = item.id;
    tourist.name = item.name;
    tourist.phone = item.phone;
    tourist.cardType = item.cardType;
    tourist.cardNo = item.cardNo;
    tourist.isChecked = item.isChecked;
    touristList.push(tourist);
  }));
  return touristList;
}

export function mapAddressInfo(addressListResp: GetAddressListResp) {
  let addressList: AddressInfo[] = [];
  addressListResp.forEach(item => {
    let addressInfo = new AddressInfo();
    addressInfo.id = item.id;
    addressInfo.name = item.name;
    addressInfo.phone = item.phone;
    addressInfo.district = item.district;
    addressInfo.detail = item.detail;
    addressInfo.type = item.type;
    addressInfo.latitude = item.latitude;
    addressInfo.longitude = item.longitude;
    addressList.push(addressInfo);
  });
  return addressList;
}

export function mapAddressInfoTemp(addressInfo: AddressInfo) {
  let addressInfoTemp: AddressInfo = new AddressInfo();
  addressInfoTemp.id = addressInfo.id;
  addressInfoTemp.name = addressInfo.name;
  addressInfoTemp.phone = addressInfo.phone;
  addressInfoTemp.district = addressInfo.district;
  addressInfoTemp.detail = addressInfo.detail;
  addressInfoTemp.type = addressInfo.type;
  addressInfoTemp.latitude = addressInfo.latitude;
  addressInfoTemp.longitude = addressInfo.longitude;
  return addressInfoTemp;
}