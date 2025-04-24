// 发表评论
export interface SubmitCommentRequest {
  comment: string;
  environmentScore: number;
  facilityScore: number;
  hotelId: number;
  hotelType: string;
  isAnonymous: number;
  overallScore: number;
  recommendScore: number;
  serviceScore: number;
  tenantId: number;
  tourType: string;
  userId: number;
  hotelName?: string;
  commentTime?: string;
}

// 酒店订房预下单
export interface PrepayRoomRequest {
  actualPaidPrice: string;
  arrDate: string;
  bookTel: string;
  booker: string;
  cardNo: string;
  depDate: string;
  guest: PrepayRoomGuestItem;
  hotelId: number;
  isPrepaid: string;
  nights: number;
  orgUnitName: string;
  orgUnitNo: string;
  rateCode: string;
  rateName: string;
  remark: string;
  rmQty: number;
  rmRate: string;
  roomCode: string;
  roomId: number;
  roomName: string;
  totalOrderPrice: string;
  userId: number;
}

export interface PrepayRoomGuestItem {
  name: string;
  tel: string;
}

// 更新用户信息
export interface UpdateUserInfoRequest {
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
}

// 查询订单详情
export interface GetOrderDetailRequest {
  userId: number;
  orderNo: string;
  orderType: number;
}

// 团购套餐预下单
export interface PrepayMealRequest {
  actualPaidPrice: string;
  goodsId: number;
  goodsName: string;
  goodsPrice: string;
  goodsQty: number;
  orderType: string;
  shopId: number;
  shopName: string;
  userId: number;
}

// 查询酒店列表
export interface HotelListRequest {
  arrDate: string;
  depDate: string;
  memberLevel: string;
  roomNum: number;
  tenantId: number;
}

// 查询房间列表
export interface RoomListRequest {
  arrDate: string;
  depDate: string;
  memberLevel: string;
  roomNum: number;
  orgUnitNo: string;
  userId: number;
  tenantId: number;
}

// 查询房间详情
export interface RoomDetailRequest {
  orgUnitNo: string;
  roomCode: string;
}

// 查询顶部banner
export interface GetServiceBannerRequest {
  pageType: number;
}

export interface GetRestaurantListRequest {
  shopId: number;
}

export interface GetMealDetailRequest {
  packageId: number;
}