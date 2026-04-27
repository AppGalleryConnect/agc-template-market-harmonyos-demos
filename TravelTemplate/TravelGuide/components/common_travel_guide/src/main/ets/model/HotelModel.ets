@ObservedV2
export class HotelModel {
  // 酒店名称
  name: string
  // 酒店类型（经济型、舒适型、豪华型等）
  type: string
  // 点评数量
  @Trace reviewCount: number
  // 收藏数量
  @Trace favoriteCount: number
  // 距离（单位：公里）
  @Trace distance: string
  // 评分
  @Trace rating: number
  // 原价
  @Trace originalPrice: number
  // 价格
  @Trace price: number
  // 图片资源
  @Trace image: string
  // 图片资源
  @Trace city: string
  // 地址
  @Trace address: string
  // 星级
  @Trace star: string
  // 住宿类型
  @Trace accommodationType: string
  // 设施
  @Trace facility: string[]
  // 地址
  @Trace position: string
  // 开业时间
  @Trace openingTime: string
  // 装修时间
  @Trace decorationTime: string
  // 房间数量
  @Trace quantity: number
  // 电话
  @Trace telephone: string
  // 舒适大床价格
  @Trace bigRoomPrice: number
  // 舒适双床价格
  @Trace doubleBedRoomPrice: number
  // 是否收藏
  @Trace isCollect: boolean

  constructor(
    name: string,
    type: string,
    reviewCount: number,
    favoriteCount: number,
    distance: string,
    rating: number,
    originalPrice: number,
    price: number = 0,
    image: string,
    city: string,
    address: string,
    star: string,
    accommodationType: string,
    facility: string[],
    position: string,
    openingTime: string,
    decorationTime: string,
    quantity: number,
    telephone: string,
    bigRoomPrice: number,
    doubleBedRoomPrice: number,
    isCollect: boolean
  ) {
    this.name = name
    this.type = type
    this.reviewCount = reviewCount
    this.favoriteCount = favoriteCount
    this.distance = distance
    this.rating = rating
    this.originalPrice = originalPrice
    this.price = price
    this.image = image
    this.city = city
    this.address = address
    this.star = star
    this.accommodationType = accommodationType
    this.facility = facility
    this.position = position
    this.openingTime = openingTime
    this.decorationTime = decorationTime
    this.quantity = quantity
    this.telephone = telephone
    this.bigRoomPrice = bigRoomPrice
    this.doubleBedRoomPrice = doubleBedRoomPrice
    this.isCollect = isCollect
  }
}