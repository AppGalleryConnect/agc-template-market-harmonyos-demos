export class LiveItem {
  rankId: number
  avatar: ResourceStr
  nickName: string
  category: string
  watching: number
  hot: number

  constructor(rankId: number, avatar: ResourceStr, nickName: string, category: string, watching: number, hot: number) {
    this.rankId = rankId
    this.avatar = avatar
    this.nickName = nickName
    this.category = category
    this.watching = watching
    this.hot = hot
  }
}