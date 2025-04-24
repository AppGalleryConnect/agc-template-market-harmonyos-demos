import { BasicInfo } from './BasicInfo';

export class CateringInfo implements BasicInfo {
  banners: ResourceStr[] = [];
  comments: number = 0;
  rating: number = 0;
  distance: number = 0;
  siteId: string = '';
  name: string = '';
  address: string = '';
  startPrice: number = 0;
  phone: string = '';
  banner: ResourceStr = '';
  detailImages: ResourceStr[] = [];
  longitude: number = 0;
  latitude: number = 0;
  detail: string = '';
  openHours: string = '';
}

export class CateringList extends Array<CateringInfo> {
}