import { util } from '@kit.ArkTS';
import { CardInfo, CourseDetailModel, DateUtil, Logger, SportTypeEnum } from '../../../../Index';
import {
  Account,
  BookingRecordInfo,
  BookState,
  CoachCourseInfo,
  ConsumeType,
  CourseBookingInfo,
  OrderInfo,
  OrderState,
  OrderType,
  SportType,
  TeachType,
  UserCard,
  UserCourse
} from '../model/MockModel';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { preferences } from '@kit.ArkData';

export const VIDEO_URL = 'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/plp/new-phones/video/pocket-series.mp4';
const TAG: string = '[MockService]';

export class MockService {
  static courseList: CourseDetailModel[] = [];
  static courseIdMap: Map<string, CourseDetailModel> = new Map();
  static userCourseList: UserCourse[] = [];
  static homeSwiperImageList: string[] = ['app.media.material11', 'app.media.material10', 'app.media.material4', 'app.media.material2']
  static sportTypeList: SportType[] = []
  static cardNatureList: string[] = []
  static courseNatureList: string[] = []
  static cardList: CardInfo[] = []
  static cardIdMap: Map<string, CardInfo> = new Map();
  static userCardList: UserCard[] = []
  static userCardMap: Map<string, UserCard> = new Map();
  static lastUsedCardId: string = '';
  static courseBookingList: CourseBookingInfo[] = [];
  static courseBookingMap: Map<string, CourseBookingInfo> = new Map();
  static coachMap: Map<string, CoachCourseInfo> = new Map();
  static bookingList: BookingRecordInfo[] = [];
  static bookingMap: Map<string, BookingRecordInfo> = new Map();
  static orderList: OrderInfo[] = [];
  static orderMap: Map<string, OrderInfo> = new Map();
  static account: Account = {
    avatar: '',
    memberId: '300589954455677',
    nickname: '',
    phone: '12345678901',
    balance: 0,
    sex: '',
    birthday: ''
  };
  static dataPreferences: preferences.Preferences;

