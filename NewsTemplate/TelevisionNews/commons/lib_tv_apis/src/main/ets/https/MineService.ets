import request from '../common/BaseRequest';
import { AuthorService } from './AuthorService';
import {
  SubscribeRequest,
} from '../params/request/CommonRequest';
import { AvResponse } from '../params/response/AvResponse';

/**
 * 我的管理类
 */
export class MineService extends AuthorService {
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

}

const instance = new MineService();

export { instance as MineServiceApi };