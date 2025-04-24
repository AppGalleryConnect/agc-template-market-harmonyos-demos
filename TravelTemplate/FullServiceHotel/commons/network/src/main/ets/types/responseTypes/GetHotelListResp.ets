export interface HotelItem {
  id: number;
  address: string;
  coordinate: string;
  imageUrl: string;
  labelList: string[];
  minPrice: number;
  name: string;
  sortNum: number;
  tel: string;
  orgUnitNo: string;
}

export type GetHotelListResp = HotelItem[];