  static init(context: Context) {
    MockService.dataPreferences = preferences.getPreferencesSync(context, { name: 'myStore' })
    MockService.courseList = MockService.getRawFile<CourseDetailModel[]>(context, 'course.json') as CourseDetailModel[];
    MockService.courseList.forEach((item: CourseDetailModel) => {
      MockService.courseIdMap.set(item.id, item);
    })

    MockService.sportTypeList = MockService.getRawFile<SportType[]>(context, 'sportTypes.json') as SportType[];

    MockService.courseNatureList = ['有氧', '力量', '塑形', '燃脂']

    MockService.cardNatureList = ['有氧', '力量', '塑形', '燃脂']

    MockService.cardList = MockService.getRawFile<CardInfo[]>(context, 'card.json') as CardInfo[];
    MockService.cardList.forEach((item: CardInfo) => {
      MockService.cardIdMap.set(item.id, item);
    })

    let courseBooking = MockService.getPreferences<CourseBookingInfo[]>('courseBooking')
    let date: Date = new Date();
    let weekdayDateMap: Map<number, string> = new Map();
    for (let i = 0; i < 7; i++) {
      // 获取一周对应的星期
      weekdayDateMap.set(date.getDay(), DateUtil.formatDate(date, '-'))
      date.setDate(date.getDate() + 1);
    }
    if (courseBooking) {
      MockService.courseBookingList = courseBooking
      MockService.courseBookingList.forEach((item: CourseBookingInfo) => {
        item.date = weekdayDateMap.get(item.weekday)!
        MockService.courseBookingMap.set(item.id, item);
      })
    } else {
      let courseInfos: CourseBookingInfo[] =
        MockService.getRawFile<CourseBookingInfo[]>(context, 'course_booking.json') as CourseBookingInfo[];
      courseInfos.forEach((item: CourseBookingInfo) => {
        item.date = weekdayDateMap.get(item.weekday)!
        MockService.courseBookingList.push(item)
        MockService.courseBookingMap.set(item.id, item);
      })
    }


    let coachInfos: CoachCourseInfo[] = MockService.getRawFile<CoachCourseInfo[]>(context, 'coach.json') as CoachCourseInfo[];
    coachInfos.forEach((item: CoachCourseInfo) => {
      MockService.coachMap.set(item.id, item);
    })

    let account = MockService.getPreferences<Account>('account')
    if (account) {
      MockService.account = account
    }

    let booking = MockService.getPreferences<BookingRecordInfo[]>('booking')
    if (booking) {
      MockService.bookingList = booking
    } else {
      MockService.bookingList = MockService.getRawFile<BookingRecordInfo[]>(context, 'booking.json') as BookingRecordInfo[];
    }
    MockService.bookingList.forEach((item: BookingRecordInfo) => {
      MockService.bookingMap.set(item.id, item);
    })

    let order = MockService.getPreferences<OrderInfo[]>('order')
    if (order) {
      MockService.orderList = order
      MockService.orderList.forEach((item: OrderInfo) => {
        MockService.orderMap.set(item.id, item);
      })
    }

    let userCard = MockService.getPreferences<UserCard[]>('userCard')
    if (userCard) {
      MockService.userCardList = userCard
      MockService.userCardList.forEach((item: UserCard) => {
        MockService.userCardMap.set(item.id, item);
      })
    }

    let userCourse = MockService.getPreferences<UserCourse[]>('userCourse')
    if (userCourse) {
      MockService.userCourseList = userCourse
    }

    // Map需序列化存储
    try {
      MockService.dataPreferences.putSync('courseBookingMap',
        JSON.stringify(Array.from(MockService.courseBookingMap.entries())));
      MockService.dataPreferences.putSync('booking', JSON.stringify(MockService.bookingList));
      MockService.dataPreferences.putSync('courses', JSON.stringify(MockService.courseList));
      MockService.dataPreferences.putSync('userCard', JSON.stringify(MockService.userCardList));
      MockService.dataPreferences.putSync('cards', JSON.stringify(MockService.cardList));
      MockService.dataPreferences.putSync('lastUsedCardId', MockService.lastUsedCardId);
      MockService.dataPreferences.flush();
    } catch (e) {
      Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
    }

    try {
      AppStorage.setOrCreate('loginState', MockService.dataPreferences.getSync('loginState', false));
    } catch (e) {
      Logger.error(TAG, `Preferences get failed. error: ${JSON.stringify(e)}`)
    }
  }

  static getCourseListBySportType(sportType: SportTypeEnum): CourseDetailModel[] {
    let list: CourseDetailModel[] = []
    MockService.courseList.forEach((item: CourseDetailModel) => {
      if (item.sportsType.includes(sportType)) {
        list.push(item)
      }
    })
    return list
  }

  static getCourseListBySearch(searchWord: string, searchSportType: SportType): CourseDetailModel[] {
    let list: CourseDetailModel[] = []
    MockService.courseList.forEach((item: CourseDetailModel) => {
      if (item.courseName.includes(searchWord) &&
        (searchSportType.typeEnum.valueOf() === 0 || item.sportsType.includes(searchSportType.typeEnum))) {
        list.push(item)
      }
    })
    return list
  }

  static getCourseListBySearchAndFilter(courseList: CourseDetailModel[], searchWord: string, index: number,
    searchCourseNature: string): CourseDetailModel[] {
    let list: CourseDetailModel[] = []
    courseList?.forEach((item: CourseDetailModel) => {
      if (item.courseName.includes(searchWord) &&
        (index === 0 || item.courseNature === searchCourseNature)) {
        list.push(item)
      }
    })
    return list
  }

  static getCourseById(courseId: string): CourseDetailModel {
    return MockService.courseIdMap.get(courseId)!
  }

