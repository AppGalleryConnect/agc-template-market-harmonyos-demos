import request from '../common/BaseRequest';
import { NewsResponse } from '../params/response/NewsResponse';
import { AbstractRequestListData, RequestListData } from '../params/response/LayoutResponse';

/**
 * 新闻基础类
 */
export class BaseNewsService {
  /**
   * 查询新闻
   * @param newsId
   * @returns
   */
  public queryNews(newsId: string): Promise<NewsResponse | undefined> {
    return request.get('/news', { params: { newsId } });
  }

  /**
   * 查询作者的所有创作内容
   * @param userId
   * @returns
   */
  public queryAllNews(userId: string): Promise<NewsResponse[]> {
    return request.get('/author/news/list', { params: { authorId: userId } });
  }

  /**
   * 查询所有文章、动态、详情
   * @returns
   */
  public queryAllNewsList(): Promise<NewsResponse[]> {
    return request.get('/all/news/list');
  }

  /**
   * 查询搜索结果列表
   * @param search
   * @returns
   */
  public querySearchResultList(search: string): Promise<AbstractRequestListData> {
    return request.get('/news/search/list', { params: { search } });
  }

  /**
   * 查询用户发布的文章
   * @param userId
   * @returns
   */
  public queryAuthorArticles(userId: string): Promise<RequestListData[]> {
    return request.get('/author/article/list', { params: { authorId: userId } });

  }

  /**
   * 查询用户发布的视频
   * @param userId
   */
  public queryAuthorVideos(userId: string): Promise<RequestListData[]> {
    return request.get('/author/video/list', { params: { authorId: userId } });

  }

  /**
   * 查询用户发布的动态
   * @param userId
   */
  public queryAuthorPosts(userId: string): Promise<RequestListData[]> {
    return request.get('/author/post/list', { params: { authorId: userId } });
  }
}

const instance = new BaseNewsService();

export { instance as BaseNewsServiceApi };