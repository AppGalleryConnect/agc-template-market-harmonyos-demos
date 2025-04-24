import { HttpRequestConfig } from '../axiosHttpRequest/AxiosModel';
import { RequestUrl } from '../constants/Common';
import { MockData } from './MockData';

export function getMockResponse<T>(config: HttpRequestConfig): T {
  let params: ESObject = config.params
  let url: string = config.url || '';
  switch (url) {
    case RequestUrl.GET_HM_SYSTEM_URL:
      return MockData.getHmSystemResp as T;
    case RequestUrl.GET_LOGIN_HM_URL:
      return MockData.getUserInfoResp as T;
    case RequestUrl.GET_OPEN_LOGIN_HM_URL:
      return MockData.getOpenLogin as T;
    case RequestUrl.GET_CLOSE_LOGIN_HM_URL:
      return MockData.getCloseLogin as T;
    case RequestUrl.GET_COUPONS_URL:
      return MockData.getCouponsResp as T;
    case RequestUrl.GET_STORE_INFO_URL:
      return MockData.getStoreInfoResp as T;
    case RequestUrl.GET_TABLE_TITLE_URL:
      return MockData.getTableTitleResp as T;
    case RequestUrl.GET_ZHUO_HAO_URL:
      return MockData.getTableInfoResp(params) as T;
    case RequestUrl.GET_DISHES_LIST_URL:
      return MockData.getDishesList as T;
    case RequestUrl.GET_DEL_CAR_URL:
      return MockData.cleanCar() as T;
    case RequestUrl.GET_ADD_DN_ORDER_URL:
      return MockData.addOrder(params) as T;
    case RequestUrl.GET_MY_ORDER_URL:
      return MockData.getMyOrder(params) as T;
    case RequestUrl.GET_CANCEL_ORDER_URL:
      return MockData.cancelOrder(params) as T;
    case RequestUrl.GET_ORDER_INFO_URL:
      return MockData.getOrderInfo(params) as T;
    case RequestUrl.GET_LQ_COUPONS_URL:
      return MockData.getLqCoupons(params) as T;
    case RequestUrl.GET_MY_CAR_URL:
      return MockData.getMyCar as T;
    case RequestUrl.GET_UPD_CAR_URL:
      return MockData.getUpdCar(params) as T;
    case RequestUrl.GET_GOOD_INFO_URL:
      return MockData.getGoodInfoResp(params) as T;
    case RequestUrl.GET_GOOD_SPEC_URL:
      return MockData.getGoodSpecInfo(params) as T;
    case RequestUrl.GET_ADD_CAR_URL:
      return MockData.addCar(params) as T;
    case RequestUrl.GET_MY_COUPONS_URL:
      return MockData.getMyCoupons as T;
    case RequestUrl.GET_HELP_URL:
      return MockData.getHelp() as T;
    case RequestUrl.GET_IS_NEW_URL:
      return MockData.getIsNew as T;
    case RequestUrl.GET_DELETE_ORDER_URL:
      return MockData.deleteOrder(params) as T;
    case RequestUrl.GET_ADD_GOODS_URL:
      return MockData.addGoods(params) as T;
    case RequestUrl.GET_HUAWEI_PAY_INFO_URL:
      return MockData.getHuaweiPayInfo(params) as T;
    default:
      return '' as T;
  }
}