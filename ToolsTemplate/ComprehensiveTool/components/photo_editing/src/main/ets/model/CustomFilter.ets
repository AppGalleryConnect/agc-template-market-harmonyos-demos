export interface CustomFilter {
  name: string
  image: Resource
  blur: number,
  invert: boolean,
  colorMatrix: number[],
  brightness: number,
  grayscale: boolean,
  isHot: boolean
  isVip: boolean
}