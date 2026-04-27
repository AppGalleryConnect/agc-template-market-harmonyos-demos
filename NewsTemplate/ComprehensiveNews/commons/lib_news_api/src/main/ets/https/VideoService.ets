import request from '../common/BaseRequest';
import { BaseNewsService } from './BaseNewsService';
import { NewsResponse } from '../params/response/NewsResponse';


/**
 * 新闻-视频类
 */
export class VideoService extends BaseNewsService {
  /**
   * 查询视频关注流
   * @param followedUserIds
   * @returns
   */
  public queryVideoFollowList(followedUserIds: string[]): Promise<NewsResponse[]> {
    return request.get('/video/follow/list', { params: { followedUserIds } });
  }

  /**
   * 查询视频流，如果有userId，查询对应用户的视频
   * 需要区分是纯视频还是发的动态中的视频
   * @param userId
   * @param type
   * @returns
   */
  public queryVideoList(userId: string = '', type: number): Promise<NewsResponse[]> {
    return request.get('/video/author/list', { params: { userId, type } });
  }

  /**
   * 查询直播视频流
   * @returns
   */
  public queryLiveVideoList(): Promise<NewsResponse[]> {
    return request.get('/video/live/list');
  }

  /**
   * 查询精彩回放视频
   * @returns
   */
  public queryHighlightVideoList(): Promise<NewsResponse[]> {
    return request.get('/video/highlight/list');
  }

  /**
   * 查询直播预约列表
   * @returns
   */
  public queryLiveReservationList(): Promise<NewsResponse[]> {
    return request.get('/video/reservation/list');
  }

  /**
   * 根据id查询详细信息
   * @param id
   * @returns
   */
  public queryVideoById(id: string): Promise<NewsResponse | undefined> {
    return request.get('/video', { params: { id } });
  }
}

const instance = new VideoService();

export { instance as VideoServiceApi };