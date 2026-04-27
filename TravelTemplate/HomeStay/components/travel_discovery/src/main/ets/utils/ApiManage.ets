import { AxiosRequestConfig } from '@ohos/axios';
import request from './AxiosBase';
import {
  CommentTravelogueRequest,
  LikeTravelogueRequest,
  QueryTravelogueDetailRequest,
  QueryTravelogueListRequest,
  RecordBrowseRequest,
} from '../model/IRequest';
import { RELATE_TYPE, URL_MAP } from '../constant/Index';

const userId: number = AppStorage.get('userId') || 93;
const appId: string = AppStorage.get('appId') || '5765880207855322407';

/**
 * 游记分页列表接口
 */
export const queryTravelogueList = (data: QueryTravelogueListRequest): Promise<ESObject> => {
  const url = URL_MAP.QUERY_TRAVELOGUE_LIST;
  const config: AxiosRequestConfig = { headers: { appId } };
  data.userId = userId;
  return request.post(url, data, config);
};

/**
 * 游记增加浏览记录接口
 */
export const recordBrowse = (id: number) => {
  const url = URL_MAP.RECORD_BROWSE;
  const data: RecordBrowseRequest = { id };
  return request.post(url, data);
};

/**
 * 游记详情接口
 */
export const queryTravelogueDetail = (id: number): Promise<ESObject> => {
  const url = URL_MAP.QUERY_TRAVELOGUE_DETAIL;
  const data: QueryTravelogueDetailRequest = { userId, id }
  return request.post(url, data);
};

/**
 * 游记点赞接口
 */
export const likeTravelogue = (id: number): Promise<ESObject> => {
  const url = URL_MAP.LIKE_TRAVELOGUE;
  const data: LikeTravelogueRequest = { userId, relId: id, relType: RELATE_TYPE };
  return request.post(url, data);
};

/**
 * 游记取消点赞接口
 */
export const cancelLikeTravelogue = (id: number): Promise<ESObject> => {
  const url = URL_MAP.CANCEL_LIKE_TRAVELOGUE;
  const data: LikeTravelogueRequest = { userId, relId: id, relType: RELATE_TYPE };
  return request.post(url, data);
};

/**
 * 游记收藏接口
 */
export const favorTravelogue = (id: number): Promise<ESObject> => {
  const url = URL_MAP.FAVOR_TRAVELOGUE;
  const data: LikeTravelogueRequest = { userId, relId: id, relType: RELATE_TYPE };
  return request.post(url, data);
};

/**
 * 游记取消收藏接口
 */
export const cancelFavorTravelogue = (id: number): Promise<ESObject> => {
  const url = URL_MAP.CANCEL_FAVOR_TRAVELOGUE;
  const data: LikeTravelogueRequest = { userId, relId: id, relType: RELATE_TYPE };
  return request.post(url, data);
};

/**
 * 游记评价接口
 */
export const commentTravelogue = (id: number, content: string): Promise<ESObject> => {
  const url = URL_MAP.COMMENT_TRAVELOGUE;
  const data: CommentTravelogueRequest = { userId, travelId: id, evaluateContent: content };
  return request.post(url, data);
};