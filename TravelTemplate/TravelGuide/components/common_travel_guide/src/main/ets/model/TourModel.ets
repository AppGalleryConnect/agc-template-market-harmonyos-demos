import { OrderInfo } from './OrderModel'
import { PassengerInfo } from './PassengerModel'
import { Type } from '@kit.ArkUI'

export interface Meals {
  breakfast: boolean
  lunch: boolean
  dinner: boolean
}

export interface ItineraryDay {
  day: number
  title: string
  activities?: Activity[]
  meals: Meals
  hotel: string
}

export interface Activity {
  icon?: string
  activity?: string
}

export interface Fees {
  include?: string[]
  exclude?: string[]
}

export interface NearbyAttraction {
  name: string
  rating: number
  distance: string
  image: string
}


@ObservedV2
export class TourModel {
  @Trace id: number = 0
  @Trace title: string = ''
  @Trace subTitle: string = ''
  @Trace province: string = ''
  @Trace cities?: string[] = []
  @Trace days: number = 0
  @Trace nights: number = 0
  @Trace groupType: string = ''
  @Trace rating: number = 0
  @Trace reviewCount: number = 0
  @Trace priceFrom: number = 0
  @Trace originalPrice: number = 0
  @Trace image?: string = ''
  @Trace tags?: string[] = []
  @Trace highlights?: string[] = []
  @Trace itinerary?: ItineraryDay[] = []
  @Trace fees?: Fees
  @Trace bookingNotes?: string[] = []
  @Trace gifts?: string[] = []
  @Trace nearbyAttractions?: NearbyAttraction[] = []
  @Trace lineSchedule: LineSchedule[] = []
}

@ObservedV2
export class CollectTourModel {
  @Trace id: number = 0
}


// 线路班期（从当天起的未来若干天）
export interface LineSchedule {
  date: string,
  dateCode: string,
  price: number,
  createDate: number | Date
}

// 详情特色、购买须知
export interface DetailsFeatures {
  id: number,
  icon: string,
  title: string,
  describe: string[] | string
}

// 购买须知表格
export interface tableItem {
  title?: string,
  contentList?: string[],
  color?: string
}

export interface tableContent {
  describe?: string,
  subDescribe?: string,
  tableList: tableItem[],
  remark?: string,
  color?: string
}

export interface detailRouterParam {
  scenicMockInfo: TourModel | null
  price: number // 单价
  starTime: string // 出发时间
  endTime: string // 返程时间
  scheduleDateCode: string // 班期
  grownManNum?: number // 成人数量
  childrenNum?: number // 儿童数量
  passengerInfo?: PassengerInfo[] // 出行人信息
  contactPhone?: string | number // 联系电话
}

export interface TourOrderRouterParam {
  orderInfo: OrderInfo
  isPulUpPay: boolean
}

export type TourList = TourModel[]


// 旅游首页跳转旅游搜索页列表的传参
@ObservedV2
export class TourPageParam {
  // 选项卡
  @Trace chooseStatus: number = 0
  // 地址或搜索关键字
  @Trace keyword: string
  // 游玩天数
  @Trace playDays: string

  constructor(chooseStatus: number, keyword: string, playDays: string) {
    this.chooseStatus = chooseStatus
    this.keyword = keyword
    this.playDays = playDays
  }
}


@ObservedV2
export class TourCollectListModel {
  @Type(CollectTourModel)
  // 收藏列表
  @Trace tourCollectList: CollectTourModel[] = []

  // 新增
  addList(id: number): void {
    let collectItem = new CollectTourModel()
    collectItem.id = id
    this.tourCollectList.push(collectItem);
  }

  // 删除
  removeList(id: number): void {
    let index = this.tourCollectList.findIndex((item: CollectTourModel) => item.id === id)
    this.tourCollectList.splice(index, 1);
  }
}