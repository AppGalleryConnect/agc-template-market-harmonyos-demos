import { LayoutTemplateModel } from './LayoutTemplateModel'
import PosterTemplateModel from './PosterTemplateModel'
import FreeCollageModel from './FreeCollageModel'
import ImageModel from './ImageModel'
import { CollageMode } from '../constant/Enum';

export default class CollageModel {
  mode: CollageMode = CollageMode.FIXED

  // 各模式独立管理图片
  fixedImages: ImageModel[] = []
  posterImages: ImageModel[] = []
  freeImages: ImageModel[] = []

  layout?: LayoutTemplateModel
  poster?: PosterTemplateModel
  free?: FreeCollageModel
}
