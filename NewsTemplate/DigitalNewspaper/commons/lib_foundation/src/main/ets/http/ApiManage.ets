/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AxiosRequestConfig } from '@ohos/axios';
import request from './AxiosBase';
import { URL_MAP } from '../common/Constant';
import { ILoginWithHuaweiIDRequest } from '../model/IRequest';
import { DigitalNewsResponse, DigitalNewsSource, IUserInfo, LoginWithHuaweiIDResp,
  NewsArticle } from '../model/IResponse';

/**
 * 华为账号登录
 */
export const loginWithHuaweiID =
  (data: ILoginWithHuaweiIDRequest, config?: AxiosRequestConfig): Promise<LoginWithHuaweiIDResp> => {
    const url = URL_MAP.LOGIN_WITH_HUAWEI_ID;
    return request.post(url, data, config);
  };

/**
 * 读取用户信息
 */
export const getUserInfo = (): Promise<IUserInfo> => {
  const url = URL_MAP.GET_USER_INFO;
  return request.get(url);
};


/**
 * 查询报纸来源列表
 */
export const queryNewsSourceList = (): Promise<DigitalNewsSource[]> => {
  const url = URL_MAP.QUERY_NEWS_SOURCE_LIST;
  return request.get(url);
}

/**
 * 查询数字报纸
 * @param sourceId
 * @param publishDate
 * @returns
 */
export const queryDigitalNewsList = (sourceId: string, publishDate: number): Promise<DigitalNewsResponse[]> => {
  const url = URL_MAP.QUERY_DIGITAL_NEWS_LIST;
  return request.get(url, { params: { sourceId, publishDate } });
}

/**
 * 查询新闻文章
 * @param newsId
 * @returns
 */
export const queryNewsArticle = (newsId: string): Promise<NewsArticle> => {
  const url = URL_MAP.QUERY_NEWS_ARTICLE;
  return request.get(url, { params: { newsId } });
}

/**
 * 获取服务卡片新闻文章
 * @returns
 */
export const queryNewsList = (): Promise<NewsArticle> => {
  const url = URL_MAP.QUERY_NEWS_FOR_CARD;
  return request.get(url);
}