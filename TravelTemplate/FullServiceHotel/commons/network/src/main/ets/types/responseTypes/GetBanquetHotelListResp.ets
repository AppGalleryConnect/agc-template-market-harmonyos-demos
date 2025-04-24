export interface BanquetHotelItem {
  id: number;
  hotelName: string;
  hotelAddress: string;
  maxArea: string;
  maxCapacity: string;
  displayImg: string;
  longitude: string;
  latitude: string;
}

export type GetBanquetHotelListResp = BanquetHotelItem[];
