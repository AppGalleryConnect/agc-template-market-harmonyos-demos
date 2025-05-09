//  特展信息
export interface PerformanceNotice {
  title: string,
  content: string[][]
}

export interface PerformanceListItem {
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


// 精彩推荐
export interface RecommendListItem {
  id: string,
  img: string,
  name: string,
  detail: string,
  price: number
}


export enum TicketStatus {
  NOTHING = '2',
  HAVE = '1',
  CLOSED = '3',
}

export enum TimeStatus {
  MORNING = '1',
  AFTERNOON = '2'
}


export interface DateItem {
  date: Date;
  label: string;
}


// 不同时间段票状态
export enum BuyStatus {
  ABLE = '1',
  EXPIRED = '3',
  NOTHING = '2',
}


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


// 常用联系人 (获取，修改，新增)
export interface Contacts {
  personID: string,
  cardType: string,
  name: string,
  phone: string,
  cardID: string
}

export interface TicketListItem {
  ticketType: string,
  typeCn: string,
  price: number,
  sortId: number
}


// 购票人信息
@ObservedV2
export class TicketOwner {
  @Trace personId: string;
  @Trace name: string;
  @Trace ticketType: string;
  @Trace typeCn: string;
  @Trace ticket: number;
  @Trace price: number;
  @Trace cardType: string;
  @Trace cardId: string;
  @Trace sortId: number;

  constructor(personId: string, name: string, ticketType: string, typeCn: string, ticket: number, price: number,
    cardType: string, cardId: string, sortId: number) {
    this.personId = personId;
    this.name = name;
    this.ticketType = ticketType;
    this.typeCn = typeCn;
    this.price = price;
    this.ticket = ticket;
    this.cardType = cardType;
    this.cardId = cardId;
    this.sortId = sortId;
  }
}


// 请求时的购票人信息
export interface TicketOwnerRequest {
  personId: string,
  name: string,
  ticketType: string,
  ticket: number,
  price: number,
}

// 票种信息
@ObservedV2
export class TicketTypeInfo {
  @Trace ticketType: string;
  @Trace typeCn: string;
  @Trace count: number;
  @Trace notice: string[];
  @Trace des: string;
  @Trace limit: number;
  @Trace price: number;

  constructor(ticketType: string, typeCn: string, count: number, notice: string[], des: string, limit: number,
    price: number) {
    this.ticketType = ticketType;
    this.typeCn = typeCn;
    this.count = count;
    this.notice = notice;
    this.des = des;
    this.limit = limit;
    this.price = price;
  }
}
