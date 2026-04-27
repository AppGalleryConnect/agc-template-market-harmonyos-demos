import { OrderStatus } from './OrderModel'
import { TravelPeopleModel } from './TravelPeopleModel'

// 机票详情
@ObservedV2
export class TicketDetailListModel {
  @Trace startDate: string = ''
  @Trace endDate: string = ''
  @Trace startLocation?: string = ''
  @Trace endLocation?: string = ''
  @Trace aviation?: string = ''
  @Trace price?: string = ''
  @Trace dark?: string = ''
  @Trace boeing?: string = ''
  @Trace seatNo: string = ''
  @Trace currentCity: string = '北京'
  @Trace returnCity: string = '上海'
  @Trace type: number = 0
  @Trace weekDate: string = ''
  @Trace timeDate: string = '2025-12-15'
  @Trace returnPrice: string = '0'
  @Trace chooseStatus: number = 0
  @Trace status: OrderStatus = OrderStatus.PENDING
  @Trace peopleList: TravelPeopleModel[] = []
  @Trace scenicRefundCreateDate: string = ''
  @Trace boardingGate: string = '首都机场2号航站楼'
  @Trace boardingGateNo: string = '3号登机口'
  @Trace cabinClass: string = '经济舱'
  @Trace ticketCreateDate: string = ''
  @Trace ticketOrderNum: string = ''
}

// 飞机票往返详情
@ObservedV2
export class TicketReturnDetailListModel {
  @Trace ticketGo: TicketDetailListModel = new TicketDetailListModel()
  @Trace ticketBack: TicketDetailListModel = new TicketDetailListModel()
}

// 火车票单程详情
@ObservedV2
export class PlaneDetailListModel {
  @Trace startDate: string = ''
  @Trace endDate: string = ''
  @Trace startLocation: string = ''
  @Trace endLocation: string = ''
  @Trace duration: string = ''
  @Trace trainNumber: string = ''
  @Trace firstClass: string = ''
  @Trace secondClass: string = ''
  @Trace businessClass: string = ''
  @Trace noSeat: string = ''
  @Trace price: string = ''
  @Trace returnPrice: string = '0'
  @Trace currentCity: string = '北京'
  @Trace returnCity: string = '上海'
  @Trace type: number = 0
  @Trace carriageNum: string = '15车12A号'
  @Trace ticketCheckpoint: string = '二层12，二层13，负一层2快速进站厅12、13'
  @Trace weekDate: string = ''
  @Trace timeDate: string = '2025-12-15'
  @Trace seatClass: string = '二等座'
  @Trace peopleList: TravelPeopleModel[] = []
  @Trace chooseStatus: number = 0
  @Trace status: OrderStatus = OrderStatus.PENDING
  @Trace scenicRefundCreateDate: string = ''
  @Trace ticketCreateDate: string = ''
  @Trace ticketOrderNum: string = ''
  @Trace time: number = 0
}

// 火车票往返详情
@ObservedV2
export class PlaneReturnDetailListModel {
  @Trace planeGo: PlaneDetailListModel = new PlaneDetailListModel()
  @Trace planeBack: PlaneDetailListModel = new PlaneDetailListModel()
}

// 火车票座位等级详情
@ObservedV2
export class PlaneTypeModel {
  @Trace type: string = ''
  @Trace price: number = 0
  @Trace tickets: number = 0
}

// 飞机票座位等级详情
@ObservedV2
export class TicketTypeModel {
  @Trace type: string = ''
  @Trace price: number = 0
}

//机票数据
@ObservedV2
export class TicketPriceModel {
  @Trace date: string = ''
  @Trace dateCode: string = ''
  @Trace price: string = ''
  @Trace id: number = 0
  @Trace dataArray: TicketPriceListModel[] = []
  @Trace dateNumber?: number = 0
}

@ObservedV2
export class TicketPriceListModel {
  @Trace startDate: string = ''
  @Trace endDate: string = ''
  @Trace startLocation: string = ''
  @Trace endLocation: string = ''
  @Trace aviation: string = ''
  @Trace price: string = ''
  @Trace dark: string = ''
  @Trace boeing: string = ''
  @Trace id: string = ''
}

//火车票数据
@ObservedV2
export class TrainTicketPriceModel {
  @Trace date: string = ''
  @Trace dateCode: string = ''
  @Trace price: string = ''
  @Trace id: number = 0
  @Trace dataArray: TrainTicketPriceListModel[] = []
  @Trace dateNumber?: number = 0
}

@ObservedV2
export class TrainTicketPriceListModel {
  @Trace startDate: string = ''
  @Trace endDate: string = ''
  @Trace startLocation: string = ''
  @Trace endLocation: string = ''
  @Trace duration: string = ''
  @Trace trainNumber: string = ''
  @Trace firstClass: string = ''
  @Trace secondClass: string = ''
  @Trace businessClass: string = ''
  @Trace noSeat: string = ''
  @Trace price: string = ''
  @Trace id: string = ''
}

// 通用列表项接口，供公共初始化方法使用，避免内联对象字面量类型
export interface PriceListCommon<TItem> {
  date: string
  dateCode: string
  price: string
  id: number
  dataArray: TItem[]
  dateNumber?: number
}

@ObservedV2
export class PlanePageVM {
  @Trace searchContent: string = ''
  @Trace chooseStatus: number = 0
  @Trace returnSatus: number = 0
  @Trace currentCity: string = '北京市'
  @Trace returnCity: string = '上海市'
  @Trace currentCity1: string = '北京市'
  @Trace returnCity1: string = '上海市'
  @Trace currentReturn: boolean = false
  @Trace placeName: string = ''
  @Trace backWeek: string = ''
  @Trace goWeek: string = ''
  @Trace selectTravelerId: TravelPeopleModel[] = []
  @Trace startDate: string = (new Date().getMonth() + 1) + '-' + new Date().getDate().toString()
  @Trace endDate: string = (new Date().getMonth() + 1) + '-' + (new Date().getDate() + 1).toString()
  @Trace startYear: number = 0
  @Trace endYear: number = 0
  @Trace locationPermission: boolean = false
}

export enum ChooseStatus {
  Aircraft = 0, //机票
  Train = 1, //火车票
  Bus = 2 //汽车票
}

export enum TripType {
  OneWay = 0, //单程
  Return = 1 //往返
}

//实名认证
@ObservedV2
export class Authentication {
  @Trace authentication: boolean = false
}