  static getCardListBySportType(sportType: SportTypeEnum): CardInfo[] {
    let list: CardInfo[] = []
    MockService.cardList.forEach((item: CardInfo) => {
      if (item.sportsType.includes(sportType)) {
        list.push(item)
      }
    })
    return list
  }

  static getCardListBySearch(searchWord: string, searchSportType: SportType): CardInfo[] {
    let list: CardInfo[] = []
    MockService.cardList.forEach((item: CardInfo) => {
      if (item.name.includes(searchWord) &&
        (searchSportType.typeEnum.valueOf() === 0 || item.sportsType.includes(searchSportType.typeEnum))) {
        list.push(item)
      }
    })
    return list
  }

  static getCardListBySearchAndFilter(cardList: CardInfo[], searchWord: string, index: number,
    searchCardNature: string): CardInfo[] {
    let list: CardInfo[] = []
    cardList?.forEach((item: CardInfo) => {
      if (item.name.includes(searchWord) &&
        (index === 0 || item.cardNature === searchCardNature)) {
        list.push(item)
      }
    })
    return list
  }

  static getCardById(cardId: string): CardInfo {
    return MockService.cardIdMap.get(cardId)!
  }

  static getUserCardById(id: string): UserCard {
    return MockService.userCardMap.get(id)!
  }

  static getUserCardByCardId(cardId: string): UserCard {
    let sortList = MockService.userCardList
      .filter((value: UserCard) => value.cardId === cardId)
      .sort((a, b) => {
        return b.restQuota - a.restQuota;
      })
    return sortList[0]
  }

  static getQuotaDurationDesc(quota: number): string {
    return quota === 365 ? '年' : (quota === 90 ? '季' : '月')
  }

  static getCardExpireDate(userCard: UserCard): Date {
    let date: Date = DateUtil.parseDateString(userCard.buyTime);
    date.setDate(date.getDate() + userCard.restQuota);
    return date
  }

  static getCoachCourseInfoListBySearch(searchWord: string, searchSportType: SportType, date: Date): CoachCourseInfo[] {
    let list: CoachCourseInfo[] = []
    let now: Date = new Date();
    let coachBookingMap: Map<string, CourseBookingInfo[]> = new Map();
    MockService.courseBookingList.forEach((item: CourseBookingInfo) => {
      let courseDetail = MockService.getCourseById(item.courseId)
      if (courseDetail.teachType === TeachType.PERSONAL && courseDetail.courseName.includes(searchWord) &&
        (searchSportType.typeEnum.valueOf() === 0 || courseDetail.sportsType.includes(searchSportType.typeEnum)) &&
        DateUtil.formatDate(date, '-') === item.date &&
        DateUtil.parseDateString(item.date + ' ' + item.timeStart).getTime() > now.getTime()) {
        if (coachBookingMap.has(item.coachId)) {
          let courseBooKingInfoList: CourseBookingInfo[] = coachBookingMap.get(item.coachId)!
          courseBooKingInfoList.push(item)
        } else {
          let courseBooKingInfoList: CourseBookingInfo[] = []
          courseBooKingInfoList.push(item)
          coachBookingMap.set(item.coachId, courseBooKingInfoList)
        }
      }
    })
    coachBookingMap.forEach((value: CourseBookingInfo[], key) => {
      let coachCourseInfo: CoachCourseInfo = MockService.coachMap.get(key)!
      coachCourseInfo.courseInfos = value
      list.push(coachCourseInfo)
    })
    return list
  }

  static getCourseBookingInfoListBySearch(searchWord: string, searchSportType: SportType,
    date: Date): CourseBookingInfo[] {
    let list: CourseBookingInfo[] = []
    let now: Date = new Date();
    MockService.courseBookingList.forEach((item: CourseBookingInfo) => {
      let courseDetail = MockService.getCourseById(item.courseId)
      if (courseDetail.courseName.includes(searchWord) &&
        (searchSportType?.typeEnum.valueOf() === 0 || courseDetail.sportsType.includes(searchSportType?.typeEnum)) &&
        courseDetail.teachType === TeachType.GROUP && DateUtil.formatDate(date, '-') === item.date &&
        DateUtil.parseDateString(item.date + ' ' + item.timeStart).getTime() > now.getTime()) {
        list.push(item)
      }
    })
    return list
  }

