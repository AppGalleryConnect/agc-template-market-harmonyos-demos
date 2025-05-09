import { AxiosInstance, AxiosResponse } from '@ohos/axios';
import { ApiResponse, GuessLike, CardDataDto, Category } from '@common/customtypes';

export class CardList {

  private axios: AxiosInstance;

  public async getGuessLike(index: number): Promise<GuessLike> {
    try {
      const res: AxiosResponse<ApiResponse<GuessLike>> =
        await this.axios.post<ApiResponse<GuessLike>>('/api/v1/cardlist/guesslike', {
          index: index
      });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async getCardsByCategoryId(categoryId: string, index: number): Promise<CardDataDto> {
    try {
      const res: AxiosResponse<ApiResponse<CardDataDto>> =
        await this.axios.post<ApiResponse<CardDataDto>>('/api/v1/cardlist/category/cards', {
          categoryId: categoryId,
          index: index
        });
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async getCategoryList(): Promise<Category[]> {
    try {
      const res: AxiosResponse<ApiResponse<Category[]>> =
        await this.axios.get<ApiResponse<Category[]>>('/api/v1/cardlist/category/list');
      return res.data.data;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  constructor(axiosInstance: AxiosInstance) {
    this.axios = axiosInstance;
  }
}
