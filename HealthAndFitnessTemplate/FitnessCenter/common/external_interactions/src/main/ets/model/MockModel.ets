@ObservedV2
export class CourseDetailModel {
  id: string;
  price: number;
  advImage: string;
  courseName: string;
  sportsType: SportTypeEnum[]
  courseNature: string
  avaiCard: string[];
  teachType: TeachType;
  serviceDetail: string;

  constructor(id: string, price: number, advImage: string, courseName: string, sportsType: SportTypeEnum[],
  courseNature: string, avaiCard: string[], teachType: TeachType, serviceDetail: string) {
    this.id = id;
    this.price = price;
    this.advImage = advImage;
    this.courseName = courseName;
    this.sportsType = sportsType;
    this.courseNature = courseNature
    this.avaiCard = avaiCard;
    this.teachType = teachType;
    this.serviceDetail = serviceDetail;
  }
}

@ObservedV2
export class CourseBookingInfo {
  id: string;
  courseId: string;
  date: string;
  weekday: number;
  timeStart: string;
  timeEnd: string;
  restQuota: number;
  totalQuota: number;
  coachId: string;

  constructor(id: string, courseId: string, date: string, weekday: number, timeStart: string, timeEnd: string,
    restQuota: number, totalQuota: number, coachId: string) {
    this.id = id;
    this.courseId = courseId;
    this.date = date;
    this.weekday = weekday;
    this.timeStart = timeStart;
    this.timeEnd = timeEnd;
    this.restQuota = restQuota;
    this.totalQuota = totalQuota;
    this.coachId = coachId;
  }
}

@ObservedV2
export class CoachCourseInfo {
  id: string;
  name: string;
  photo: string;
  introduction: string;
  courseInfos: CourseBookingInfo[];

  constructor(id: string, name: string, photo: string, introduction: string, courseInfos: CourseBookingInfo[]) {
    this.id = id;
    this.name = name;
    this.photo = photo;
    this.introduction = introduction;
    this.courseInfos = courseInfos;
  }
}

@ObservedV2
export class CardInfo {
  id: string;
  price: number;
  name: string;
  advImage: string;
  shortName: string;
  useInstruction: string;
  sportsType: SportTypeEnum[];
  cardNature: string
  avaiCourse: string;
  consumeType: ConsumeType;
  quota: number;
  saveMoney: number;
  originPrice: number;

  constructor(id: string, price: number, name: string, advImage: string, shortName: string, useInstruction: string,
    sportsType: SportTypeEnum[], cardNature: string, avaiCourse: string, consumeType: ConsumeType, quota: number,
    saveMoney: number, originPrice: number) {
    this.id = id;
    this.price = price;
    this.name = name;
    this.advImage = advImage;
    this.shortName = shortName;
    this.useInstruction = useInstruction;
    this.sportsType = sportsType;
    this.cardNature = cardNature
    this.avaiCourse = avaiCourse;
    this.consumeType = consumeType;
    this.quota = quota;
    this.saveMoney = saveMoney;
    this.originPrice = originPrice;
  }
}

export interface UserCard {
  id: string
  cardId: string;
  restQuota: number;
  buyTime: string;
}

export interface UserCourse {
  id: string;
  courseId: string;
  courseBookingId: string;
  courseState: boolean;
  bookingRecordId: string;
}

export interface BookingRecordInfo {
  id: string;
  createTime: string;
  courseBookingId: string;
  bookState: BookState;
  phone: string;
  name: string;
  personNum: number;
  remark: string;
  bookingDate: string;
  userCardId?: string;
}

export interface BookingInfo {
  courseBookingInfo: CourseBookingInfo;
  courseDetail: CourseDetailModel;
  phone: string;
  name: string;
  personNum: number;
  remark: string;
  bookState?: BookState
}

export interface OrderInfo {
  id: string,
  orderType: OrderType,
  orderState: OrderState,
  cardId?: string,
  bookingId?: string
  number: number;
  price: number;
  createTime: string;
  payTime?: string;
}

export interface SportType {
  name: string,
  typeEnum: SportTypeEnum,
  icon: string,
  advImage: string[]
}

export interface Account {
  avatar: ResourceStr;
  memberId: string;
  nickname: string;
  phone: string;
  balance: number;
  sex: string;
  birthday: string;
}

export enum BookState {
  ALL = 0,
  TO_BE_USE = 1,
  COMPLETED = 2,
  EXPIRED = 3,
  CANCELED = 4
}

export enum OrderState {
  ALL = 0,
  COMPLETED = 1,
  TO_BE_PAY = 2,
  CANCELED = 3
}

export enum SportTypeEnum {
  RUN = 1,
  YOGA = 2,
  BOXING = 3,
  BIKE = 4
}

export enum TeachType {
  GROUP = 1,
  PERSONAL = 2
}

export enum ConsumeType {
  TIMES = 1,
  DURATION = 2
}

export enum OrderType {
  CARD = 1,
  COURSE = 2
}