import { GetAddressListResp } from 'network';
import { AddressInfo } from 'types';

export function mapAddressInfo(addressListResp: GetAddressListResp) {
  let addressList: AddressInfo[] = []
  addressListResp.forEach(item => {
    let addressInfo = new AddressInfo()
    addressInfo.id = item.id
    addressInfo.name = item.name
    addressInfo.phone = item.phone
    addressInfo.district = item.district
    addressInfo.detail = item.detail
    addressInfo.type = item.type
    addressList.push(addressInfo)
  })
  return addressList
}