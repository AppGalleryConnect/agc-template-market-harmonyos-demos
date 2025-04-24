export interface OrderItem {
  orderNo: string;
  orderStatus: string;
  createTime: string;
  payMethod: string;
  remark: string;
  id: number;
  userId: number;
  totalOrderPrice: string;
  discountedPrice: string;
  actualPaidPrice: string;
  currency: string;
  shopName: string;
  goodsName: string;
  orderType: number;
  usageStartTime: string;
  usageEndTime: string;
  specificationName: string | null;
  shopId: string | null;
  goodsId: string | null;
  orderDetailId: string | null;
  payTime: string | null;
  payExpireTime: string | null;
  closeTime: string | null;
  cancelTime: string | null;
  goodsQty: number;
  goodsPrice: number;
  icon?: ResourceStr;
  shopLogo: ResourceStr;
  displayImg: ResourceStr;
  roomResourceInfos: ResourceInfoItem[];
}

export interface TabItem {
  label: string;
  class: OrderClass;
}

export enum OrderType {
  HOTEL = 1,
  MEAL = 2,
}

export enum OrderClass {
  ALL = -1,
  PENDING_PAYMENT = 1,
  PENDING_USAGE = 2,
  COMPLETE = 3,
  CANCEL = 4,
}

export enum OrderClassLabel {
  ALL = '全部',
  PENDING_PAYMENT = '待付款',
  PENDING_USAGE = '待使用',
  COMPLETE = '已完成',
  CANCEL = '已取消',
}

export enum PaymentType {
  ONLINE,
  CASH,
}

export interface ResourceInfoItem {
  resourceType: string;
  resourceUrl: string;
}

export interface HotelOrderItem {
  orderNo: string;
  orderStatus: string;
  createTime: string;
  payMethod: string;
  prepayResult: string;
  remark: string;
  id: number;
  userId: number;
  totalOrderPrice: string;
  discountedPrice: string;
  actualPaidPrice: string;
  currency: string;
  payTime: string | null;
  payExpireTime: string | null;
  arrDate: string;
  depDate: string;
  hotelId: number;
  hotelCode: string;
  hotelName: string;
  roomId: number;
  roomCode: number | null;
  roomName: string;
  nights: number;
  rmQty: 1;
  booker: string | null;
  bookTel: string | null;
  checkInList: CheckInItem[];
  roomInfo: RoomInfo;
  cover?: string | null;
}

export interface RoomInfo {
  pmsResourceInfoList: PmsResourceInfoItem[];
}

export interface PmsResourceInfoItem {
  resourceUrl: string;
}

export interface CheckInItem {
  id: number;
  delFlag: string;
  orderId: number;
  checkInName: string;
  checkInTel: string;
}

export interface MealOrderItem {
  order: MealOrderDetail;
  shopInfo: MealOrderShopInfo;
  packageInfo: MealOrderPackageInfo;
}

export interface MealOrderDetail {
  createTime: string;
  updateTime: string;
  remark: string;
  id: number;
  orderNo: string;
  status: string;
  availableCount: number;
  availableAmount: number | null;
  dinnerPackageId: number;
  shopId: number;
  totalOrderPrice: string;
  discountedPrice: string;
  actualPaidPrice: string;
  totalCount: number;
  userId: number;
  payTime: null | string;
  payExpireTime: null | string;
  closeTime: null | string;
  cancelTime: null | string;
  prepayId: string;
  prepayResult: string;
}

export interface MealOrderShopInfo {
  shopId: number;
  shopName: string;
  labels: string;
  image: string;
}

export interface MealOrderPackageInfo {
  id: number;
  shopId: number;
  effectiveEndTime: string;
  effectiveStartTime: string;
  purchaseLimitPerPeople: number;
  usageRule: string;
  discountedPrice: number;
  price: number;
  packageName: string;
  status: number;
  images: string;
}

export interface OrderInfo {
  img?: ResourceStr;
  title: string;
  time: Date;
  price: number;
  count: number;
}

export interface OrderDetail extends OrderInfo {
  paymentType: PaymentType;
  orderNum: string;
}
