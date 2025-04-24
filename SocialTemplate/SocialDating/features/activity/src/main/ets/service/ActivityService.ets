import { BaseService, Constants } from 'commons';
import { QueryActivityResponse } from '../model/QueryActivityResponse';
import { http } from '@kit.NetworkKit';
import Logger from 'commons/src/main/ets/utils/Logger';
import { GetActivityResponse } from '../model/GetActivityResponse';
import { ActivityInfo } from '../model/ActivityInfo';
import { QueryEnrolledActivitiesResponse } from '../model/QueryEnrolledActivitiesResponse';

export class ActivityService extends BaseService {
  async queryActivities(city: string, curPage?: number, pageSize?: number): Promise<QueryActivityResponse | null> {
    let queryRsp =
      await this.doRequest<QueryActivityResponse>(this.appendUrl(city, curPage, pageSize),
        http.RequestMethod.GET, null);
    Logger.debug('queryActivities rsp =' + JSON.stringify(queryRsp));
    if (queryRsp == null || queryRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('queryActivities failed, city=' + city);
      return null;
    } else {
      return queryRsp;
    }
  }

  async queryEnrolledActivities(uid: number, curPage?: number,
    pageSize?: number): Promise<QueryEnrolledActivitiesResponse | null> {
    let queryRsp =
      await this.doRequest<QueryEnrolledActivitiesResponse>(this.appendUrlForQueryEnrolledActivities(uid, curPage,
        pageSize),
        http.RequestMethod.GET, null);
    Logger.debug('queryEnrolledActivities rsp =' + JSON.stringify(queryRsp));
    if (queryRsp == null || queryRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('queryEnrolledActivities failed, uid=' + uid + ', curPage=' + curPage + ', pageSize=' + pageSize);
      return null;
    } else {
      return queryRsp;
    }
  }

  appendUrlForQueryEnrolledActivities(uid: number, curPage: number | undefined, pageSize: number | undefined): string {
    let url = '/activity/enrolled/' + uid + '/';
    return super.appendPageParam(curPage, url, pageSize);
  }

  async getActivity(activityId: number): Promise<ActivityInfo | null> {
    let queryRsp =
      await this.doRequest<GetActivityResponse>('/activity/' + activityId,
        http.RequestMethod.GET, null);
    Logger.debug('getActivity rsp =' + JSON.stringify(queryRsp));
    if (queryRsp == null || queryRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.warn('getActivity failed, activityId=' + activityId);
      return null;
    } else {
      return queryRsp.activity;
    }
  }

  appendUrl(city: string, curPage: number | undefined, pageSize: number | undefined): string {
    let url = '/activity/list/';
    url = super.appendPageParam(curPage, url, pageSize);
    url += '?city=' + city;
    return url;
  }
}

export default new ActivityService({
  baseUrl: BaseService.BASE_URL_MOCK, isMock: true
});

