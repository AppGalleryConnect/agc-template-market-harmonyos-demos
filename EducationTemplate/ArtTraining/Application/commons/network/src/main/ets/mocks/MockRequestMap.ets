import { promptAction } from '@kit.ArkUI';
import { Logger } from 'commonlib';
import { RequestUrl } from '../constants/NetworkEnums';
import { BaseResponse } from '../types/ResponseTypes';
import { httpsMock } from './HttpApisMock';

type MockMap = Record<string, (...args: ESObject[]) => Promise<BaseResponse>>;

// 创建 URL 到 Mock 方法的映射对象
const mockMap: MockMap = {
  /**
   * 用户信息
   */
  [RequestUrl.BIND_PHONE]: httpsMock.bindPhone,
  [RequestUrl.USER_GET_INFO]: httpsMock.getUserInfo,
  [RequestUrl.GET_STORE_CONFIG]:httpsMock.getStoreConfig,
  [RequestUrl.GET_COURSE_DETAIL]:httpsMock.getCourseDetail,
  [RequestUrl.GET_COURSE_LIST]:httpsMock.getCourseList,
  [RequestUrl.CREATE_COURSE_ORDER]:httpsMock.createCourseOrder,
  [RequestUrl.CANCEL_COURSE_ORDER]:httpsMock.cancelCourseOrder,
  [RequestUrl.GET_ORDER_LIST]:httpsMock.getOrderList,
  [RequestUrl.GET_ORDER_DETAIL]:httpsMock.getOrderDetail,
  [RequestUrl.GET_COURSE_LIST_ORDERED]:httpsMock.getCourseListOrdered,
  [RequestUrl.GET_CHECKIN_ACTIVITY_DETAIL]:httpsMock.getCheckInActivityDetail,
  [RequestUrl.GET_CHECKIN_ACTIVITY_LIST]:httpsMock.getCheckInActivityList,
  [RequestUrl.CREATE_CHECKIN_ACTIVITY_ORDER]:httpsMock.createCheckInActivityOrder,
  [RequestUrl.CANCEL_CHECKIN_ACTIVITY_ORDER]:httpsMock.cancelCheckInActivityOrder,
  [RequestUrl.GET_CHECKIN_ACTIVITY_LIST_ORDERED]:httpsMock.getCheckInActivityListOrdered,
  [RequestUrl.COMMIT_USER_CHECKIN]:httpsMock.commitUserCheckIn,
  [RequestUrl.GET_USER_CHECKIN_RECORD_LIST]:httpsMock.getUserCheckInRecordList,
};

// 模拟一个延时的 mock 方法，延迟时间为 `delay` 毫秒
function simulateDelay<T>(data: T, delay: number): Promise<T> {
  return new Promise<T>((resolve) => {
    setTimeout(() => {
      resolve(data);
    }, delay);
  });
}

function mockErrorHandler(msg?: string): Promise<BaseResponse> {
  const errMsg: string = 'replace mock data failed!';
  promptAction.showToast({ message: errMsg });
  Logger.error('[MockRequest]', msg ?? '', errMsg);
  const res: BaseResponse = {
    ret:{
      code: -1,
      msg: errMsg,
    },
  };
  return Promise.reject(res);
}

export async function replaceMockData(url: string | undefined, ...args: ESObject[]): Promise<ESObject> {
  const arr = Object.entries(mockMap);
  if (url) {
    const func = arr.find((item) => url === item[0]);
    if (func) {
      const response: BaseResponse = await func[1](...args);
      const delayResponse: BaseResponse = await simulateDelay(response, 0);
      return Promise.resolve(delayResponse);
    }
    return mockErrorHandler('cannot find mock function.');
  }
  return mockErrorHandler('cannot find url.');
}
