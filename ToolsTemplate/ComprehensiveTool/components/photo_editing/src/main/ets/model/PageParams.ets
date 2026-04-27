export interface BeautyParam {
  uris: string[]
  barIndex: number;
  filterName?: string;
  pixelMap?: PixelMap
}

export interface ImageShowModel {
  imageSource: Resource
  text?: string
  needDownload?: boolean
}

export interface DraftModel {
  id:string
  uri: string
  updateTime: string
}

export interface StickerShowModel extends ImageShowModel {
  tag: string[]
  isVip: boolean
}

@ObservedV2
export class MyPosition {
  @Trace x: number = 0
  @Trace y: number = 0
  @Trace width?: number = 0
  @Trace height?: number = 0
}