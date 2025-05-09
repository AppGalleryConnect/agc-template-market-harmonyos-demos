export interface BaseResponse<T = ESObject> {
  code: number;
  msg?: string;
  data: T;
}

export interface GetUserInfoResp {
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
}

export interface UserLoginResp {
  loginToken: string;
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
}


// 推荐展览
export interface RecommendListItem {
  id: string,
  img: string,
  name: string,
  detail: string,
  price: number
}

export type GetRecommendListResp = RecommendListItem[];


// 订单列表
export interface OrderListItem {
  orderNo: string,
  visitTime: string,
  orderTime: string,
  visitor: number,
  status: string,
  actualPay?: number,
  orderAmount?: number,
  cancelTime?: string,
  placeTime?: string,
  payTime?: string,
  performanceName: string,
  orderStr?: string
}

export type GetOrderListInfoResp = OrderListItem[];

// 购票人信息
export interface TicketOwner {
  personId: string,
  name: string,
  ticketType: string,
  ticket: number,
  price: number,
}

// 订单参观人信息
export interface OrderVisitor {
  personId: string,
  name: string,
}

// 订单信息
export interface GetOrderDetailResp {
  orderNo: string,
  visitTime: string,
  orderTime: string,
  visitor: number,
  status: string,
  actualPay?: number,
  orderAmount?: number,
  cancelTime?: string,
  placeTime?: string,
  payTime?: string,
  visitors?: OrderVisitor[],
  ticketOwner?: TicketOwner[]
  contactPhone: string,
  notice: string[][],
  isFree: boolean,
  performanceName: string,
  orderStr?: string
}


//  特展信息
export interface PerformanceNotice {
  title: string,
  content: string[][]
}

interface PerformanceListItem {
  performanceId: string,
  img: string,
  title: string,
  desc: string,
  price: number,
  notice: PerformanceNotice[]
  duration: string
  location: string,
  overview: string[]
}

export type GetPerformanceInfoResp = PerformanceListItem[];


// 特展政策信息
interface PolicyContent {
  title: string,
  main: string[]
  tips: string
}

interface PerformancePolicy {
  label: string,
  content: PolicyContent[]
}

export type GetPerformancePolicyResp = PerformancePolicy[];


// 免费约展时间信息
export interface DayTicketInfo {
  date: Date,
  day: string,
  total: number,
  statusCn: string,
  status: string,
  morningAmount: number,
  afternoonAmount: number
}

export type GetDayTicketResp = DayTicketInfo[];


// 付费约展时间票务信息
export interface TimeSegment {
  label: string,
  remainTicket: number,
  buyStatus: string,
  buyStatusCn: string
}

export interface TimeTicketInfo {
  date: Date,
  day: string,
  total: number,
  statusCn: string,
  status: string,
  timeSegment: TimeSegment[]
}

export type GetTimeTicketResp = TimeTicketInfo[];


//  讲解服务文字内容
interface ExplainTextItem {
  title: string,
  content: string[]
}

export type GetExplainTextResp = ExplainTextItem[];

// 省博介绍
export interface GetIntroduceResp {
  total: string,
  content: string[]
}


// 更新用户信息
export interface UpdateUserInfoRequest {
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar?: string;
}


// 常用联系人 (获取，修改，新增)
export interface Contacts {
  personID: string,
  cardType: string,
  name: string,
  phone: string,
  cardID: string
}

export type ContactsResp = Contacts[];


// 票种信息
export interface TicketTypeInfo {
  ticketType: string,
  typeCn: string,
  count: number,
  notice: string[],
  des: string,
  limit: number,
  price: number
}


export type GetTicketTypeInfoResp = TicketTypeInfo[];

// 付费订票
export interface PrepayBuyTicketResp {
  orderNo: string;
  orderStr: string;
}

export interface ParkTextResp {
  title: string,
  content: string
}

// 交通信息
export interface GetTrafficDetailResp {
  name: string;
  coordinate: string;
}