export interface AddressListItem {
  id: string;
  name: string;
  phone: string;
  district: string;
  detail: string;
  type: number;
  latitude: number;
  longitude: number;
}

export class GetAddressListResp extends Array<AddressListItem> {
}