import { InternalAxiosRequestConfig } from '@ohos/axios';
import { URL_MAP } from '../common/Constant';
import { MockApi } from './MockApi';

/**
 * 映射相应mock接口
 * @param config
 * @returns
 */
export const getMockResponse = (config?: InternalAxiosRequestConfig): Object | undefined => {
  const url = config?.url || '';
  switch (url) {
    case URL_MAP.GET_USER_INFO:
      return MockApi.getUserInfo();
    case URL_MAP.UPDATE_USER_INFO:
      return MockApi.updateUserInfo(config);
    case URL_MAP.CHECK_IN:
      return MockApi.getCheckInList();
    case URL_MAP.VIP_PREPAY:
      return MockApi.vipPrepay(config);
    case URL_MAP.ORDER_LIST:
      return MockApi.getOrderList(config);
    case URL_MAP.ORDER_INFO:
      return MockApi.getOrderInfo(config);
    case URL_MAP.ORDER_COUNT:
      return MockApi.getOrderCount();
    case URL_MAP.DELETE_ORDER:
      return MockApi.deleteOrder(config);
    case URL_MAP.COMPANY_LIST:
      return MockApi.getCompanyList();
    case URL_MAP.COUPON_LIST:
      return MockApi.getCouponList(config);
    case URL_MAP.GOODS_LIST:
      return MockApi.getGoodsList();
    case URL_MAP.ESTIMATED_PRICE:
      return MockApi.getEstimatedPrice();
    case URL_MAP.SERVICE_POINT_LIST:
      return MockApi.getServicePointList();
    case URL_MAP.PREPAY:
      return MockApi.prepay(config);
    case URL_MAP.ADD_REMAKE:
      return MockApi.addRemakeToOrder(config);
    case URL_MAP.UPDATE_ORDER:
      return MockApi.updateOrder(config);
    default:
      return '';
  }
}