/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { AppStorageMap, CurAppInfo } from '../common/Constant';
import { getMockResponse } from './HttpMockMap';

/**
 * 是否使用mock数据
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