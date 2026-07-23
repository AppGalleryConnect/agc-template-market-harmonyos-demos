import { CollageMode } from '../constant/Enum'
import ImageModel from './ImageModel';

export interface CollageModeInfo {
  name: string
  mode: CollageMode
  show?: boolean
  clickAction: () => void
}

export interface XY { x: number; y: number }
export interface PicRegionJSON { coordinates: XY[] } // 4 个点，顺/逆时针

@ObservedV2
export class LayoutRegion {
  @Trace path: string = '' // SVG Path
}

@ObservedV2
export class LayoutTemplateModel {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace image?: Resource
  @Trace selectedImage?: Resource
  @Trace count: number = 0
  @Trace width: string = '100%'
  @Trace height: string = '100%'
  @Trace regions: LayoutRegion[] = []

  constructor(template?: LayoutTemplateModel) {
    if (template) {
      this.id = template.id
      this.name = template.name
      this.image = template.image
      this.selectedImage = template.selectedImage
      this.count = template.count
      this.width = template.width
      this.height = template.height
      this.regions = template.regions
    }
  }
}

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
export class PosterTemplateModel {
  @Trace id: string = ''
  @Trace count: number = 0
  @Trace background?: Resource     // 背景图片路径
  @Trace example?: Resource       // 样例
  @Trace oriRegions: PicRegionJSON[] = []
  @Trace regions: PosterRegion[] = []
  @Trace hasProcessed: boolean = false
  @Trace isVip: boolean = false;

  constructor(template?: PosterTemplateModel) {
    if (template) {
      this.id = template.id
      this.count = template.count
      this.background = template.background
      this.example = template.example
      this.oriRegions = template.oriRegions
      this.hasProcessed = template.hasProcessed
      this.isVip = template.isVip
    }
  }
}

export class FreeCollageModel {
  background?: Resource
  images: ImageModel[] = []
}

@ObservedV2
export class ImageVM {
  @Trace id: string = ''
  @Trace src: string = ''
  @Trace x: number = 0
  @Trace y: number = 0
  @Trace width: number = 100
  @Trace height: number = 100
  @Trace scale: number = 1
  @Trace rotate: number = 0

  updateFromModel(model: ImageModel) {
    this.id = model.id
    this.src = model.src
    this.x = model.x
    this.y = model.y
    this.width = model.width
    this.height = model.height
    this.scale = model.scale
    this.rotate = model.rotate
  }
}