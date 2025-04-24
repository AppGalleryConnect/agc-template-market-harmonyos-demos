import {
  BaseService,
  CommonRsp,
  Constants,
  GetFeedResponse,
  CreateFeedResponse,
  CreateFeedRequest,
  Feed,
  FollowType,
  QueryFeedResponse,
  FollowUserRequest,
  MockService
} from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import { http } from '@kit.NetworkKit';

export class FeedService extends BaseService {
  async getFeedList(queryType: string, uid?: number | null, curPage?: number,
    pageSize?: number): Promise<QueryFeedResponse | null> {
    if (this.serviceConfig.isMock) {
      return MockService.getFeedList(queryType, uid, curPage, pageSize)
    }
    let queryRsp =
      await this.doRequest<QueryFeedResponse>(this.appendUrl('/feed/list/', queryType, uid, curPage, pageSize),
        http.RequestMethod.GET, null);
    if (queryRsp == null || queryRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('queryFeed failed, queryType=' + queryType);
    }
    return queryRsp;
  }

  async getFeedDetail(feedId: number): Promise<Feed | null> {
    if (this.serviceConfig.isMock) {
      return MockService.getFeedDetail(feedId)
    }
    let queryRsp = await this.doRequest<GetFeedResponse>('/feed/' + feedId, http.RequestMethod.GET, null);
    if (queryRsp == null || queryRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('queryFeed failed, feedId=' + feedId);
      return null;
    } else {
      return queryRsp.feed;
    }
  }

  async createFeed(createFeedReq: CreateFeedRequest): Promise<number | null> {
    if (this.serviceConfig.isMock) {
      return MockService.createFeed(createFeedReq)
    }
    let createFeedRsp =
      await this.doRequest<CreateFeedResponse>('/feed', http.RequestMethod.POST, JSON.stringify(createFeedReq));
    Logger.debug('createFeedRsp=' + JSON.stringify(createFeedRsp));
    if (createFeedRsp == null || createFeedRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('createFeed failed, createFeedReq=' + JSON.stringify(createFeedReq));
      return null;
    } else {
      return createFeedRsp.feedId;
    }
  }

  /**
   * 关注用户（本方法与UserService中的followUser方法是一样的，为了避免交叉依赖，冗余了本方法）
   * @param followUid  followUid
   * @param currentUid currentUid
   * @param type type
   * @returns CommonRsp
   */
  async followUser(followUid: number, currentUid: number, type: FollowType): Promise<CommonRsp | null> {
    if (this.serviceConfig.isMock) {
      return MockService.followUser(followUid, currentUid, type)
    }
    let followUserReq: FollowUserRequest = new FollowUserRequest(currentUid, followUid, type);
    let followRsp =
      await this.doRequest<CommonRsp>('/user/follow', http.RequestMethod.POST, JSON.stringify(followUserReq));
    if (followRsp == null || followRsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('followUser failed, followRsp=' + JSON.stringify(followRsp) + ', followReq=' +
      JSON.stringify(followUserReq));
      return null;
    } else {
      return followRsp;
    }
  }

  private appendUrl(url: string, queryType: string, uid?: number | null, curPage?: number, pageSize?: number): string {
    url = super.appendPageParam(curPage, url, pageSize);
    url += '?queryType=' + queryType;
    if (uid !== undefined && uid != null) {
      url += '&uid=' + uid;
    }
    return url;
  }
}

export default new FeedService({
  baseUrl: BaseService.BASE_URL_MOCK, isMock: true
});