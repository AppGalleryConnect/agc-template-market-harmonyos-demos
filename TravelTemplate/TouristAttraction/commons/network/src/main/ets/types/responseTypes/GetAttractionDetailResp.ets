export interface GetAttractionDetailResp {
  labels: string[]
  detailImages: ResourceStr[]
  attractionId: number
  brief: string
  name: string
  location: string
  longitude: number
  latitude: number
  banner: ResourceStr
  icon: ResourceStr
  introduction: string
  consultPhone: string
  audio: string
  isHot: number
}

export interface Instructions {
  instructionId: number,
  instructionTitle: string,
  instructionDetail: string
}

export interface GetAttractionDetailsResp extends Array<GetAttractionDetailResp> {}