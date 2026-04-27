import axios, { AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';

const instance = axios.create({
  baseURL: '',
  timeout: 10 * 3000,
  headers: {},
});

instance.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    } else {
      console.error('[Network]' + `https request failed：${response.config.url}. error:` +
      JSON.stringify(response.status),
      );
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    console.error(
      '[Network]' + `https request failed：. error:` + JSON.stringify(error),
    );
    return Promise.reject(error);
  },
);

export default instance;