import { AttractionUtil } from 'common';
import { AccommodationInfo, AppStorageMap, AttractionInfo, CateringInfo, ToiletInfo } from 'types';

export interface Guide<T> {
  id: number
  title: string
  activeIcon: ResourceStr
  icon: ResourceStr,
  defaultIcon: ResourceStr
  type: LocationType
  data: T[]
}

export class SiteInfo {
  siteId: string = '';
  name: string = '';
  type: LocationType = LocationType.ATTRACTION;
  icon: ResourceStr = '';
  location: string = '';
  longitude: number = 0;
  latitude: number = 0;
  audio: string = '';
  remainsForMan: number = 0;
  remainsForWoman: number = 0;
  titleColor: number = 0;
}

export enum LocationType {
  ATTRACTION = 0,
  CATERING = 1,
  ACCOMMODATION = 2,
  TOILETS = 3
}

export const GUIDE_TABS_INFO = [{
  id: 0,
  title: '景点',
  activeIcon: $r('app.media.guide_scenic'),
  defaultIcon: $r('app.media.guide_scenic_default'),
  icon: $r('app.media.icon_scenic'),
  type: LocationType.ATTRACTION,
  data: AttractionUtil.getAttraction().attractions,
} as Guide<AttractionInfo>,
  {
    id: 1,
    title: '餐饮',
    activeIcon: $r('app.media.guide_catering'),
    defaultIcon: $r('app.media.guide_catering_default'),
    icon: $r('app.media.icon_catering'),
    type: LocationType.CATERING,
    data: AppStorage.get(AppStorageMap.CATERING_LIST)!,
  } as Guide<CateringInfo>,
  {
    id: 2,
    title: '住宿',
    activeIcon: $r('app.media.guide_accommodation'),
    defaultIcon: $r('app.media.guide_accommodation_default'),
    icon: $r('app.media.icon_accommodation'),
    type: LocationType.ACCOMMODATION,
    data: AppStorage.get(AppStorageMap.ACCOMMODATION_LIST)!,
  } as Guide<AccommodationInfo>,
  {
    id: 3,
    title: '卫生间',
    activeIcon: $r('app.media.guide_toilets'),
    icon: $r('app.media.icon_toilet'),
    defaultIcon: $r('app.media.guide_toilets_default'),
    type: LocationType.TOILETS,
    data: AppStorage.get(AppStorageMap.TOILET_LIST)!,
  } as Guide<ToiletInfo>,
];