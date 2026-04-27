import { InternalAxiosRequestConfig } from '@ohos/axios';
import { BASE_URL, URL_MAP } from '../constant/Index';
import { MockApi } from './MockApi';
import { Context } from '@ohos.arkui.UIContext';
import { UtilLog } from '@hw-agconnect/util-log';

/**
 * 处理喜欢、收藏、评论的数量，超过1w，则简化显示
 */
export const handleCount = (value: number) => {
  if (value === null) {
    return '0';
  }
  if (value > 10000) {
    return `${(value / 10000).toFixed(1)}w`;
  }
  return value.toString();
};

/**
 * 无域名的图片地址需要拼上域名
 */
export const handleImgSrc = (context: Context, url: string): string => {
  if (!url) {
    return '';
  }
  if (url.startsWith('https')) {
    return url;
  }

  if (url.startsWith('mockImage://')) {
    const resourceName = url.split('//')[1];
    try {
      const resource = context.resourceManager.getMediaBase64ByNameSync(resourceName);
      return resource
    } catch (err) {
      UtilLog.error('get image resource failed', err);
    }
  }

  return `${BASE_URL}${url}`;
};

/**
 * 去除头部空格
 */
export const trimStart = (str: string) => {
  let index = 0;
  while (index < str.length && /\s/.test(str[index])) {
    index++;
  }
  return str.substring(index);
}


/**
 * 映射相应mock接口
 */
export const getMockResponse = (config?: InternalAxiosRequestConfig): ESObject => {
  const url = config?.url || '';
  switch (url) {
    case URL_MAP.QUERY_TRAVELOGUE_LIST:
      return MockApi.queryTravelogueList(config);
    case URL_MAP.RECORD_BROWSE:
      return MockApi.recordBrowse();
    case URL_MAP.QUERY_TRAVELOGUE_DETAIL:
      return MockApi.queryTravelogueDetail(config);
    case URL_MAP.LIKE_TRAVELOGUE:
      return MockApi.likeTravelogue(config);
    case URL_MAP.CANCEL_LIKE_TRAVELOGUE:
      return MockApi.cancelLikeTravelogue(config);
    case URL_MAP.FAVOR_TRAVELOGUE:
      return MockApi.favorTravelogue(config);
    case URL_MAP.CANCEL_FAVOR_TRAVELOGUE:
      return MockApi.cancelFavorTravelogue(config);
    case URL_MAP.COMMENT_TRAVELOGUE:
      return MockApi.commentTravelogue(config);
    case URL_MAP.QUERY_ROUTE_LINE:
      return MockApi.queryRouteLineList();
    case URL_MAP.QUERY_ROUTE_LINE_DETAIL:
      return MockApi.queryRouteLineDetail(config);
    case URL_MAP.QUERY_ATTRACTION_DETAIL:
      return MockApi.queryAttractionDetail(config);
    default:
      return '';
  }
}

export const padZero = (input: number) => {
  return input.toString().padStart(2, '0');
};

/**
 * 格式化日期展示
 * @param date 日期
 */
export const formatDate = (date: Date): string => {
  return `${date.getFullYear()}/${padZero(date.getMonth() + 1)}/${padZero(date.getDate())}`;
}

/**
 * 格式化时间
 * @param date 日期
 */
export const formatTime = (date: Date): string => {
  return `${padZero(date.getHours())}:${padZero(date.getMinutes())}:${padZero(date.getSeconds())}`;
};

/**
 * 格式化日期时间展示
 * @param date 日期
 */
export const formatDateTime = (date: Date): string => {
  return `${formatDate(date)} ${formatTime(date)}`;
}

export const handleTimeFormat = (datetime: string | number) => {
  if (!datetime) {
    return '--';
  }
  const date = new Date(datetime);
  return formatDateTime(date);
};
