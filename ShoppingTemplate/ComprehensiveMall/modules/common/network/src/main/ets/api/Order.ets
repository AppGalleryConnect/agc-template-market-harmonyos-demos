import { AxiosInstance, AxiosResponse } from '@ohos/axios';

import { ApiResponse, PreOrderInfoDto, PreOrderRequest, OrderCardDto } from '@common/customtypes';

export class Order {
  private axios: AxiosInstance;
  public getProOrderInfo = async (req: PreOrderRequest): Promise<PreOrderInfoDto> => {
    try {
      const res: AxiosResponse<ApiResponse<PreOrderInfoDto>> =
        await this.axios.post<ApiResponse<PreOrderInfoDto>>('/api/v1/order/preorder', {
          preOrderRequest: req,
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  };
  public getOrderList = async (type: number): Promise<OrderCardDto[]> => {
    try {
      const res: AxiosResponse<ApiResponse<OrderCardDto[]>> =
        await this.axios.post<ApiResponse<OrderCardDto[]>>('/api/v1/order/list', {
          type,
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  };
  public deleteOrderByCode = async (code: string): Promise<OrderCardDto[]> => {
    try {
      const res: AxiosResponse<ApiResponse<OrderCardDto[]>> =
        await this.axios.post<ApiResponse<OrderCardDto[]>>('/api/v1/order/delete', {
          code: code,
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  };
  public refundOrderByCode = async (code: string): Promise<OrderCardDto[]> => {
    try {
      const res: AxiosResponse<ApiResponse<OrderCardDto[]>> =
        await this.axios.post<ApiResponse<OrderCardDto[]>>('/api/v1/order/refund', {
          code: code,
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  };
  public agreeOrderByCode = async (code: string): Promise<OrderCardDto[]> => {
    try {
      const res: AxiosResponse<ApiResponse<OrderCardDto[]>> =
        await this.axios.post<ApiResponse<OrderCardDto[]>>('/api/v1/order/agree', {
          code: code,
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  };
  constructor(axiosInstance: AxiosInstance) {
    this.axios = axiosInstance;
  }
}
