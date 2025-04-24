import { BaseResponse, https } from '@ohos_agcit/office_attendance_network';
import { DataManager } from '../mock/DataManager';
import { ScheduleInfo } from '../types/Types';

export class RequestProxy {
  static queryByName(name: string): Promise<ScheduleInfo[]> {
    return Promise.resolve(DataManager.queryByName(name));
  }

  static queryByID(id: string): Promise<ScheduleInfo | undefined> {
    return Promise.resolve(DataManager.queryById(id));
  }

  static queryByDate(date: string): Promise<ScheduleInfo[]> {
    return Promise.resolve(DataManager.queryByDate(date));
  }

  static queryScheduleDates(fromDate: string, toDate: string): Promise<Array<string>> {
    return Promise.resolve(DataManager.queryScheduleDates(fromDate, toDate));
  }

  static saveOne(item: ScheduleInfo): Promise<BaseResponse<undefined>> {
    DataManager.saveOne(item);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static editTask(item: ScheduleInfo): Promise<BaseResponse<undefined>> {
    DataManager.saveOne(item);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static delete(id: string): Promise<BaseResponse<undefined>> {
    DataManager.deleteById(id);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }
}