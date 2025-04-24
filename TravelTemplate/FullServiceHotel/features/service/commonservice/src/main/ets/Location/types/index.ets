import { mapCommon } from '@kit.MapKit';

export interface LocationPageModel {
  location: LocationGuideItem;
  guide: LocationGuideItem[];
  mapOptions?: mapCommon.MapOptions;
}

export interface LocationGuideItem {
  icon?: string;
  title: string;
  desc: string;
  image?: string;
}

export interface TrafficResp {
  id: number;
  name: string;
  coordinate: string;
  infos: LocationGuideItem[];
}

export interface HotelCoordinate {
  latitude: number;
  longitude: number;
}
