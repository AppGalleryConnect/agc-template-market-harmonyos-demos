import { OperateType } from './CommonEnums';

export interface AddressInfo {
  name: string,
  formatAddress: string,
  distance: number
}

export interface IPhoneRequest {
  phone: string
}

// 根据用户id获取数据
export interface IUserIdRequest {
  userId: number
}

export interface ICardInfo {
  label: ResourceStr,
  icon: ResourceStr,
  action: () => void,
  bgColor?: ResourceColor,
}

export interface BeautyParam {
  uris: string[];
  operateType: OperateType
  filterName?: string;
  pixelMap?: PixelMap;
}

export interface CustomFilter {
  name: string
  image: Resource
  blur: number,
  invert: boolean,
  colorMatrix: number[],
  brightness: number,
  grayscale: boolean,
  isHot: boolean
}