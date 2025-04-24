import { promptAction } from '@kit.ArkUI';
import { Logger } from 'commonlib';
import { RequestUrl } from '../constants/NetworkEnums';
import { BaseResponse } from '../types/ResponseTypes';
import { httpsMock } from './HttpApisMock';

type MockMap = Record<string, (...args: ESObject[]) => Promise<BaseResponse>>;

// 创建 URL 到 Mock 方法的映射对象
const mockMap: MockMap = {
  /**
   * 课程管理
   */
  [RequestUrl.SCHEDULE_CONFIG]: httpsMock.getScheduleConfig,
  [RequestUrl.QUERY_DAY_COURSE]: httpsMock.queryDayCourse,
  [RequestUrl.USER_BIND_PHONE]: httpsMock.bindPhone,
  [RequestUrl.USER_GET_INFO]: httpsMock.getUserInfo,
  [RequestUrl.USER_UPDATE_NICKNAME]: httpsMock.updateUserNickname,
  [RequestUrl.QUERY_ALL_COURSE]: httpsMock.queryAllCourse,
  [RequestUrl.CLASS_SIGN_IN]: httpsMock.signIn,
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
  return Promise.reject({ errMsg: errMsg });
}

export async function replaceMockData(url: string | undefined, ...args: ESObject[]): Promise<BaseResponse> {
  const arr = Object.entries(mockMap);
  if (url) {
    const func = arr.find((item) => url === item[0]);
    if (func) {
      const response: BaseResponse = await func[1](...args);
      const delayResponse: BaseResponse = await simulateDelay(response, 500);
      return Promise.resolve(delayResponse);
    }
    return mockErrorHandler('cannot find mock function.');
  }
  return mockErrorHandler('cannot find url.');
}
