import { httpsMock } from './HttpRequestApiMock';
import { promptAction } from '@kit.ArkUI';
import { FullLoading, Logger } from 'commonlib';
import { BaseSuccessResponse } from '../types/BaseSuccessResponse';

type MockMap = Record<string, (...args: ESObject[]) => Promise<BaseSuccessResponse>>;

// 创建 URL 到 Mock 方法的映射对象
const mockMap: MockMap = {
  '/v1/coupons/coupons-list': httpsMock.getCoupons,
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
  FullLoading.hideLoading();
  promptAction.showToast({ message: errMsg });
  Logger.error('[MockRequest]', msg ?? '', errMsg);
  return Promise.reject(errMsg);
}

export async function replaceMockData(url: string | undefined, args: ESObject): Promise<ESObject> {
  const arr = Object.entries(mockMap);
  if (url) {
    // url严格一致
    const func = arr.find((item) => url === item[0]);
    if (func) {
      const response: BaseSuccessResponse = await func[1](args);
      const delayResponse: BaseSuccessResponse = await simulateDelay(response, 200);
      FullLoading.hideLoading();
      return Promise.resolve(delayResponse);
    }
    return mockErrorHandler('cannot find mock function.');
  }
  return mockErrorHandler('cannot find url.');
}
