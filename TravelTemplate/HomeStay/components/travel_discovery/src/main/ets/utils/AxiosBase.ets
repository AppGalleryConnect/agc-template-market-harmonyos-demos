import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BASE_URL } from '../constant/Index';
import { getMockResponse } from './Index';

// 是否使用mock数据
const useMock: boolean = true;

const instance = axios.create({
  baseURL: BASE_URL,
  timeout: 3000,
  headers: {}
});

// Add a request interceptor.
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  return config;
}, (error: AxiosError) => {
  return Promise.reject(error);
});

const onRejectedNormal = (error: AxiosError) => {
  return Promise.reject(error.response?.data);
};

const onRejectedMock = (error: AxiosError): Promise<ESObject> => {
  const resp: ESObject = getMockResponse(error.config);
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(resp);
    }, 100)
  })
};

// Add a response interceptor.
instance.interceptors.response.use((response: AxiosResponse) => {
  if (response.status === 200 && response.data?.code === 0) {
    return response.data;
  }
  return Promise.reject(response.data);
}, useMock ? onRejectedMock : onRejectedNormal);

export default instance;