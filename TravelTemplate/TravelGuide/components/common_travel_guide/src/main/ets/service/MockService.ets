import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { HotelModel } from '../model/HotelModel';
import { TravelerModel } from '../model/TravelerModel';
import { TourModel } from '../model/TourModel';
import { CalendarUtil } from '../util/CalendarUtil';
import {
  PriceListCommon,
  TicketPriceListModel,
  TicketPriceModel,
  TrainTicketPriceListModel,
  TrainTicketPriceModel
} from '../model/TicketPriceModel';
import { SecureRandomUtil } from 'common';

// 模拟酒店数据
@ObservedV2
export class MockService {
  @Trace public static hotelResult: HotelModel[] = []

  public static init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('hotelMock.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      MockService.hotelResult = JSON.parse(resultPut) as HotelModel[]

    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}

// 模拟酒店数据
@ObservedV2
export class MockOverseasService {
  @Trace public static hotelResult: HotelModel[] = []

  public static init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('overseasHotelMock.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      MockOverseasService.hotelResult = JSON.parse(resultPut) as HotelModel[]

    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}

//模拟出行人数据显示
@ObservedV2
export class MockTravelerService {
  @Trace public static travelerResult: TravelerModel[] = []

  public static init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('travelerMock.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      MockTravelerService.travelerResult = JSON.parse(resultPut) as TravelerModel[]

    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}

// 动态计算日期数据
export class MockPublicPrice {
  // 方法1：先生成开始时间，确保结束时间在20:00之前
  public static generateRandomTimeWithDuration(durationHours: number) {
    // 将4.5小时转换为分钟
    const durationMinutes = durationHours * 60;

    // 计算允许的开始时间范围
    // 最晚开始时间 = 20:00 - durationMinutes
    const latestStartMinutes = 20 * 60 - durationMinutes;

    // 最早开始时间是8:00
    const earliestStartMinutes = 8 * 60;

    // 生成随机开始分钟数
    const randomStartMinutes = Math.floor(
      SecureRandomUtil.getRandomNumber(1) * (latestStartMinutes - earliestStartMinutes)
    ) + earliestStartMinutes;

    // 计算开始时间的小时和分钟
    const startHour = Math.floor(randomStartMinutes / 60);
    const startMinute = randomStartMinutes % 60;

    // 计算结束时间
    const endMinutes = randomStartMinutes + durationMinutes;
    const endHour = Math.floor(endMinutes / 60);
    const endMinute = Math.floor(endMinutes % 60);
    const startDate = `${startHour.toString().padStart(2, '0')}:${startMinute.toString().padStart(2, '0')}`
    const endDate = `${endHour.toString().padStart(2, '0')}:${endMinute.toString().padStart(2, '0')}`
    return [startDate, endDate]
  }

  public static initList<TItem>(lists: PriceListCommon<TItem>[], listData: TItem, index: number) {
    lists[index].id = index
    let randomListNum = SecureRandomUtil.getRandomNumber(1) * 2 + 10;
    let randomNum = SecureRandomUtil.getRandomNumber(1) * 0.5 + 1.0;
    lists[index].price = String((500 * randomNum).toFixed(0))
    //创建一个表示当前日期的Date对象
    let today = new Date();
    // 创建一个新的Date对象，表示index天后的日期
    let fiveDaysLater = new Date(today);
    fiveDaysLater.setDate(today.getDate() + index);
    // 获取index天后的日期是周几
    let dayOfWeek = fiveDaysLater.getDay();
    const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    let curDateNumber = new Date(new Date().toDateString()).getTime();
    if (index <= (31 - new Date().getDate())) {
      if (index === 0) {
        lists[0].dateNumber = curDateNumber
        lists[0].date = '今天'
        lists[0].dateCode = (new Date().getMonth() + 1) + '-' + new Date().getDate().toString()
      } else if (index === 1) {
        lists[1].dateNumber = (curDateNumber + (24 * 60 * 60 * 1000) * index)
        lists[1].date = '明日'
        lists[1].dateCode = (new Date().getMonth() + 1) + '-' + (new Date().getDate() + index).toString()
      } else if (index === 2) {
        lists[2].dateNumber = (curDateNumber + (24 * 60 * 60 * 1000) * index)
        lists[2].date = '后天'
        lists[2].dateCode = (new Date().getMonth() + 1) + '-' + (new Date().getDate() + index).toString()
      } else {
        lists[index].dateNumber = (curDateNumber + (24 * 60 * 60 * 1000) * index)
        lists[index].dateCode =
          (new Date().getMonth() + 1) + '-' + (Number(new Date().getDate()) + index).toString()
        lists[index].date = days[dayOfWeek]
      }

    } else if (index <= (31 - new Date().getDate() + 31)) {
      lists[index].dateNumber = (curDateNumber + (24 * 60 * 60 * 1000) * index)
      lists[index].dateCode = (new Date().getMonth() + 2 > 12 ? 1 : new Date().getMonth() + 2) + '-' +
      (Number(new Date().getDate()) + index - 31).toString()
      lists[index].date = days[dayOfWeek]
    } else if (index > (31 - new Date().getDate() + 31)) {
      lists[index].dateNumber = (curDateNumber + (24 * 60 * 60 * 1000) * index)
      let date: number = 0
      if (new Date().getMonth() + 3 === 13) {
        date = 1
      } else if (new Date().getMonth() + 3 === 14) {
        date = 2
      } else {
        date = new Date().getMonth() + 3
      }
      lists[index].dateCode = date + '-' + (index - 31 - (31 - new Date().getDate())).toString()
      lists[index].date = days[dayOfWeek]
    }

    lists[index].dataArray.push(listData)
    for (let number = 0; number < randomListNum; number++) {
      lists[index].dataArray.push(listData)
    }
  }
}

// 模拟机票价格列表
@ObservedV2
export class MockTicketPriceService {
  @Trace public static travelerResult: TicketPriceModel[] = []

