import { BaseResponse } from '@ohos_agcit/office_attendance_network';
import { DataManager } from '../mock/DataManager';

export class RequestProxy {
  static login(): Promise<BaseResponse<undefined>> {
    DataManager.login();
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static logout(): Promise<BaseResponse<undefined>> {
    DataManager.logout();
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static isLoggedIn(): Promise<BaseResponse<boolean>> {
    const isLoggedIn: boolean = DataManager.isLoggedIn();
    let resp: BaseResponse = { code: 200, data: isLoggedIn };
    return Promise.resolve(resp);
  }
}