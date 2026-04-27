@ObservedV2
export class Viewer {
  @Trace rank: number; // 榜排名
  @Trace id: string; // id
  @Trace name: string; // 姓名

  constructor(rank: number, id: string, name: string) {
    this.rank = rank;
    this.id = id;
    this.name = name;
  }
}


@ObservedV2
export class GiftInfoClass {
  @Trace id: string
  @Trace senderNickname: string
  @Trace senderAvatar: ResourceStr
  @Trace giftName: string
  @Trace giftImage: ResourceStr
  @Trace quantity: number

  constructor(
    id: string = '1',
    senderNickname: string = '浪里白条',
    senderAvatar: ResourceStr = $r('app.media.avatar'),
    giftName: string = '礼物1',
    giftImage: ResourceStr = $r('app.media.gift'),
    quantity: number = 5) {
    this.id = id
    this.senderNickname = senderNickname
    this.senderAvatar = senderAvatar
    this.giftName = giftName
    this.giftImage = giftImage
    this.quantity = quantity
  }
}