import { httpsMock } from './HttpRequestApiMock';
import { promptAction } from '@kit.ArkUI';
import { Logger } from 'commonlib';
import { BaseResponse } from '../types/BaseResponse';
import { RequestUrlMap } from '../apis/RequestUrlMap';

type MockMap = Record<string, (...args: ESObject[]) => Promise<BaseResponse>>;

// 创建 URL 到 Mock 方法的映射对象
const mockMap: MockMap = {
  /**
   * 配置信息
   */
  [RequestUrlMap.COMMON_TENANT_INFO]: httpsMock.getTenantInfo,
  [RequestUrlMap.COMMON_TENANT_CONFIG]: httpsMock.getTenantConfig,
  [RequestUrlMap.COMMON_TRAFFIC_DETAIL]: httpsMock.getTrafficDetail,
  [RequestUrlMap.COMMON_GRADE_LIST]: httpsMock.getGradeList,
  [RequestUrlMap.COMMON_PAGE_BANNER]: httpsMock.getServiceBanner,
  /**
   * 用户信息
   */
  [RequestUrlMap.USER_LOGIN]: httpsMock.hotelUserLogin,
  [RequestUrlMap.USER_SEARCH]: httpsMock.getHotelUserInfo,
  [RequestUrlMap.USER_UPDATE]: httpsMock.updateHotelUserInfo,
  /**
   * 公告
   */
  [RequestUrlMap.NOTICE_LIST]: httpsMock.getNoticeList,
  [RequestUrlMap.NOTICE_DETAIL]: httpsMock.getNoticeDetail,
  /**
   * 评论
   */
  [RequestUrlMap.COMMON_SHOP_LIST]: httpsMock.getShopListForComment,
  [RequestUrlMap.COMMENT_LIST]: httpsMock.getCommentList,
  [RequestUrlMap.COMMENT_CREATE]: httpsMock.submitComment,
  /**
   * 订单
   */
  [RequestUrlMap.ORDER_LIST]: httpsMock.getOrderList,
  [RequestUrlMap.ORDER_DETAIL_HOTEL]: httpsMock.getHotelOrderDetail,
  [RequestUrlMap.ORDER_DETAIL_MEAL]: httpsMock.getMealOrderDetail,
  /**
   * 酒店预订
   */
  [RequestUrlMap.HOTEL_LIST]: httpsMock.getHotelList,
  [RequestUrlMap.HOTEL_ROOM_LIST]: httpsMock.getRoomList,
  [RequestUrlMap.HOTEL_ROOM_DETAIL]: httpsMock.getRoomDetail,
  /**
   * 餐厅预定
   */
  [RequestUrlMap.RESTAURANT_LIST]: httpsMock.getRestaurantList,
  [RequestUrlMap.RESTAURANT_DETAIL]: httpsMock.getRestaurantDetail,
  [RequestUrlMap.RESTAURANT_MEAL_DETAIL]: httpsMock.getMealDetail,
  /**
   * 宴会厅预定
   */
  [RequestUrlMap.BANQUET_HOTEL_LIST]: httpsMock.getBanquetHotelList,
  [RequestUrlMap.BANQUET_LIST]: httpsMock.getBanquetRoomList,
  [RequestUrlMap.BANQUET_DETAIL]: httpsMock.getBanquetRoomDetail,
  /**
   * 支付
   */
  [RequestUrlMap.PREPAY_HOTEL]: httpsMock.prepayHotel,
  [RequestUrlMap.PREPAY_MEAL]: httpsMock.prepayMeal,
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
    code: -1,
    msg: errMsg,
    data: undefined,
  };
  return Promise.reject(res);
}

export async function replaceMockData(url: string | undefined, ...args: ESObject[]): Promise<BaseResponse> {
  const arr = Object.entries(mockMap);
  if (url) {
    const func = arr.find((item) => url.startsWith(item[0]));
    if (func) {
      const response: BaseResponse = await func[1](...args);
      const delayResponse: BaseResponse = await simulateDelay(response, 200);

      return Promise.resolve(delayResponse);
    }
    return mockErrorHandler('cannot find mock function.');
  }
  return mockErrorHandler('cannot find url.');
}
