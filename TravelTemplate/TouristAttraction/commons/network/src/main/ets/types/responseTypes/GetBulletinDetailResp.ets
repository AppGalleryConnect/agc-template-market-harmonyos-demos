export interface GetBulletinDetailResp {
  id: number
  title: string
  detail: string
  releaseTime: string
  banner: ResourceStr
  detailImages: ResourceStr []
}

export interface GetBulletinDetailsResp extends Array<GetBulletinDetailResp> {}