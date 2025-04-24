import { promptAction } from '@kit.ArkUI';
import { Logger } from '@ohos_agcit/office_attendance_common_lib';
import { RequestUrl } from '../constants/NetworkEnums';
import { BaseResponse } from '../types/ResponseTypes';
import { httpsMock } from './HttpApisMock';

type MockMap = Record<string, (...args: ESObject[]) => Promise<BaseResponse>>;

// 创建 URL 到 Mock 方法的映射对象
const mockMap: MockMap = {
  /**
   * 用户信息
   */
  [RequestUrl.USER_BIND_PHONE]: httpsMock.bindPhone,
  [RequestUrl.USER_GET_INFO]: httpsMock.getUserInfo,
};

// 模拟一个延时的 mock 方法，延迟时间为 `delay` 毫秒
function simulateDelay<T>(data: T, delay: number): Promise<T> {
  return new Promise<T>((resolve) => {
    setTimeout(() => {
      resolve(data);
    }, delay);
  });
}

function mockErrorHandler(msg?: string): Promise<string> {
  const errMsg: string = 'replace mock data failed!';
  promptAction.showToast({ message: errMsg });
  Logger.error('[MockRequest]', msg ?? '', errMsg);
  return Promise.reject(errMsg);
}

export async function replaceMockData(url: string | undefined, ...args: ESObject[]): Promise<ESObject> {
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
