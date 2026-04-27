import { TextReader } from '@kit.SpeechKit'

export interface TextParams {
  text: string
  // 是否支持点击收回播报面板
  isClickable: boolean
}

export enum BarAlignment {
  LEFT = 1,
  RIGHT = 2
}

export enum DisplayTab {
  COVER_AND_CONTENT = 1,
  CONTENT = 2,
  COVER = 3,
}

export enum ResetParamType {
  ALL = 1,
  BAR_PARAM = 2,
  READ_LIST = 3
}

export interface MinibarParams {
  defaultAlignment: BarAlignment
  bottom?: number
}

export interface BrandInfo {
  panelName?: string
}


export interface ReaderContent extends TextReader.ReadInfo {
  id: string
  title: TextParams
  bodyInfo: string
  category?: string
  author?: TextParams
  date?: TextParams
  isFavorite?: boolean
  imgSrc?: ResourceStr | PixelMap
}

export interface ReaderParams extends TextReader.ReaderParam {
  isVoiceBrandVisible: boolean
  businessBrandInfo?: BrandInfo
  isFastForward?: boolean
  isMinibarNeeded?: boolean
  minibarParams?: MinibarParams
  displayTab?: DisplayTab
  reportProgressPeriod?: number
}

export interface ReaderState extends TextReader.ReadState {}

export interface IconParams {
  iconWidth?: Length
  iconHeight?: Length
  iconBackgroundColor?: ResourceColor
  iconBorderRadius?: Length | BorderRadiuses
}