  static searchCourseBooking(searchWord: string): CourseBookingInfo | undefined {
    let first: CourseBookingInfo | undefined = undefined
    let now: Date = new Date();
    let courseSortList = MockService.courseBookingList
      .sort((a, b) => {
        const timeA = DateUtil.parseDateString(a.date);
        const timeB = DateUtil.parseDateString(b.date);
        return timeA.getTime() - timeB.getTime();
      })
      .filter(item => DateUtil.parseDateString(item.date + ' ' + item.timeStart).getTime() > now.getTime());
    for (let i = 0; i < courseSortList.length; i++) {
      let item = courseSortList[i];
      let courseDetail = MockService.getCourseById(item.courseId)
      if (courseDetail.courseName.includes(searchWord)) {
        if (item.restQuota > 0) {
          return item;
        } else {
          if (first === undefined) {
            first = item
          }
        }
      }
    }
    return first;
  }

  static getCourseBookingById(id: string): CourseBookingInfo {
    return MockService.courseBookingMap.get(id)!
  }

  static getBookingListByState(bookingState: BookState): BookingRecordInfo[] {
    let list: BookingRecordInfo[] = [];
    let now: Date = new Date();
    MockService.bookingList.forEach((item: BookingRecordInfo) => {
      if (item.bookState === BookState.TO_BE_USE) {
        let bookingInfo = MockService.getCourseBookingById(item.courseBookingId)
        // 超时订单更新订单状态为已过期
        if (DateUtil.parseDateString(item.bookingDate + ' ' + bookingInfo.timeStart).getTime() <= now.getTime()) {
          item.bookState = BookState.EXPIRED
        }
      }
      if (item.bookState === bookingState || bookingState === BookState.ALL) {
        list.push(item)
      }
    })
    return list;
  }

  static getBookingRecordById(id: string): BookingRecordInfo {
    return MockService.bookingMap.get(id)!
  }

  static getOrderListByState(orderState: OrderState): OrderInfo[] {
    let list: OrderInfo[] = [];
    if (orderState === OrderState.ALL) {
      return MockService.orderList;
    } else {
      MockService.orderList.forEach((item: OrderInfo) => {
        if (item.orderState === orderState) {
          list.push(item)
        }
      })
      return list;
    }
  }

  static getOrderById(orderId: string): OrderInfo {
    return MockService.orderMap.get(orderId)!
  }

  static getBookStateString(state: number): string {
    switch (state) {
      case BookState.ALL:
        return '全部'
      case BookState.TO_BE_USE:
        return '待使用'
      case BookState.COMPLETED:
        return '已完成'
      case BookState.EXPIRED:
        return '已过期'
      case BookState.CANCELED:
        return '已取消'
      default:
        return ''
    }
  }

  static getOrderStateString(state: number): string {
    switch (state) {
      case OrderState.ALL:
        return '全部'
      case OrderState.COMPLETED:
        return '已完成'
      case OrderState.TO_BE_PAY:
        return '待支付'
      case OrderState.CANCELED:
        return '已取消'
      default:
        return ''
    }
  }

