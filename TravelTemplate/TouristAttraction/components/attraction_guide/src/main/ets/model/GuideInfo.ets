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