import axios, { AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = '[Network]';

export const axiosInstance = axios.create({
  baseURL: '',
  timeout: 2 * 3000,
  headers: {},
});

axiosInstance.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response);
    } else {
      hilog.error(DOMAIN, TAG, `https request failed：${response.config.url}. error: ${JSON.stringify(response.status)}`);
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    hilog.error(DOMAIN, TAG, `https request failed. error: ${JSON.stringify(error)}`);
    return Promise.reject(error);
  },
);

