import dayjs from 'dayjs'
import { HolidayDetail, HolidayItem, HolidayMonthDetail } from '../models/HolidayModel'
import { Https } from '../https/Https'

@ObservedV2
export class HolidayVM {
  @Trace holidayList: HolidayItem[] = []
  @Trace holidayDetail: HolidayDetail | null = null
  @Trace holidayMonthDetail: HolidayMonthDetail[] = []
  @Trace curMonth: dayjs.Dayjs = dayjs()
  private static _instance: HolidayVM

  public static get instance() {
    if (!HolidayVM._instance) {
      HolidayVM._instance = new HolidayVM()
    }
    return HolidayVM._instance
  }

  public async getHolidayList() {
    await Https.getHolidayYear({ year: this.curMonth.year() }).then((resp) => {
      if (resp) {
        let list = resp.holidayList as HolidayItem[]
        list.forEach((item: HolidayItem) => {
          this.holidayList.push(new HolidayItem(item.startday, item.name))
        })
      }
    })
  }

  public async getHolidayMonthDetail() {
    this.holidayMonthDetail = []
    console.log('attach::::::::::::::::::::::::::::')
    await Https.getHolidayMonth({ date: this.curMonth.format('YYYY-M') }).then((resp) => {
      if (resp) {
        let data = resp.holidayArray as HolidayMonthDetail[]
        data.forEach((item: HolidayMonthDetail) => {
          this.holidayMonthDetail.push(new HolidayMonthDetail(item))
        })
        console.log(this.curMonth.format('YYYY-M') + 'data' + JSON.stringify(data))
      }
    })
  }

  public async getHolidayDetail(startday: string) {
    await Https.getDailyInfo({ date: startday }).then((resp) => {
      if (resp) {
        this.holidayDetail = resp
      }
    })
  }

  public updateHolidayInfo(date: dayjs.Dayjs) {
    if (this.curMonth.format('YYYYMM') !== date.format('YYYYMM')) {
      this.curMonth = date;
      console.log('getHolidayMonthDetail')
      this.getHolidayMonthDetail()
    }
  }

  public isHoliday(dateStr: string) {
    let flag = false;
    this.holidayMonthDetail.forEach((item) => {
      if (!flag) {
        flag = Boolean(item.list.filter((it) => {
          return it.date === dateStr && it.status === '1'
        }).length)
      }
    })
    return flag
  }

  public isWorkday(dateStr: string) {
    let flag = false;
    this.holidayMonthDetail.forEach((item) => {
      if (!flag) {
        flag = Boolean(item.list.filter((it) => {
          return it.date === dateStr && it.status === '2'
        }).length)
      }
    })
    return flag

  }
}

export default HolidayVM