  public static init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('ticketPrices.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      let lists: TicketPriceModel[] = JSON.parse(resultPut) as TicketPriceModel[]
      let datas: number = 90
      let time = new Date().getTime()
      for (let index = 0; index < datas; index++) {
        let listData: TicketPriceListModel = {
          'id': `plane_go_${index}_${time}`,
          'startDate': MockPublicPrice.generateRandomTimeWithDuration(2.2)[0],
          'endDate': MockPublicPrice.generateRandomTimeWithDuration(2.2)[1],
          'startLocation': '首都T2',
          'endLocation': '虹桥T1',
          'aviation': '海南航空HU760',
          'boeing': '波音783',
          'price': String(Math.max(199,
            Math.round(689 + Math.floor(SecureRandomUtil.getRandomNumber(1) * 300) + 150))),
          'dark': '特惠经济舱3.1折'
        }
        MockPublicPrice.initList(lists, listData, index)
        MockTicketPriceService.travelerResult = lists
      }
    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}

// 模拟机票返程价格列表
@ObservedV2
export class MockTicketReturnPriceService {
  @Trace public static travelerResult: TicketPriceModel[] = []

  public static init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('ticketReturnPrices.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      let lists: TicketPriceModel[] = JSON.parse(resultPut) as TicketPriceModel[]
      let datas: number = 90
      for (let index = 0; index < datas; index++) {
        let time = new Date().getTime()
        let listData: TicketPriceListModel = {
          'id': `plane_back_${index}_${time}`,
          'startDate': MockPublicPrice.generateRandomTimeWithDuration(3.2)[0],
          'endDate': MockPublicPrice.generateRandomTimeWithDuration(3.2)[1],
          'startLocation': '虹桥T1',
          'endLocation': '首都T2',
          'aviation': '海南航空HU76',
          'boeing': '波音783',
          'price': String(Math.max(189,
            Math.round(459 + Math.floor(SecureRandomUtil.getRandomNumber(1) * 460) + 250))),
          'dark': '特惠经济舱3.1折'
        }
        MockPublicPrice.initList(lists, listData, index)
        MockTicketReturnPriceService.travelerResult = lists
      }
    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}

// 模拟火车票单程价格列表
@ObservedV2
export class MockTrainTicketPriceService {
  @Trace public static travelerResult: TrainTicketPriceModel[] = []

  public static init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('trainPrices.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      let lists: TrainTicketPriceModel[] = JSON.parse(resultPut) as TrainTicketPriceModel[]
      let datas: number = 90
      for (let index = 0; index < datas; index++) {
        let time = new Date().getTime()
        let listData: TrainTicketPriceListModel = {
          'id': `ticket_go_${index}_${time}`,
          'startDate': MockPublicPrice.generateRandomTimeWithDuration(4.2)[0],
          'endDate': MockPublicPrice.generateRandomTimeWithDuration(4.2)[0],
          'startLocation': '北京西',
          'endLocation': '上海虹桥',
          'duration': '4时30分',
          'trainNumber': 'G35',
          'firstClass': '有座',
          'secondClass': '有座',
          'businessClass': '抢',
          'noSeat': '4张',
          'price': String(Math.max(199, Math.round(349 + Math.floor(SecureRandomUtil.getRandomNumber(1) * 200) + 50)))
        }
        MockPublicPrice.initList(lists, listData, index)
        MockTrainTicketPriceService.travelerResult = lists
      }
    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}

// 模拟火车票返程价格列表
@ObservedV2
export class MockTrainTicketReturnPriceService {
  @Trace public static travelerResult: TrainTicketPriceModel[] = []

  public static init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('trainReturnPrices.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      let lists: TrainTicketPriceModel[] = JSON.parse(resultPut) as TrainTicketPriceModel[]
      let datas: number = 90

      for (let index = 0; index < datas; index++) {
        let time = new Date().getTime()

        let listData: TrainTicketPriceListModel = {
          'id': `ticket_back_${index}_${time}`,
          'startDate': MockPublicPrice.generateRandomTimeWithDuration(5)[0],
          'endDate': MockPublicPrice.generateRandomTimeWithDuration(5)[0],
          'startLocation': '上海虹桥',
          'endLocation': '北京西',
          'duration': '5时30分',
          'trainNumber': 'G30',
          'firstClass': '有座',
          'secondClass': '有座',
          'businessClass': '抢',
          'noSeat': '4张',
          'price': String(Math.max(269,
            Math.round(199 + Math.floor(SecureRandomUtil.getRandomNumber(1) * 230) + 150)))
        }
        MockPublicPrice.initList(lists, listData, index)
        MockTrainTicketReturnPriceService.travelerResult = lists
      }

    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}

// 模拟旅游列表
@ObservedV2
export class MockTourListService {
  @Trace public static tourResult: TourModel[] = []

  public static async init() {
    // 取模拟数据
    getContext().resourceManager.getRawFileContent('tourMock.json').then((value: Uint8Array) => {
      const textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      const resultPut = textDecoder.decodeToString(value);
      const resultObj = JSON.parse(resultPut) as TourModel[]
      MockTourListService.tourResult = (resultObj || []).map((item: TourModel) => {
        const basePrice = Number.isFinite(item?.priceFrom as number) ? (item.priceFrom as number) : 999
        // 为每条数据生成从当天起的30天线路班期
        item.lineSchedule = CalendarUtil.getCalendarPrice(basePrice, 300, 30, true)
        return item;
      })

    }).catch((e: BusinessError) => {
      return Promise.reject(e);
    });
  }
}


