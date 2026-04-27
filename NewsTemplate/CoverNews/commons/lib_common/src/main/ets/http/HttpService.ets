import request from './BaseRequest';
import { INewsItem } from '../types/NewsItem';

export class HttpService {
  public queryNewsList(): Promise<INewsItem[]> {
    return request.get('/news/list');
  }

  public queryNewsDetail(newsId: string): Promise<INewsItem> {
    return request.get('/news/detail', { params: newsId });
  }

  public queryMyLikes(): Promise<INewsItem[]> {
    return request.get('/my/like/list');
  }

  public addLike(newsId: string): Promise<void> {
    return request.post('/my/like/add', newsId);
  }

  public cancelLike(newsId: string): Promise<void> {
    return request.post('/my/like/cancel', newsId);
  }

  public batchCancelLike(newsIds: string): Promise<void> {
    return request.post('/my/like/cancel/batch', newsIds);
  }
}

const instance = new HttpService();

export { instance as HttpServiceApi };