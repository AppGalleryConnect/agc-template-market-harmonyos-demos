import { HttpUtil } from '../utils/HttpUtil';
import { http } from '@kit.NetworkKit';
import Logger from '../utils/Logger';
import { CommonUtils } from '../utils/CommonUtils';
import url from '@ohos.url';
import { Constants, QueryFeedType } from '../utils/Constants';
import { UiUtils } from '../utils/UiUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import { BufferUtil } from '../utils/BufferUtil';
import { BasicUserInfo } from '../model/BasicUserInfo';

export class ServiceConfig {
  baseUrl: string | null = null;
  isMock: boolean = false;
}

export class BaseService {
  public static CUR_PAGE_DEFAULT: number = 1;
  public static PAGE_SIZE_DEFAULT: number = 10;
  public static BASE_URL_MOCK = 'http://127.0.0.1';
  protected serviceConfig: ServiceConfig;
  private httpUtil: HttpUtil;

  constructor(serviceConfig: ServiceConfig) {
    this.serviceConfig = serviceConfig;
    this.httpUtil = new HttpUtil();
  }

  public async doRequest<T>(url: string, reqMethod: http.RequestMethod, data: string | null): Promise<T> {
    Logger.debug('doRequest,url=' + url + ', reqData=' + data);
    if (this.serviceConfig.isMock) {
      return mockResult(this.serviceConfig.baseUrl + url, reqMethod);
    }
    let resStr = '';
    await this.httpUtil.doRequest(url, reqMethod, data).then((rsp: string) => {
      resStr = rsp;
    })
    let res = JSON.parse(resStr) as T;
    this.httpUtil.destroyHttpRequest();
    return res;
  }

  public appendPageParam(curPage: number | undefined, url: string, pageSize: number | undefined): string {
    if (curPage === undefined) {
      url += BaseService.CUR_PAGE_DEFAULT;
    } else {
      url += curPage;
    }
    url += '/';
    if (pageSize === undefined) {
      url += BaseService.PAGE_SIZE_DEFAULT;
    } else {
      url += pageSize;
    }
    return url;
  }
}

export function getRawFile<T>(filePath: string): Promise<T> {
  return getContext().resourceManager.getRawFileContent(filePath)
    .then((value: Uint8Array) => {
      let res: string = BufferUtil.bufferToString(value);
      return JSON.parse(res) as T;
    }).catch((e: BusinessError) => {
      Logger.error(`getRawFileContent failed, error code: ${e.code}, message: ${e.message}.`);
      UiUtils.showToast(e.message);
      return Promise.reject(e);
    });
}

export function getCurrentUid():number |null{
  let currentUserBasic: BasicUserInfo | null | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
  if (currentUserBasic != null && currentUserBasic !== undefined) {
    return currentUserBasic.uid
  }
  return null;
}

function mockResult<T>(url: string, reqMethod: http.RequestMethod): Promise<T> {
  let filePath = 'oper.common.rsp.json';
  if (reqMethod === http.RequestMethod.GET) {
    if (url.indexOf('user') > 0) {
      filePath = getMockFilePathForUser(url);
    } else if (url.indexOf('activity') > 0) {
      filePath = getMockFilePathForActivity(url);
    } else if (url.indexOf('feed') > 0) {
      filePath = getMockFilePathForFeed(url);
    } else if (url.indexOf('matchmaker') > 0) {
      filePath = 'query.matchmaker.1.json';
    } else if (url.indexOf('membership') > 0) {
      filePath = 'query.membership.json';
    }
  } else if (reqMethod === http.RequestMethod.POST) {
    if (url.indexOf('user/query') > 0) {
      if (isCurrentUserFemale()) {
        filePath = 'query.user.json';
      } else {
        filePath = 'query.user.1.json';
      }
    } else if (url.indexOf('feed') > 0) {
      filePath = 'create.feed.rsp.json';
    }
  }
  Logger.debug('mockResult filePath=' + filePath + ', url=' + url);
  return getRawFile<T>(filePath)
}

function getMockFilePathForFeed(inputUrl: string): string {
  let filePath = 'get.empty.json'
  if (inputUrl.indexOf('feed/list') > 0) {
    const urlObj = url.URL.parseURL(inputUrl)
    let queryType = urlObj.params.get('queryType');
    if (queryType === QueryFeedType.QUERY_RECOMMEND.toString()) {
      filePath = 'query.recommend.feed.json';
    } else if (queryType === QueryFeedType.QUERY_FOLLOWED.toString()) {
      filePath = 'query.followed.feed.json';
    } else if (queryType === QueryFeedType.QUERY_BY_USER.toString()) {
      let uid = urlObj.params.get('uid');
      filePath = 'query.feed.by.user.' + uid + '.json';
    }
    return filePath;
  } else {
    let urlSplit: string[] = inputUrl.split('/')
    let feedId = urlSplit[urlSplit.length-1];
    return 'get.feed.detail.' + feedId + '.json';
  }
}

function getMockFilePathForUser(url: string): string {
  let filePath = 'get.empty.json'
  if (url.indexOf('user/query') > 0) {
    filePath = 'query.user.json';
  } else if (url.indexOf('user/recommended') > 0) {
    let urlSplit: string[] = url.split('/')
    let curPageParam = urlSplit[urlSplit.length-2];
    if (CommonUtils.isDigit(curPageParam)) {
      let curPage = parseInt(curPageParam);
      if (curPage === 1) {
        filePath = 'get.recommend.user.1.json';
      } else if (curPage === 2) {
        filePath = 'get.recommend.user.2.json';
      } else {
        filePath = 'get.empty.json';
      }
    }
  } else if (url.indexOf('user/followed') > 0) {
    filePath = 'get.empty.json';
  } else {
    let firstLoginFlag: boolean | undefined = AppStorage.get(Constants.FIRST_LOGIN_FLAG);
    if (firstLoginFlag === undefined || firstLoginFlag) {
      filePath = 'get.empty.json';
    } else {
      filePath = 'get.user.json';
    }
  }
  return filePath;
}

function getMockFilePathForActivity(inputUrl: string): string {
  if (inputUrl.indexOf('activity/list') > 0) {
    return 'query.activity.list.json';
  } else if (inputUrl.indexOf('activity/enrolled') > 0) {
    return 'query.enrolled.activity.list.json'
  } else {
    let urlSplit: string[] = inputUrl.split('/')
    let activityId = urlSplit[urlSplit.length-1];
    return 'get.activity.detail.' + activityId + '.json';
  }
}


function isCurrentUserFemale() {
  let currentUserBasic: BasicUserInfo | null | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
  if (currentUserBasic != null && currentUserBasic !== undefined) {
    return currentUserBasic.gender === Constants.GENDER_FEMALE
  }
  return false;
}
