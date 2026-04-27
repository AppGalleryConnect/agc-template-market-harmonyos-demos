import axios, { AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';

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
    } else {
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    return Promise.reject(error);
  },
);

export default instance;