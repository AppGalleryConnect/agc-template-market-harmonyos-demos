import { BaseResponse } from '@ohos_agcit/office_attendance_network';
import { DataManager } from '../mock/DataManager';
import { CheckInDetailRecord, CheckInHistoryDataItem, CheckInHistoryDetailDataItem } from '../types/Types';

export class RequestProxy {
  static queryCheckInHistories(): Promise<CheckInHistoryDataItem[]> {
    return Promise.resolve(DataManager.queryCheckInHistories());
  }

  static getTodayCheckInDetail(): Promise<CheckInHistoryDetailDataItem[]> {
    return Promise.resolve(DataManager.getTodayCheckInDetail());
  }

  static addCheckInDetail(value: CheckInDetailRecord): Promise<BaseResponse<undefined>> {
    DataManager.addCheckInDetail(value);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static saveIsQuickCheckIn(value: boolean): Promise<BaseResponse<undefined>> {
    DataManager.saveIsQuickCheckIn(value);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static isQuickCheckIn(): Promise<boolean> {
    return Promise.resolve(DataManager.isQuickCheckIn());
  }
}