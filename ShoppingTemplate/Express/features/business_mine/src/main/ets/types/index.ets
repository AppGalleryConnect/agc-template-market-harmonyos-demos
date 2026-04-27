export interface IMainServiceItem {
  text: string,
  image: ResourceStr,
  func: Function
}

export interface IRegion {
  code: string,
  name: string,
  children?: []
}

export interface IVip {
  id: number,
  name: string,
  originalPrice: number,
  discountPrice: number,
  instructions?: string,
}