import { AxiosInstance, AxiosResponse } from '@ohos/axios';
import { ApiResponse, Home } from '@common/customtypes';

export class Homepage {

  private axios: AxiosInstance;

  public async getHomeCoreData(): Promise<Home> {
    try {
      const res: AxiosResponse<ApiResponse<Home>> =
        await this.axios.get<ApiResponse<Home>>('/api/v1/homepage/home');
      if (res.data.code === -1) {
        throw new Error();
      } else {
        return res.data.data;
      }
    } catch (error) {
      return Promise.reject(error);
    }
  }

  constructor(axiosInstance: AxiosInstance) {
    this.axios = axiosInstance;
  }
}
