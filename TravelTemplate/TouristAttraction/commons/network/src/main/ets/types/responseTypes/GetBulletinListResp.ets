export interface BulletinListItem {
  id: number
  title: string
  releaseTime: string
}

export interface GetBulletinListResp extends Array<BulletinListItem> {}