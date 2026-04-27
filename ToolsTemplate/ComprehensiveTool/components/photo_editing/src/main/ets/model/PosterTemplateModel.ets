export class PosterRegion {
  path: string = ''
  x: number = 0
  y: number = 0
  width: number = 100
  height: number = 100
  rotate: number = 0
  zIndex: number = 0
}
@ObservedV2
export default class PosterTemplateModel {
  @Trace id: string = ''
  @Trace count: number = 0
  @Trace background?: Resource     // 背景图片路径
  @Trace example?: Resource       // 样例
  @Trace oriRegions: PicRegionJSON[] = []
  @Trace regions: PosterRegion[] = []
  @Trace hasProcessed: boolean = false
  @Trace isVip: boolean = false;
}

export interface XY { x: number; y: number }
export interface PicRegionJSON { coordinates: XY[] } // 4 个点，顺/逆时针