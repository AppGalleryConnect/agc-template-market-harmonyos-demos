export interface AttractionListItem {
  labels: string[]
  detailImages: ResourceStr[]
  attractionId: number
  name: string
  banner: ResourceStr
  icon: ResourceStr
  isHot: number,
  latitude: number,
  longitude: number,
  audio: string,
  location: string
}

export interface AttractionList extends Array<AttractionListItem> {}

export interface GetAttractionsInfoResp {
  banners: ResourceStr[]
  attractions: AttractionList
}