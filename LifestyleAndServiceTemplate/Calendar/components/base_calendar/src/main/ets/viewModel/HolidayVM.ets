import dayjs from 'dayjs'
import { UtilLog } from '@hw-agconnect/util-log';
import { HolidayDetail, HolidayItem, HolidayMonthDetail } from '../models/HolidayModel'
import { Https } from '../https/Https'

const TAG = '[HolidayVM]'

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
    await Https.getHolidayYear({ 'year': this.curMonth.year() }).then((resp) => {
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
    await Https.getHolidayMonth({ 'date': this.curMonth.format('YYYY-M') }).then((resp) => {
      if (resp) {
        let data = resp.holidayArray as HolidayMonthDetail[]
        data.forEach((item: HolidayMonthDetail) => {
          this.holidayMonthDetail.push(new HolidayMonthDetail(item))
        })
        UtilLog.info(TAG, this.curMonth.format('YYYY-M') + 'data' + JSON.stringify(data))
      }
    })
  }

  public async getHolidayDetail(startDay: string) {
    await Https.getDailyInfo({ 'date': startDay }).then((resp) => {
      if (resp) {
        this.holidayDetail = resp
      }
    })
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