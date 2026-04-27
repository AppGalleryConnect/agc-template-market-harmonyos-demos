import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { MockData } from './MockData';

export class HttpServiceMock {
  start(adapter: AxiosMockAdapter) {
    // 查询新闻列表
    adapter.onGet('/news/list').reply(() => {
      const list = MockData.newsList;
      return [HttpStatusCode.Ok, list];
    });

    // 查询新闻详情
    adapter.onGet('/news/detail').reply((config: AxiosRequestConfig) => {
      const news = MockData.newsList.find(v => v.id === config.params as string);
      return [HttpStatusCode.Ok, news];
    });

    // 查询我的点赞
    adapter.onGet('/my/like/list').reply(() => {
      const list = MockData.newsList.filter(v => MockData.myLikes.includes(v.id));
      return [HttpStatusCode.Ok, list];
    });

    // 点赞
    adapter.onPost('/my/like/add').reply((config: AxiosRequestConfig) => {
      const data = config.data as string;
      MockData.myLikes.push(data);
      const news = MockData.newsList.find(v => v.id === data);
      if (news) {
        news.isLiked = true;
      }
      return [HttpStatusCode.Ok];
    });

    // 取消点赞
    adapter.onPost('/my/like/cancel').reply((config: AxiosRequestConfig) => {
      const data = config.data as string;
      MockData.myLikes = MockData.myLikes.filter(v => v !== data);
      const news = MockData.newsList.find(v => v.id === data);
      if (news) {
        news.isLiked = false;
      }
      return [HttpStatusCode.Ok];
    });

    // 批量取消点赞
    adapter.onPost('/my/like/cancel/batch').reply((config: AxiosRequestConfig) => {
      const data = config.data as string;
      MockData.myLikes = MockData.myLikes.filter(v => !data.includes(v));
      MockData.newsList.forEach(v => {
        if (data.includes(v.id)) {
          v.isLiked = false;
        }
      })
      return [HttpStatusCode.Ok];
    });
  }
}