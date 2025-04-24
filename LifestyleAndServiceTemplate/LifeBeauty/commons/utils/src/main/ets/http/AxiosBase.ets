import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { AppStorageMap, BASE_URL, URL_MAP } from '../common/Constant';
import { MockApi } from './MockApi';

/**
 * 是否使用mock数据
 */
const useMock: boolean = true;

const instance = axios.create({
  baseURL: BASE_URL,
  timeout: 3000,
});

// Add a request interceptor.
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  if (!config.url?.includes('loginWithHuaweiID')) {
    config.headers.set('Token', AppStorage.get(AppStorageMap.TOKEN));
  }
  return config;
}, (error: AxiosError) => {
  return Promise.reject(error);
});


const onRejectedNormal = (error: AxiosError) => {
  return Promise.reject(error.response?.data);
};

const onRejectedMock = (error: AxiosError): Promise<Object> => {
  const resp: Object = getMockResponse(error.config);
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(resp);
    }, 100)
  })
};

// Add a response interceptor.
instance.interceptors.response.use((response: AxiosResponse) => {
  if (response.status === 200 && response.data?.errorCode === 0) {
    return response.data?.data;
  }
  return Promise.reject(response.data);
}, useMock ? onRejectedMock : onRejectedNormal);


/**
 * 映射相应mock接口
 * @param config
 * @returns
 */
export const getMockResponse = (config?: InternalAxiosRequestConfig): Object => {
  const url = config?.url || '';
  switch (url) {
    case URL_MAP.LOGIN_WITH_HUAWEI_ID:
      return MockApi.loginWithHuaweiID();
    case URL_MAP.REFRESH_TOKEN:
      return MockApi.refreshToken();
    case URL_MAP.BIND_MOBILE_WITH_CODE:
      return MockApi.bindMobileWithCode();
    case URL_MAP.CONFIRM_REBIND_MOBILE:
      return MockApi.confirmRebindMobileWithSecret();
    case URL_MAP.GET_USER_INFO:
      return MockApi.getUserInfo();
    case URL_MAP.UNBIND_MOBILE:
      return MockApi.unbindMobile();
    case URL_MAP.GET_STORE_INFO:
      return MockApi.getStoreInfo();
    case URL_MAP.GET_STORE_LIST:
      return MockApi.getStoreList();
    case URL_MAP.GET_GOOD_LIST:
      return MockApi.getGoodList();
    case URL_MAP.GET_APPOINTMENT_LIST:
      return MockApi.getAppointmentList(config);
    case URL_MAP.CREATE_APPOINTMENT_INFO:
      return MockApi.createAppointmentInfo(config);
    case URL_MAP.UPDATE_APPOINTMENT_INFO:
      return MockApi.updateAppointmentInfo(config);
    case URL_MAP.CANCEL_APPOINTMENT:
      return MockApi.cancelAppointment(config);
    case URL_MAP.ACTIVE_MEMBER_CARD:
      return MockApi.activeMemberCard();
    case URL_MAP.GET_SINGLE_VISIT_CARD_LIST:
      return MockApi.getSingleVisitCardList();
    case URL_MAP.GET_GROUP_LIST:
      return MockApi.getGroupList();
    case URL_MAP.PRE_ORDER:
      return MockApi.preOrder(config);
    case URL_MAP.GET_MY_SINGLE_VISIT_CARD_LIST:
      return MockApi.getMySingleVisitCardList();
    case URL_MAP.GET_MY_GROUP_LIST:
      return MockApi.getMyGroupList();
    case URL_MAP.REFUND_GROUP:
      return MockApi.refund(config);
    default:
      return '';
  }
}


export default instance;