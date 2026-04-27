import request from '../common/BaseRequest';
import { AuthorService } from './AuthorService';
import {
  AddReservationRequest,
  AuthorRequest,
  DeleteCommentRequest,
  ModifyPersonalInfoRequest,
  NewsRequest,
  PublishCommentRequest,
  SubscribeRequest,
} from '../params/request/CommonRequest';
import { NewsResponse } from '../params/response/NewsResponse';
import { AuthorResponse } from '../params/response/AuthorResponse';
import { AggregateNewsComment } from '../params/response/AggregateResponse';
import { CommentResponse } from '../params/response/CommentResponse';
import { AvResponse } from '../params/response/AvResponse';

/**
 * 我的管理类
 */
export class MineService extends AuthorService {
  /**
   * 点赞
   * @param newsId
   */
  public addLike(newsId: string): Promise<void> {
    const data: NewsRequest = { newsId };
    return request.post('/my/like/add', data);
  }

  /**
   * 取消点赞
   * @param newsId
   */
  public cancelLike(newsId: string): Promise<void> {
    const data: NewsRequest = { newsId };
    return request.post('/my/like/cancel', data);
  }

  /**
   * 查询我的点赞
   * @returns
   */
  public queryMyLikes(): Promise<NewsResponse[]> {
    return request.get('/my/like/list');
  }

  /**
   * 查询新增的粉丝
   * @returns
   */
  public queryNewFans(): Promise<AuthorResponse[]> {
    return request.get('/new/fans/list');
  }

  /**
   * 添加关注
   * @param authorId
   */
  public addWatch(authorId: string): Promise<void> {
    const data: AuthorRequest = { authorId };
    return request.post('/watch/add', data);
  }

  /**
   * 取消关注
   * @param authorId
   */
  public cancelWatch(authorId: string): Promise<void> {
    const data: AuthorRequest = { authorId };
    return request.post('/watch/cancel', data);
  }

  /**
   * 订阅公众号
   * @param subscribeId
   */
  public AddSubscribeWatch(subscribeId: string): Promise<void> {
    const data: SubscribeRequest = { subscribeId };
    return request.post('/subscribe/add', data);
  }

  /**
   * 取消订阅公众号
   * @param subscribeId
   */
  public cancelSubscribeWatch(subscribeId: string): Promise<void> {
    const data: SubscribeRequest = { subscribeId };
    return request.post('/subscribe/cancel', data);
  }

  /**
   * 取消全部订阅
   */
  public cancelAllSubscribe(): Promise<void> {
    return request.post('/subscribe/cancel/all');
  }

  /**
   * 查询我的订阅
   * @returns
   */
  public queryMySubscribe(userId: string): Promise<AvResponse[]> {
    return request.get('/my/subscribe/list', { params: { userId } });
  }

  /**
   * 收藏
   * @param newsId
   */
  public addMark(newsId: string): Promise<void> {
    const data: NewsRequest = { newsId };
    return request.post('/my/mark/add', data);
  }

  /**
   * 取消收藏
   * @param newsId
   */
  public cancelMark(newsId: string): Promise<void> {
    const data: NewsRequest = { newsId };
    return request.post('/mark/cancel', data);
  }

  /**
   * 查询我的收藏
   * @returns
   */
  public queryMyMarks(): Promise<NewsResponse[]> {
    return request.get('/my/mark/list');
  }

  /**
   * 发表评论
   * @param params
   */
  public publishComment(params: PublishCommentRequest): Promise<CommentResponse> {
    return request.post('/publish/comment', params);
  }

  /**
   * 查询我的评论
   * @returns
   */
  public queryMineCommentList(): Promise<AggregateNewsComment[]> {
    return request.get('/my/comment/list');
  }

  /**
   * 删除评论
   * @param newsId
   * @param commentId
   * @returns
   */
  public deleteComment(newsId: string, commentId: string): Promise<void> {
    const data: DeleteCommentRequest = {
      newsId,
      commentId,
    };
    return request.post('/comment/delete', data);
  }

  /**
   * 添加到阅读历史
   * @param newsId
   */
  public addToHistory(newsId: string): Promise<void> {
    const data: NewsRequest = { newsId };
    return request.post('/history/add', data);
  }

  /**
   * 从阅读历史中删除
   * @param newsId
   */
  public deleteFromHistory(newsId: string): Promise<void> {
    const data: NewsRequest = { newsId };
    return request.post('/history/delete', data);
  }

  /**
   * 查询我的阅读记录
   * @returns
   */
  public queryMyHistory(): Promise<NewsResponse[]> {
    return request.get('/my/history/list');
  }

  /**
   * 修改个人信息
   * @param params
   * @returns
   */
  public modifyPersonalInfo(params: ModifyPersonalInfoRequest): Promise<void> {
    return request.post('/modify/personal/info', params);
  }

  /**
   * 添加预约
   * @param newsId
   * @param liveStartTime
   * @param eventId
   */
  public addReservation(newsId: string, liveStartTime: number, eventId: number): Promise<void> {
    const data: AddReservationRequest = { newsId, liveStartTime, eventId };
    return request.post('/my/reservation/add', data);
  }

  /**
   * 取消预约
   * @param newsId
   */
  public cancelReservation(newsId: string): Promise<void> {
    const data: NewsRequest = { newsId };
    return request.post('/my/reservation/cancel', data);
  }

  /**
   * 查询我的预约列表
   * @returns
   */
  public queryMyReservations(): Promise<NewsResponse[]> {
    return request.get('/my/reservation/list');
  }

  /**
   * 批量删除预约记录
   * @param newsIds
   */
  public deleteReservations(newsIds: string[]): Promise<void> {
    return request.post('/my/reservation/delete', newsIds);
  }

  /**
   * 拉黑作者
   * @param authorId
   * @returns
   */
  public blockAuthor(authorId: string): Promise<void> {
    return request.post('/my/block/author', authorId);
  }

  /**
   * 屏蔽新闻
   * @param newsId
   * @returns
   */
  public blockNews(newsId: string): Promise<void> {
    return request.post('/my/block/news', newsId);
  }
}

const instance = new MineService();

export { instance as MineServiceApi };