  static saveAccountInfo(nickname: string, phone: string, sex: string, birthday: string, avatar: ResourceStr) {
    MockService.account.nickname = nickname
    MockService.account.phone = phone
    MockService.account.sex = sex
    MockService.account.birthday = birthday
    MockService.account.avatar = avatar
    try {
      MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account));
      MockService.dataPreferences.flush();
    } catch (e) {
      Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
    }
  }

  static createOrder(orderType: OrderType, orderState: OrderState, number: number, price: number, cardId?: string,
    bookingId?: string): OrderInfo {
    let order: OrderInfo = {
      id: MockService.generateDigitString(11),
      orderType: orderType,
      orderState: orderState,
      number: number,
      price: price,
      createTime: DateUtil.formatDate(new Date(), '-', undefined, 'medium')
    }
    if (orderType === OrderType.CARD) {
      order.cardId = cardId
      if (order.cardId?.length === 0) {
        order.bookingId = bookingId
      }
    } else {
      order.bookingId = bookingId
    }
    if (orderState === OrderState.COMPLETED) {
      order.payTime = DateUtil.formatDate(new Date(), '-', undefined, 'medium')
    }

    MockService.orderList.splice(0, 0, order);
    MockService.orderMap.set(order.id, order);
    try {
      MockService.dataPreferences.putSync('order', JSON.stringify(MockService.orderList));
      MockService.dataPreferences.flush();
    }  catch (e) {
      Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
    }
    return order;
  }

  static createBookingRecord(courseBookingId: string, bookState: BookState, phone: string, name: string,
    personNum: number, remark: string, bookingDate: string, userCardId?: string): BookingRecordInfo {
    let bookingRecord: BookingRecordInfo = {
      id: MockService.generateDigitString(11),
      createTime: DateUtil.formatDate(new Date(), '-', undefined, 'medium'),
      courseBookingId: courseBookingId,
      bookState: bookState,
      phone: phone,
      name: name,
      personNum: personNum,
      remark: remark,
      userCardId: userCardId,
      bookingDate: bookingDate
    }

    MockService.bookingList.splice(0, 0, bookingRecord);
    MockService.bookingMap.set(bookingRecord.id, bookingRecord);
    try {
      MockService.dataPreferences.putSync('booking', JSON.stringify(MockService.bookingList));
      MockService.dataPreferences.flush();
    } catch (e) {
      Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
    }
    return bookingRecord;
  }

  static addUserCourse(courseId: string): UserCourse {
    let userCourse: UserCourse = {
      id: MockService.generateDigitString(11),
      courseId: courseId,
      courseBookingId: '',
      courseState: false,
      bookingRecordId: ''
    }
    MockService.userCourseList.push(userCourse);
    try {
      MockService.dataPreferences.putSync('userCourse', JSON.stringify(MockService.userCourseList));
      MockService.dataPreferences.flush();
    } catch (e) {
      Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
    }
    return userCourse;
  }

  static removeUserCourse(id: string): void {
    const existingCourseIndex = MockService.userCourseList.findIndex(userCourse => userCourse.id === id);
    if (existingCourseIndex !== -1) {
      // 退回余额
      const existingCourse = MockService.userCourseList[existingCourseIndex];
      const courseDetail = MockService.getCourseById(existingCourse.courseId)
      const returnPrice = courseDetail.price
      MockService.account.balance += parseFloat(returnPrice.toFixed(2))

      // 更新映射表，删除课程
      MockService.userCourseList.splice(existingCourseIndex, 1)

      // 保存到持久化存储
      try {
        MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account));
        MockService.dataPreferences.putSync('userCourse', JSON.stringify(MockService.userCourseList));
        MockService.dataPreferences.flush();
      } catch (e) {
        Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
      }
    } else {
      Logger.error(TAG, `UserCourse ${id} not exist.`)
    }
  }


  static addUserCard(cardId: string, restQuota: number): UserCard {
    const existingCardIndex = MockService.userCardList.findIndex(card => card.cardId === cardId);
    if (existingCardIndex !== -1) {
      // 如果已持有，叠加卡项次数或有效期
      const existingCard = MockService.userCardList[existingCardIndex];
      existingCard.restQuota += restQuota; // 叠加剩余次数

      // 更新映射表和列表
      MockService.userCardMap.set(existingCard.id, existingCard);
      MockService.userCardList[existingCardIndex].restQuota = existingCard.restQuota

      // 保存到持久化存储
      try {
        MockService.dataPreferences.putSync('userCard', JSON.stringify(MockService.userCardList));
        MockService.dataPreferences.flush();
      } catch (e) {
        Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
      }

      return existingCard;
    } else {
      // 如果未持有，创建新卡项
      let userCard: UserCard = {
        id: MockService.generateDigitString(11),
        cardId: cardId,
        restQuota: restQuota,
        buyTime: DateUtil.formatDate(new Date(), '-', undefined, 'medium'),
      }
      MockService.userCardList.push(userCard);
      MockService.userCardMap.set(userCard.id, userCard);
      try {
        MockService.dataPreferences.putSync('userCard', JSON.stringify(MockService.userCardList));
        MockService.dataPreferences.flush();
      } catch (e) {
        Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
      }
      return userCard;
    }
  }

  static removeUserCard(cardId: string): void {
    const existingCardIndex = MockService.userCardList.findIndex(card => card.cardId === cardId);
    if (existingCardIndex !== -1) {
      // 退回余额
      const existingCard = MockService.userCardList[existingCardIndex];
      const cardInfo = MockService.getCardById(existingCard.cardId)
      const returnPrice = (existingCard.restQuota / cardInfo.quota) * cardInfo.price
      MockService.account.balance += parseFloat(returnPrice.toFixed(2))

      // 更新映射表，删除卡项
      MockService.userCardList.splice(existingCardIndex, 1)
      MockService.userCardMap.delete(existingCard.id)

      // 保存到持久化存储
      try {
        MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account));
        MockService.dataPreferences.putSync('userCard', JSON.stringify(MockService.userCardList));
        MockService.dataPreferences.flush();
      } catch (e) {
        Logger.error(TAG, `Preferences put failed. error: ${JSON.stringify(e)}`)
      }
    } else {
      Logger.error(TAG, `UserCard ${cardId} not exist.`)
    }
  }

  static userCardCanUse(userCard: UserCard): boolean {
    let cardInfo: CardInfo = MockService.getCardById(userCard.cardId)
    if (cardInfo?.consumeType === ConsumeType.TIMES) {
      return userCard.restQuota > 0
    } else {
      let now = new Date()
      return MockService.getCardExpireDate(userCard) > now
    }
  }

  static generateDigitString(count: number): string {
    // 获取13位时间戳并转为字符串
    const timestamp = new Date().getTime().toString();
    // 截取时间戳后6位（包含毫秒级变化）
    const timePart = timestamp.substring(7);

    // 剩余位置生成随机数（补零确保长度）
    const randomPart = MockService.doRandBySync(2)
      .toString()
      .padStart(count - 6, '0'); // 补零

    // 4. 拼接并返回结果
    return timePart + randomPart;
  }

  static doRandBySync(len: number): number {
    let rand = cryptoFramework.createRandom();
    let randData = rand.generateRandomSync(len);
    if (randData != null) {
      return randData.data.reduce((acc, byte) => acc * 256 + byte, 0); // 将字节转换为整数
    } else {
      Logger.error(TAG, '[Sync]: get rand result fail!');
    }
    return 0
  }

  static getRawFile<T>(context: Context, filePath: string): T | null {
    if (typeof context.resourceManager.getRawFileContentSync === 'function') {
      const value = context.resourceManager.getRawFileContentSync(filePath);
      return JSON.parse(MockService.bufferToString(value)) as T;
    }
    Logger.error(TAG, 'Sync API not available');
    return null;
  }

  static getPreferences<T>(key: string): T | undefined {
    let value = MockService.dataPreferences.getSync(key, '');
    if (value.toString().length > 0) {
      return JSON.parse(value.toString()) as T;
    }
    return undefined;
  }

  static bufferToString(buffer: Uint8Array): string {
    let textDecoder = util.TextDecoder.create('utf-8', {
      ignoreBOM: true
    });
    let resultPut = textDecoder.decodeToString(buffer);
    return resultPut;
  }
}