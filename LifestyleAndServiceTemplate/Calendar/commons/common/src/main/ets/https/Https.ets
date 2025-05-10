import { HolidayDetail } from '../models/HolidayModel';
import { DailyInfo, HolidaysMonth, HolidaysYear, OldAlmanac } from './CalendarBeans';

import { MockData } from './DataMock';


class Https {
  //老黄历
  public static async getOldAlmanac(params: ESObject = { date: '2024-09-10' }): Promise<OldAlmanac | null> {
    // let resp: ESObject = await getData(APIs.old_almanac[0], APIs.old_almanac[1], params)
    // LogUtil.debug(`getOldAlmanac:${JSON.stringify(resp)}`)
    // if (resp.code == 1) {
    //   return resp.data as OldAlmanac;
    // }
    let data: OldAlmanac = JSON.parse(JSON.stringify(MockData.GET_OLD_ALMANAC));
    return Promise.resolve(data);
  }

  //获取当年假期
  public static async getHolidayYear(params: ESObject = { year: '2024' }): Promise<HolidaysYear | null> {
    // let resp: ESObject = await getData(APIs.holidays_year[0], APIs.holidays_year[1], params)
    // LogUtil.debug(`getHolidayYear:${JSON.stringify(resp)}`)
    // if (resp.code == 1) {
    //   return resp.data as HolidaysYear;
    // }
    return null;
  }

  //获取近期假期
  public static async getHolidayMonth(params: ESObject = { date: '2024-9' }): Promise<HolidaysMonth | null> {
    // let resp: ESObject = await getData(APIs.holidays_month[0], APIs.holidays_month[1], params)
    // LogUtil.debug(`request ${params.date}getHolidayMonth:${JSON.stringify(resp)}`)
    // if (resp.code == 1) {
    //   return resp.data as HolidaysMonth;
    // }
    return null;
  }

  //获取当日假期信息
  public static async getDailyInfo(params: ESObject = { date: '2024-1-1' }): Promise<HolidayDetail | null> {
    //   let resp: ESObject = await getData(APIs.daily_info[0], APIs.daily_info[1], params)
    //   LogUtil.debug(`getDailyInfo:${JSON.stringify(resp)}`)
    //   if (resp.code == 1) {
    //     return resp.data as HolidayDetail;
    //   }
    return null;
  }
}


export { Https };