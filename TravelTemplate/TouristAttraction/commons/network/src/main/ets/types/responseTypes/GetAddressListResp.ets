export interface AddressListItem {
  id: string
  name: string
  phone: string
  district: string
  detail: string
  type: number
}

export class GetAddressListResp extends Array<AddressListItem> {}