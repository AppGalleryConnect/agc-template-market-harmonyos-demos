import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { AppStorageMap, CurAppInfo } from '../common/Constant';
import { getMockResponse } from './HttpMockMap';

/*
:todo 是否使用mock数据
*/
const useMock: boolean = true;

const instance = axios.create({
  baseURL: CurAppInfo.BASE_URL,
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
  const resp: Object | undefined = getMockResponse(error.config);
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(resp ?? '');
    }, 300)
  })
};

// Add a response interceptor.
instance.interceptors.response.use((response: AxiosResponse) => {

  if (response.status === 200 && response.data?.error_code === 0) {
    return response.data?.data;
  }
  return Promise.reject(response.data);
}, useMock ? onRejectedMock : onRejectedNormal);

export default instance;