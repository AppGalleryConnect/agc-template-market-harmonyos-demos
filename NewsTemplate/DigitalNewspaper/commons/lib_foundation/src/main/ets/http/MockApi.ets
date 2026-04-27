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

import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { URL_MAP } from '../common/Constant';
import { MockDigitalNews, MockNewsArticle, MockUserData } from './MockData';
import { ENewsRequest, NewsDetailRequest } from '../model/IRequest';
import { Utils } from '../utils/Utils';


export class MockApi {
  public start(adapter: AxiosMockAdapter) {
    /**
     * 华为账号登录
     */
    adapter.onPost(URL_MAP.LOGIN_WITH_HUAWEI_ID).reply(() => {
      return [HttpStatusCode.Ok, MockUserData.LOGIN_RESP];
    });

    /**
     * 读取用户信息
     */
    adapter.onGet(URL_MAP.GET_USER_INFO).reply(() => {
      return [HttpStatusCode.Ok, MockUserData.USER_INFO];
    });

    /**
     * 查询报纸来源列表
     */
    adapter.onGet(URL_MAP.QUERY_NEWS_SOURCE_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockDigitalNews.sources];
    })


    /**
     * 查询数字报纸列表
     */
    adapter.onGet(URL_MAP.QUERY_DIGITAL_NEWS_LIST).reply((config: AxiosRequestConfig) => {
      const params = config.params as ENewsRequest;
      const paperTime = Utils.formatDate(params.publishDate)
      MockDigitalNews.list.forEach(v => {
        v.id;
        v.paperTime = paperTime;
      });

      return [HttpStatusCode.Ok, [...MockDigitalNews.list]];
    });

    /**
     * 查询新闻文章
     */
    adapter.onGet(URL_MAP.QUERY_NEWS_ARTICLE).reply((config: AxiosRequestConfig) => {
      const param = config.params as NewsDetailRequest;
      const item = MockNewsArticle.list.find(v => v.id === param.newsId);

      return [HttpStatusCode.Ok, item];
    });

    /**
     * 查询新闻文章列表
     */
    adapter.onGet(URL_MAP.QUERY_NEWS_FOR_CARD).reply(() => {
      let randomIndex: number = Math.floor(Math.random() * MockNewsArticle.list.length);
      return [HttpStatusCode.Ok, MockNewsArticle.list[randomIndex]];
    })
  }
}
