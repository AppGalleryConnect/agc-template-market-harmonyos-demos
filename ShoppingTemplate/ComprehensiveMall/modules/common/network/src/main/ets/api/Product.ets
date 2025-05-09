import { AxiosInstance, AxiosResponse } from '@ohos/axios';
import { ApiResponse, ProductInfo } from '@common/customtypes';

export class Product {

  private axios: AxiosInstance;

  public async getInfo(id: string): Promise<ProductInfo> {
    try {
      const res: AxiosResponse<ApiResponse<ProductInfo>> =
        await this.axios.post<ApiResponse<ProductInfo>>('/api/v1/product/info', {
          id: id
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  constructor(axiosInstance: AxiosInstance) {
    this.axios = axiosInstance;
  }
}
