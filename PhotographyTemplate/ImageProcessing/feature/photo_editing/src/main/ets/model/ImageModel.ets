import { image } from '@kit.ImageKit'
import { font } from '@kit.ArkUI'
import { LayerType } from '../constant/Enum'
import { CanvasTextItem } from './BeautificationParam'

export default class ImageModel {
  id: string = ''             // 唯一标识，方便更新/删除
  src: string = ''            // 图片路径
  x: number = 0               // 坐标（自由拼接模式用）
  y: number = 0
  width: number = 100         // 显示宽度
  height: number = 100        // 显示高度
  scale: number = 1           // 缩放比例
  rotate: number = 0          // 旋转角度
  path: string = ''
}

export interface ImgOffset {
  x: number
  y: number
}

export interface PixelMapLayer {
  type: LayerType
  pixelMap: image.PixelMap
  filterIndex?: number // 滤镜场景下，用于标识当前滤镜在数组中的位置
}

export interface ImageTextItem {
  icon: Resource
  text: string
  value: string
}

export interface TextFontModel {
  isVip: boolean
  font: font.FontOptions
}

export interface ICanvasText {
  currentColor: ResourceColor
  fontSize: number
  opacity: number
  isBold: boolean
  isItalics: boolean
  isUnderline: boolean
  font: ResourceStr
  text: string
  dx: number
  dy: number
}

export interface TextEditDialogParams {
  cloneText: string
  canvasText: CanvasTextItem
  close: Function
}

export interface MosaicInfo {
  icon:ResourceStr
  mosaicSource:string
  isVip:boolean
}

export interface ScrawlInfo {
  isVip: boolean
  icon: ResourceStr
  brushWidth: number
  shadowBlur: number
  lineCap: string
  lineDash: number[]
}