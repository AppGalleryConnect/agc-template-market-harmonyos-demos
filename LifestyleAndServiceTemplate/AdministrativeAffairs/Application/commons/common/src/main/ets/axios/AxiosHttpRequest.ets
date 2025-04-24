import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';

const service = axios.create();

service.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    config.headers.Accept = 'application/json'
    config.headers['Content-Type'] = 'application/json'
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  },
);

service.interceptors.response.use(
  (response: AxiosResponse) => {
    return response;
  },
  async (error: AxiosError) => {
    return Promise.reject(error);
  },
);

export default service;

