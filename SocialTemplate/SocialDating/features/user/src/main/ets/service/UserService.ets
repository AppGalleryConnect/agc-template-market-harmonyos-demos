import {
  BaseService,
  CommonRsp,
  FollowType,
  Constants,
  CreateUserRequest,
  GetUserResponse,
  QueryUserResponse,
  UserFullInfo,
  MockService
} from 'commons';
import { http } from '@kit.NetworkKit';
import Logger from 'commons/src/main/ets/utils/Logger';
import { SearchCondition } from '../model/SearchCondition';

export class UserService extends BaseService {
  async getUserFullInfoByUnionId(unionId: string | undefined | null): Promise<GetUserResponse | null> {
    if (this.serviceConfig.isMock) {
      return MockService.getUserFullInfoByUnionId(unionId);
    }
    let getUserRsp = await this.doRequest<GetUserResponse>('/user/' + unionId, http.RequestMethod.GET, null);
    if (getUserRsp == null || getUserRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('getUserFullInfoByUnionId failed, unionId=' + unionId);
      return null;
    } else {
      return getUserRsp;
    }
  }

  async getRecommendUsers(unionId: string | undefined, curPage: number): Promise<UserFullInfo[]> {
    if (this.serviceConfig.isMock) {
      let res = MockService.getRecommendUsers(unionId, curPage);
      return res == null ? [] : res;
    }
    let queryUserRsp = await this.doRequest<QueryUserResponse>('/user/recommended/' + unionId + '/' + curPage + '/1',
      http.RequestMethod.GET, null)
    if (queryUserRsp == null || queryUserRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('getRecommendUsers failed, unionId=' + unionId);
      return [];
    } else {
      Logger.debug('getRecommendUser=' + JSON.stringify(queryUserRsp.users));
      return queryUserRsp.users;
    }
  }

  async searchUsers(searchCondition: SearchCondition): Promise<UserFullInfo[]> {
    if (this.serviceConfig.isMock) {
      let res = MockService.searchUsers();
      return res == null ? [] : res;
    }
    let queryUserRsp =
      await this.doRequest<QueryUserResponse>('/user/query',
        http.RequestMethod.POST, JSON.stringify(searchCondition));
    Logger.debug('queryUserRsp=' + JSON.stringify(queryUserRsp));
    if (queryUserRsp == null || queryUserRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('searchUser failed, searchCondition=' + JSON.stringify(searchCondition));
      return [];
    } else {
      return queryUserRsp.users;
    }
  }

  async queryFollowedUser(uid: number, queryType: number, curPage ?: number,
    pageSize?: number): Promise<UserFullInfo[]> {
    if (this.serviceConfig.isMock) {
      let res = MockService.queryFollowedUser(uid, queryType, curPage, pageSize);
      return res == null ? [] : res;
    }
    let queryUserRsp =
      await this.doRequest<QueryUserResponse>(this.appendQueryFollowUserUrl('/user/followed/', uid, queryType, curPage,
        pageSize), http.RequestMethod.GET, null);
    Logger.debug('queryUserRsp=' + JSON.stringify(queryUserRsp));
    if (queryUserRsp == null || queryUserRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('queryFollowedUser failed, uid=' + uid + ',queryType=' + queryType);
      return [];
    } else {
      return queryUserRsp.users;
    }
  }

  appendQueryFollowUserUrl(uri: string, uid: number, queryType: number, curPage: number | undefined,
    pageSize: number | undefined): string {
    let url = super.appendPageParam(curPage, uri, pageSize);
    url += '?uid=' + uid;
    url += '&queryType=' + queryType;
    return url;
  }

  async createUser(createUserRequest: CreateUserRequest): Promise<CommonRsp | null> {
    if (this.serviceConfig.isMock) {
      let rsp = MockService.createUser(createUserRequest);
      Logger.debug('createUserRsp=' + JSON.stringify(rsp))
      return rsp;
    }
    let rsp = await this.doRequest<CommonRsp>('/user', http.RequestMethod.POST, JSON.stringify(createUserRequest));
    if (rsp == null || rsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('create user failed, createUserRequest=' + JSON.stringify(createUserRequest));
    }
    return rsp;
  }

  async updateUser(userFullInfo: UserFullInfo): Promise<CommonRsp | null> {
    if (this.serviceConfig.isMock) {
      return MockService.updateUser(userFullInfo);
    }
    let rsp = await this.doRequest<CommonRsp>('/user', http.RequestMethod.PUT, JSON.stringify(userFullInfo));
    if (rsp == null || rsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('update user failed, userFullInfo=' + JSON.stringify(userFullInfo));
    }
    return rsp;
  }

  async deleteUser(userFullInfo: UserFullInfo): Promise<CommonRsp | null> {
    if (this.serviceConfig.isMock) {
      return MockService.deleteCurrentUser();
    }
    let rsp =
      await this.doRequest<CommonRsp>('/user/' + userFullInfo?.userInfo?.hwUnionId, http.RequestMethod.DELETE, null);
    if (rsp == null || rsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('delete user failed, uid=' + userFullInfo?.userInfo?.hwUnionId);
    }
    return rsp;
  }

  async followUser(currentUid: number, followUid: number, hasFollowed: number | null): Promise<CommonRsp | null> {
    if (this.serviceConfig.isMock) {
      return MockService.followUser(followUid, currentUid,
        (hasFollowed == null || hasFollowed === Constants.NO) ? FollowType.Follow : FollowType.UnFollow)
    }
    let rsp =
      await this.doRequest<CommonRsp>('/user/follow', http.RequestMethod.POST,
        JSON.stringify(new FollowUserRequest(currentUid, followUid,
          (hasFollowed == null || hasFollowed === Constants.NO) ?
          FollowType.Follow : FollowType.UnFollow)));
    if (rsp == null || rsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('follow user failed, uid=' + currentUid + ', followUid=' + followUid);
    }
    return rsp;
  }
}

export default new UserService({
  baseUrl: '', isMock: true
});

class FollowUserRequest {
  uid: number;
  followUid: number;
  type: number;

  constructor(uid: number, followUid: number, type: number) {
    this.uid = uid;
    this.followUid = followUid;
    this.type = type;
  }
}