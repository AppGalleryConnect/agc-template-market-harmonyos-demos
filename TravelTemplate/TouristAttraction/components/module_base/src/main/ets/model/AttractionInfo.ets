import { ScenicBasicInfo } from './Index';

export interface Instructions {
  instructionId: number,
  instructionTitle: string,
  instructionDetail: string
}

@ObservedV2
export class AttractionInfo implements ScenicBasicInfo {
  @Trace labels: string[] = [];
  @Trace detailImages: ResourceStr[] = [];
  @Trace attractionId: number = 0;
  @Trace brief: string = '';
  @Trace name: string = '';
  @Trace location: string = '';
  @Trace longitude: number = 0;
  @Trace latitude: number = 0;
  @Trace banner: ResourceStr = '';
  @Trace icon: ResourceStr = '';
  @Trace introduction: string = '';
  @Trace consultPhone: string = '';
  @Trace audio: string = '';
  @Trace isHot: number = 0;
}

export class AttractionsInfo {
  banners: ResourceStr[] = [];
  attractions: AttractionInfo[] = [];
}

export class AttractionList extends Array<AttractionInfo> {
}
