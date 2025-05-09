export interface IBannerItem {
  id: number,
  img: ResourceStr,
}

export interface INoticeItem {
  id: number,
  name: string,
  img: ResourceStr,
  date: string,
}

export interface INoticeInfo {
  id: number,
  name: string,
  image: string[]
}

export type GetNoticeListResp = INoticeItem[]

export type GetNoticeInfoResp = INoticeInfo

export type GetBannerListResp = IBannerItem[]