import { ScenicBasicInfo } from './ScenicBasicInfo';

export interface Instructions {
  instructionId: number,
  instructionTitle: string,
  instructionDetail: string
}

export class AttractionInfo implements ScenicBasicInfo {
  labels: string[] = [];
  detailImages: ResourceStr[] = [];
  attractionId: number = 0;
  brief: string = '';
  name: string = '';
  location: string = '';
  longitude: number = 0;
  latitude: number = 0;
  banner: ResourceStr = '';
  icon: ResourceStr = '';
  introduction: string = '';
  consultPhone: string = '';
  audio: string = '';
  isHot: number = 0;
}

export class AttractionsInfo {
  banners: ResourceStr[] = [];
  attractions: AttractionInfo[] = [];
}

export class AttractionList extends Array<AttractionInfo> {
}
