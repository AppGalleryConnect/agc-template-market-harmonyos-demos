import { AxiosInstance, AxiosResponse } from '@ohos/axios';
import { ApiResponse } from '@common/customtypes';

export class Search {

  private axios: AxiosInstance;

  public async getSuggestions(): Promise<string[]> {
    try {
      const res: AxiosResponse<ApiResponse<Record<'suggestions', string[]>>> =
        await this.axios.get<ApiResponse<Record<'suggestions', string[]>>>('/api/v1/search/suggestions');
      return res.data.data.suggestions;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async getCandidateWords(key: string): Promise<string[]> {
    try {
      const res: AxiosResponse<ApiResponse<Record<'candidateWords', string[]>>> =
        await this.axios.post<ApiResponse<Record<'candidateWords', string[]>>>('/api/v1/search/candidate', {
          key: key
      });
      return res.data.data.candidateWords;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  constructor(axiosInstance: AxiosInstance) {
    this.axios = axiosInstance;
  }
}
