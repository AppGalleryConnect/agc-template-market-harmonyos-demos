/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
export class CommonConstant {
  static readonly FULL_PERCENT: string = '100%';
}

export interface BarModel {
  label: ResourceStr;
  value: QueryTravelogueListType;
}

// 关系类型，游记的固定值
export const RELATE_TYPE = 'TRAVELOGUE';

// 服务端请求基础链接
export const BASE_URL = '';

// 有无的标记
export enum StatusFLAG {
  YES = 'Y',
  NO = 'N',
}

// ALL:全部，NEW:最新，HOT:最热
export enum QueryTravelogueListType {
  ALL = 'ALL',
  NEW = 'NEW',
  HOT = 'HOT',
}

// url命名
export enum URL_MAP {
  QUERY_TRAVELOGUE_LIST = '/api/travelogue/page',
  RECORD_BROWSE = '/api/travelogue/browse',
  QUERY_TRAVELOGUE_DETAIL = '/api/travelogue/detail',
  LIKE_TRAVELOGUE = '/api/likes/add',
  CANCEL_LIKE_TRAVELOGUE = '/api/likes/delete',
  FAVOR_TRAVELOGUE = '/api/favorites/add',
  CANCEL_FAVOR_TRAVELOGUE = '/api/favorites/delete',
  COMMENT_TRAVELOGUE = '/api/travelogue/evaluate',
}
;

export enum PageRouteName {
  PAGE_DETAIL = 'PageDetail',
  PAGE_SEARCH = 'PageSearch',
}

export enum EventEmitName {
  CHANGE_LIKED = 'changeLiked'
}

export const BAR_LIST: BarModel[] = [
  {
    label: $r('app.string.bar_total'),
    value: QueryTravelogueListType.ALL,
  },
  {
    label: $r('app.string.bar_new'),
    value: QueryTravelogueListType.NEW,
  },
  {
    label: $r('app.string.bar_hot'),
    value: QueryTravelogueListType.HOT,
  },
];

