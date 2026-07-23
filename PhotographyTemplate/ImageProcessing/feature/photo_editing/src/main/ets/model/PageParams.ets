export interface ImageShowModel {
  imageSource: Resource;
  text?: string;
  needDownload?: boolean;
}

export interface DraftModel {
  id: string;
  uri: string;
  updateTime: string;
}

export interface StickerShowModel extends ImageShowModel {
  tag: string[];
}

@ObservedV2
export class MyPosition {
  @Trace x: number = 0;
  @Trace y: number = 0;
  @Trace width?: number = 0;
  @Trace height?: number = 0;
}