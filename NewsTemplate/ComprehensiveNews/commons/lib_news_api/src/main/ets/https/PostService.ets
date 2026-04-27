import request from '../common/BaseRequest';
import { TopicResponse } from '../params/response/TopicResponse';
import { PostQueryRequest, PostRequest } from '../params/request/CommonRequest';
import { NewsResponse } from '../params/response/NewsResponse';
import { BaseNewsService } from './BaseNewsService';

/**
 * 新闻-动态类
 */
export class PostService extends BaseNewsService {
  /**
   * 查询推荐
   * @param params
   * @returns
   */
  public queryPostRecommendList(params: PostQueryRequest): Promise<NewsResponse[]> {
    return request.get('/post/recommend/list', { params });
  }

  /**
   * 查询关注
   * @param params
   * @returns
   */
  public queryPostFollowList(params: PostQueryRequest): Promise<NewsResponse[]> {
    return request.get('/post/follow/list', { params });
  }

  /**
   * 查询话题相关
   * @param params
   * @returns
   */
  public queryPostTopicList(params: PostQueryRequest): Promise<NewsResponse[]> {
    return request.get('/post/topic/list', { params });
  }

  /**
   * 查询话题列表
   * @returns
   */
  public queryTopicList(): Promise<TopicResponse[]> {
    return request.get('/topic/list');
  }

  /**
   * 发布动态
   * @param post
   */
  public publishPost(post: PostRequest): Promise<void> {
    return request.post('/publish/post', post);
  }
}

const instance = new PostService();

export { instance as PostServiceApi }