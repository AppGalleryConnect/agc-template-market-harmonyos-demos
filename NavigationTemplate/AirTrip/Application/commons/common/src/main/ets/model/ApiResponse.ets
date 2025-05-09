import { UserInfo } from '../constants/CommonModel'

interface FunctionResultRet {
  code: number
  desc: string
}

@ObservedV2
export class PassengerInfo {
  id: string = '' // 乘机人ID
  @Trace name: string = '' // 姓名
  @Trace certificateType: string = '' // 证件类型
  @Trace certificateNo: string = '' // 证件号码
  @Trace phone: string = '' // 手机号码
  @Trace isChecked: boolean = false
}

export class OrderInfo {
  id: string = '' // 订单ID
  orderNo: string = '' // 订单编号
  flightId: string = '' // 航班ID
  flightNo: string = '' // 航班号
  createTime: number = 0
  airlineName: string = '' // 航空公司名称
  aircraftType: string = '' // 机型
  takeoffTime: string = '' // 起飞时间
  landingTime: string = '' // 到达时间
  departureCity: string = '' // 出发城市
  departureAirport: string = '' // 出发机场
  destinationCity: string = '' // 目的城市
  destinationAirport: string = '' // 目的机场
  mealType: string = '' // 餐食类型
  spaceType: string = '' // 舱位类型
  spacePrice: number = 0 // 舱位价格
  airportConstructionPrice: number = 0 // 机建费
  fuelPrice: number = 0 // 燃油费
  includeTaxPrice: number = 0 // 机票含税价格
  contactName: string = '' //联系人姓名
  contactPhone: string = '' //联系人电话
  status: number = -1 // 状态：1-待支付；2-待出票；3-已出票；4-退改票；0-已取消
  passengerList: string = '[]'
}

export class ResourceInfo {
  id: string = ''
  name: string = ''
  imgUrl: string = ''
  linkUrl?: string = ''
  bgColor?: string = ''
}


export class Trip {
  // 行程单ID
  id: string = ''
  // 航班号
  flightNo: string = ''
  // 航空公司名称
  airlineName: string = ''
  // 机型
  aircraftType: string = ''
  // 机龄
  aircraftAge: string = ''
  // 飞行里程
  flyMiles: string = ''
  // 飞行时长
  flyDuration: string = ''
  // 计划起飞时间
  planTakeoffTime: string = ''
  // 计划到达时间
  planLandingTime: string = ''
  // 实际起飞时间
  actualTakeoffTime: string = ''
  // 实际到达时间
  actualLandingTime: string = ''
  // 出发城市
  departureCity: string = ''
  // 出发机场
  departureAirport: string = ''
  // 目的城市
  destinationCity: string = ''
  // 目的机场
  destinationAirport: string = ''
  // 餐食类型
  mealType: string = ''
  // 舱位类型
  spaceType: string = ''
  // 机票含税价格
  includeTaxPrice: number = 0
  // 座位号
  seatNo: string = ''
  // 客票号
  ticketNo: string = ''
  // 状态 1-待出行；2-已结束
  status: string = ''
}

export interface TripListResult {
  ret: FunctionResultRet,
  result: Trip[]
}

export interface ResourceData {
  pageBgImages: ResourceInfo[],
  commonServices: ResourceInfo[],
  bannerServices: ResourceInfo[],
}

export interface PassengerListResult {
  ret: FunctionResultRet,
  result: PassengerInfo[]
}

export interface CommonFuncResult {
  ret: FunctionResultRet,
  result: number
}

export interface OrderListResult {
  ret: FunctionResultRet,
  result: OrderInfo[]
}

export interface UserInfoResult {
  ret: FunctionResultRet,
  result: UserInfo[]
}

export interface ResourceDataResult {
  ret: FunctionResultRet,
  result: ResourceData
}