import { BasicInfo } from 'module_base';

export class CateringInfo implements BasicInfo {
  banners: ResourceStr[] = [];
  comments: number = 0;
  rating: number = 0;
  distance: number = 0;
  siteId: string = '';
  name: string = '';
  address: string = '';
  phone: string = '';
  startPrice: number = 0;
  banner: ResourceStr = '';
  longitude: number = 0;
  latitude: number = 0;
  detail: string = '';
  detailImages: ResourceStr[] = [];
  openHours: string = '';
}

export class AccommodationInfo implements BasicInfo {
  name: string = '';
  phone: string = '';
  location: string = '';
  startPrice: number = 0;
  banner: ResourceStr = '';
  banners: ResourceStr[] = [];
  longitude: number = 0;
  latitude: number = 0;
  /*酒店标签*/
  labels: string[] = [];
  detail: string = '';
  /*详情图片*/
  detailImages: ResourceStr[] = [];
  /*房型列表信息*/
  roomTypeInfo: RoomTypeInfo = {
    roomTypeId: 0,
    labels: [],
    roomTypePrice: {
      date: new Date(),
      price: 0,
    },
  };
  /*评分*/
  rating: number = 0;
  siteId: string = '';
  address: string = '';
  distance: number = 0;
  comments: number = 0;
}

export interface RoomTypePrice {
  date: Date,
  price: number
}

export interface RoomTypeInfo {
  roomTypeId: number,
  labels: string[],
  roomTypePrice: RoomTypePrice
}

export interface CateringTabBarData {
  id: CateringTabBarType;
  title: ResourceStr;
  component: WrappedBuilder<[]>
}

export enum CateringTabBarType {
  CATERING = 0,
  ACCOMMODATION = 1,
}