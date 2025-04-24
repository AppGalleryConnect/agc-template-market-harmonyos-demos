import { BasicInfo } from './BasicInfo';

export class AccommodationInfo implements BasicInfo {
  name: string = '';
  location: string = '';
  startPrice: number = 0;
  phone: string = '';
  banner: ResourceStr = '';
  banners: ResourceStr[] = [];
  longitude: number = 0;
  latitude: number = 0;
  detail: string = '';
  /*酒店标签*/
  labels: string[] = [];
  /*详情图片*/
  detailImages: ResourceStr[] = [];
  /*评分*/
  rating: number = 0;
  /*房型列表信息*/
  roomTypeInfo: RoomTypeInfo = {
    roomTypeId: 0,
    labels: [],
    roomTypePrice: {
      date: new Date(),
      price: 0,
    },
  };
  siteId: string = '';
  address: string = '';
  distance: number = 0;
  comments: number = 0;
}

export interface RoomTypeInfo {
  roomTypeId: number,
  labels: string[],
  roomTypePrice: RoomTypePrice
}

export interface RoomTypePrice {
  date: Date,
  price: number
}

export class AccommodationList extends Array<AccommodationInfo> {
}