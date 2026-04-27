import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosResponse } from '@ohos/axios';

// 创建axios实例
const instance = axios.create({
  /**
   * todo: 填写实际的baseUrl
   */
  baseURL: '',
  timeout: 10 * 3000,
  headers: {},
});

instance.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    }
    return Promise.reject(response);
  },
  (error: BusinessError) => {
    return Promise.reject(error);
  },
);

export default instance;