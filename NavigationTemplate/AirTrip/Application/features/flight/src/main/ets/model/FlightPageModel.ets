
export enum SortBy {
  TIME = 'time',
  PRICE = 'price'
}

@ObservedV2
export class FlightInfo {
  // 航班id
  id: string = ''
  // 航班号
  flightNo: string = ''
  // 航空公司名称
  airlineName: string = ''
  // 机型
  aircraftType: string = ''
  // 起飞时间
  takeoffTime: string = ''
  // 到达时间
  landingTime: string = ''
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
  // 最低舱位价
  lowestPrice: string = ''
  // 最低舱位折扣
  lowestDiscount: string = ''
}

// 机票信息
@ObservedV2
export class FlightSpaceInfo {
  id:	string = '' // 舱位ID
  flightId: string = '' // 航班ID
  spaceType: string = '' // 舱位类型
  spacePrice:	string = '' // 舱位价格
  spaceDiscount: string = '' // 舱位折扣
  refundChangePolicy:	string = '' // 退改政策
  baggagePolicy: string = '' // 行李政策
}

// 乘机人信息
@ObservedV2
export class PassengerInfo {
  id: string = '' // ID
  name: string = '' // 姓名
  certificateType: string = '' // 证件类型
  certificateNo: string = '' // 证件号码
  phone: string = '' // 手机号码
}

export interface FlightOrderInfo {
  flightInfo: FlightInfo
  spaceInfo: FlightSpaceInfo
}

export class Instruct {
  name: string = ''
  linkUrl: ResourceStr = ''
  constructor(name: string, linkUrl: ResourceStr) {
    this.name = name
    this.linkUrl = linkUrl
  }
}

export class FlightPageModel {
  // 获取航班舱位信息列表
  static getFlightSpaceList(flightInfo: FlightInfo): FlightSpaceInfo[] {
    let list: FlightSpaceInfo[] = []
    let firstPrice = flightInfo.lowestPrice
    let firstDiscount = flightInfo.lowestDiscount
    let prices: string[] = [
      firstPrice, String(Number(firstPrice) + 80), String(Number(firstPrice) + 109),
      String(Number(firstPrice) + 130), String(Number(firstPrice) + 216), String(Number(firstPrice) + 245),
      String(Number(firstPrice) + 268), String(Number(firstPrice) + 280), String(Number(firstPrice) + 310),
      String(Number(firstPrice) + 355)
    ]
    let discounts: string[] = [
      firstDiscount, String(Number(firstDiscount) + 1.1), String(Number(firstDiscount) + 1.5),
      String(Number(firstDiscount) + 1.6), String(Number(firstDiscount) + 2.0), String(Number(firstDiscount) + 2.2),
      String(Number(firstDiscount) + 2.5), String(Number(firstDiscount) + 2.9), String(Number(firstDiscount) + 3.2),
      String(Number(firstDiscount) + 3.2)
    ]
    let refundChangePolicys: string[] = ['提前退改', '提前改期免费', '改退签']

    for (let i = 0; i < 10; i++) {
      let spaceItem: FlightSpaceInfo = new FlightSpaceInfo()
      spaceItem.id = 'id_' + i
      spaceItem.flightId = 'flight_id_' + i
      spaceItem.spaceType = i % 2 === 0 ? 'ECONOMY_CLASS' : 'FIRST_CLASS'
      spaceItem.spacePrice = prices[i]
      spaceItem.spaceDiscount = discounts[i]
      spaceItem.refundChangePolicy = i % 3 === 0 ? (refundChangePolicys[0] + '￥' + prices[i]) : refundChangePolicys[i % 3]
      spaceItem.baggagePolicy = i % 2 === 0 ? '托运行李额20KG': '托运行李额30KG'

      list.push(spaceItem)
    }
    return list
  }

  static getInstructionList(): Instruct[] {
    return [
      new Instruct('《预订须知》', $rawfile('h5page.html')),
      new Instruct('《锂电池运输安全规定》', $rawfile('h5page.html')),
      new Instruct('《民航旅客禁止、限制随身携带和托运物品目录》', $rawfile('h5page.html')),
    ]
  }
}

interface FunctionResultRet {
  code: number
  desc: string
}

export interface FlightListResult {
  ret: FunctionResultRet,
  result: FlightInfo[]
}