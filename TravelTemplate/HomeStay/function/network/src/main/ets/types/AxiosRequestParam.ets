export interface GetInfoRequest {
  appId: string,
  openId?: string
}

export interface GetHotelInfo {
  appId: string,
  recommendGoodsCount: number,
  roomTypeCount: number,
  featureRoomTypeCount: number,
  brandStoryCount: number,
  hotScenicSpotCategoryCount: number,
  recommendScenicSpotCount: number,
}

export interface AddComplaintsRequest {
  openId: string,
  phone: string,
  content: string,
  appId: string,
  filePath: string,
}

export interface AddOrModifyPassengerRequest {
  passengerId: number,
  passengerName: string,
  passengerPhone: string,
  passengerCardType: string,
  passengerCardId: string,
  appId: string,
}

export interface CreateOrderRequest {
  appId: string,
  passengerId: number,
  id: number,
  orderStatus: number,
  orderType: number,
  orderRemark: string,
  planCheckInDate: string,
  planCheckOutDate: string,
  checkInPersonNum: number,
  dayCount: number,
  openId: string,
  orderSn: string,
  createTime: string,
  amount: number,
  count: number,
  goodsBanner: ResourceStr,
  goodsCount: number,
  commodityId: number,
  sfc: string
}

export interface UpdateOrderRequest {
  orderSn: string,
  orderStatus: number
}