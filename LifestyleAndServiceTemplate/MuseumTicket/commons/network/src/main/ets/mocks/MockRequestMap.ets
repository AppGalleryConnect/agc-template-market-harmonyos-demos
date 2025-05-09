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
  [RequestUrl.USER_BIND_PHONE]: httpsMock.bindPhone,
  [RequestUrl.USER_GET_INFO]: httpsMock.getUserInfo,
  [RequestUrl.HOME_RECOMMEND_LIST]:httpsMock.getRecommendList,
  [RequestUrl.ORDER_LIST_INFO]:httpsMock.getOrderList,
  [RequestUrl.ORDER_TICKET_DETAIL]:httpsMock.getOrderDetail,
  [RequestUrl.PERFORMANCE_INFO]:httpsMock.getPerformanceInfo,
  [RequestUrl.ORDER_DAY_TICKET]:httpsMock.getDayTicket,
  [RequestUrl.EXPLAIN_TEXT]:httpsMock.getExplainText,
  [RequestUrl.INTRODUCE_TEXT]:httpsMock.getIntroduceText,
  [RequestUrl.PARKING_TEXT]:httpsMock.getParkingText,
  [RequestUrl.PRIVACY_TEXT]:httpsMock.getPrivacyText,
  [RequestUrl.CONTACTS_INFO]:httpsMock.getContacts,
  [RequestUrl.UPDATE_CONTACT]:httpsMock.upDateContacts,
  [RequestUrl.CANCEL_ORDER]:httpsMock.cancelOrder,
  [RequestUrl.ORDER_FREE]:httpsMock.orderFree,
  [RequestUrl.BUY_TIME_TICKET]:httpsMock.getTimeTicket,
  [RequestUrl.TICKET_TYPE_INFO]:httpsMock.getTicketType,
  [RequestUrl.BUY_TICKET]:httpsMock.prePayBuyTicket,
  [RequestUrl.USER_GET_INFO]:httpsMock.getUserInfo,
  [RequestUrl.USER_LOGIN]:httpsMock.userLogin,
  [RequestUrl.UPDATE_USERINFO]:httpsMock.updateUserInfo,
  [RequestUrl.BANNER_IMG]:httpsMock.getBannerImg,
  [RequestUrl.DEL_VISITOR]:httpsMock.delContacts,
  [RequestUrl.USER_CANCEL_PHONE]:httpsMock.cancelPhone,
  [RequestUrl.TRAFFIC_DETAIL]:httpsMock.getTrafficDetail
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
