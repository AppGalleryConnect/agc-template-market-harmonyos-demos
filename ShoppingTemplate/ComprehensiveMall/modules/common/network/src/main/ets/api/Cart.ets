import { AxiosInstance, AxiosResponse } from '@ohos/axios';

import { ApiResponse, CartDto } from '@common/customtypes';

export class Cart {

  private axios: AxiosInstance;

  public getSimpleCartData = async (): Promise<CartDto> => {
    try {
      const res: AxiosResponse<ApiResponse<CartDto>> =
        await this.axios.post<ApiResponse<CartDto>>('/api/v1/cart', {
          isSimple: true
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public getCartData = async (): Promise<CartDto> => {
    try {
      const res: AxiosResponse<ApiResponse<CartDto>> =
        await this.axios.post<ApiResponse<CartDto>>('/api/v1/cart', {
          isSimple: false
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public addSkuToCart = async (skuCode: string, count: number): Promise<CartDto> => {
    try {
      const res: AxiosResponse<ApiResponse<CartDto>> =
        await this.axios.post<ApiResponse<CartDto>>('/api/v1/cart/add', {
          skuCode: skuCode,
          count: count
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public deleteSkuFromCart = async (skuCodes: string[]): Promise<CartDto> => {
    try {
      const res: AxiosResponse<ApiResponse<CartDto>> =
        await this.axios.post<ApiResponse<CartDto>>('/api/v1/cart/delete', {
          skuCodes: skuCodes
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public changeSkuCount = async (skuCode: string, count: number): Promise<CartDto> => {
    try {
      const res: AxiosResponse<ApiResponse<CartDto>> =
        await this.axios.post<ApiResponse<CartDto>>('/api/v1/cart/count', {
          skuCode: skuCode,
          count: count
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
