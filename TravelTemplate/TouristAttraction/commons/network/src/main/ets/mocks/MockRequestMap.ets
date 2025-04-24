import { promptAction } from '@kit.ArkUI';
import { Logger } from 'common';
import { RequestUrl } from '../constants/NetworkEnums';
import { BaseResponse } from '../types/ResponseTypes';
import { httpsMock } from './HttpApisMock';

type MockMap = Record<string, (...args: ESObject[]) => Promise<BaseResponse>>;

// 创建 URL 到 Mock 方法的映射对象
const mockMap: MockMap = {
  [RequestUrl.HOME_GET_INFO]: httpsMock.getHomeRollupInfo,
  [RequestUrl.BULLETIN_GET_LIST]: httpsMock.getBulletinList,
  [RequestUrl.ATTRACTION_GET_LIST]: httpsMock.getAttractionList,
  [RequestUrl.TICKET_GET_LIST]: httpsMock.getTicketList,
  [RequestUrl.NOTE_GET_LIST]: httpsMock.getNoteList,
  [RequestUrl.ROUTE_GET_LIST]: httpsMock.getRouteList,
  [RequestUrl.COMMODITY_GET_LIST]: httpsMock.getCommodityList,
  [RequestUrl.BULLETIN_GET_DETAIL]: httpsMock.getBulletinDetail,
  [RequestUrl.ATTRACTION_GET_DETAIL]: httpsMock.getAttractionDetail,
  [RequestUrl.TICKET_GET_DETAIL]: httpsMock.getTicketDetail,
  [RequestUrl.NOTE_GET_DETAIL]: httpsMock.getNoteDetail,
  [RequestUrl.ROUTE_GET_DETAIL]: httpsMock.getRouteDetail,
  [RequestUrl.COMMODITY_GET_DETAIL]: httpsMock.getCommodityDetail,
  [RequestUrl.TOURIST_GET_LIST]: httpsMock.getTouristList,
  [RequestUrl.COMMODITY_ORDER_CREATE]: httpsMock.createCommodityOrder,
  [RequestUrl.TICKET_ORDER_CREATE]: httpsMock.createTicketOrder,
  [RequestUrl.ORDER_LIST]: httpsMock.getOrderList,
  [RequestUrl.ORDER_DETAIL]: httpsMock.getOrderDetail,
  [RequestUrl.ORDER_MODIFY]: httpsMock.modifyOrderDetail,
  [RequestUrl.CATERING_DETAIL]: httpsMock.getCateringDetail,
  [RequestUrl.ACCOMMODATION_DETAIL]: httpsMock.getAccommodationDetail,
  [RequestUrl.TOURIST_CREATE]: httpsMock.createTourist,
  [RequestUrl.TOURIST_MODIFY]: httpsMock.modifyTourist,
  [RequestUrl.TOURIST_DELETE]: httpsMock.deleteTourist,
  [RequestUrl.ADDRESS_CREATE]: httpsMock.createAddress,
  [RequestUrl.ADDRESS_MODIFY]: httpsMock.modifyAddress,
  [RequestUrl.ADDRESS_GET_LIST]: httpsMock.getAddressList,
  [RequestUrl.ADDRESS_DELETE]: httpsMock.deleteAddress,
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
