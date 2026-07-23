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
import { CommonUtils, IGoodCategory, IGoodInfo } from 'module_base';
import { FilterTagAndList, SearchItem, SearchSource, SearchWordItem } from 'search';
import { OrderStatus, QueryGoodListSource, URL_MAP, } from '../common/Constant';
import {
  IAppointmentUpdate,
  IOrderUpdate,
  IQueryGood,
  IQueryGoodList,
  IQueryOrderList,
  ISearchResultParams,
  ISubmitOrderRequest,
  IUpdateCity,
  IVerifyCode,
} from '../model/IRequest';
import { BindMobileWithCodeResp, IFullOrderInfo, IOrderDetail, ISearchWordItem, IUserInfo } from '../model/IResponse';
import { MockData } from './MockData';


export class MockApi {
  static subIndex: number = 0;
  static myOrderList: IOrderDetail[] = [];
  static isBindMobile: boolean = false;
  static _refreshTimes: number = 0;

  static buildOrderFullInfo(orderInfo: IOrderDetail): IFullOrderInfo {
    const goodInfo = MockData.ALL_GOOD_LIST.find(v => v.id === orderInfo.goodId)!;
    const fullInfo: IFullOrderInfo = {
      id: goodInfo.id,
      title: goodInfo.title,
      subTitle: goodInfo.subTitle,
      vipPrice: goodInfo.vipPrice,
      image: goodInfo.image,
      addressName: `${orderInfo.addressName} ${orderInfo.addressStr}`,
      contactPhone: orderInfo.contactPhone,
      appointTime: orderInfo.appointTime,
      remark: orderInfo.remark,
      actualPay: orderInfo.actualPay,
      orderId: orderInfo.orderId,
      status: orderInfo.status,
      orderTime: orderInfo.orderTime,
      payTime: orderInfo.payTime,
      consumeTime: orderInfo.consumeTime,
      refundTime: orderInfo.refundTime,
      setSubscription: orderInfo.setSubscription,
      setSchedule: orderInfo.setSchedule,
      calendarId: orderInfo.calendarId,
    };

    return fullInfo;
  }

  static generateOrder(param: ISubmitOrderRequest): IOrderDetail {
    const myOrder: IOrderDetail = {
      orderId: new Date().getTime().toString(),
      goodId: param.goodId,
      addressName: param.addressName,
      addressStr: param.addressStr,
      contactPhone: param.contactPhone,
      contactName: param.contactName,
      appointTime: param.appointTime,
      remark: param.remark,
      actualPay: param.actualPay,
      status: OrderStatus.TO_PAY,
      orderTime: new Date().getTime(),
      setSubscription: false,
      setSchedule: false,
    };

    return myOrder;
  }

  static addHistoryList(historyWord: string, searchId?: number | string): Promise<void> {
    const historyData = MockData.HISTORY_LIST;
    const recordIndex = historyData.findIndex(item => item.content === historyWord);
    if (recordIndex === -1) {
      historyData.unshift({ content: historyWord, id: searchId ?? Date.now() });
    } else {
      const record = historyData[recordIndex];
      historyData.splice(recordIndex, 1);
      historyData.unshift(record);
    }
    return Promise.resolve();
  }

  static buildSearchResult(goodInfo: IGoodInfo): SearchItem {
    const searchResultItem: SearchItem = {
      title: goodInfo.title,
      id: goodInfo.id,
      image: CommonUtils.handleImgUrl(goodInfo.image),
      intro: goodInfo.subTitle,
      price: goodInfo.price,
      vipPrice: goodInfo.vipPrice,
      soldNum: goodInfo.soldNum,
      classId: goodInfo.classId,
      subIndex: goodInfo.subIndex,
    };
    return searchResultItem;
  }

  static findSearchResult(keyword: string): SearchItem[] {
    const category = MockData.ALL_CATEGORY_SERVICES.find(v => v.categoryLabel.includes(keyword));
    return MockData.ALL_GOOD_LIST.filter(v => {
      if (v.classId === category?.categoryId) {
        return true;
      }
      if (v.title.includes(keyword)) {
        return true;
      }
      if (v.subTitle.includes(keyword)) {
        return true;
      }
      if (JSON.stringify(v.serviceContentList).includes(keyword)) {
        return true;
      }
      if (JSON.stringify(v.feeList).includes(keyword)) {
        return true;
      }
      return false;
    }).map((item) => {
      return MockApi.buildSearchResult(item);
    });
  }

  public start(adapter: AxiosMockAdapter) {
    /**
     * 华为账号登录
     */
    adapter.onPost(URL_MAP.LOGIN_WITH_HUAWEI_ID).reply(() => {
      return [HttpStatusCode.Ok, MockData.LOGIN_RESP];
    });

    /**
     * 读取用户信息
     */
    adapter.onGet(URL_MAP.GET_USER_INFO).reply(() => {
      return [HttpStatusCode.Ok, MockData.USER_INFO];
    });

    /**
     * 更新用户信息
     */
    adapter.onPost(URL_MAP.UPDATE_USER_INFO).reply((config: AxiosRequestConfig) => {
      const data: IUserInfo = JSON.parse(config?.data ?? '{}') as IUserInfo;
      CommonUtils.assign(MockData.USER_INFO, data);
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 首页聚合信息
     */
    adapter.onGet(URL_MAP.GET_HOME_INFO).reply(() => {
      const bannerGoodIdList: string[] = ['home_clean_banner1', 'home_clean_1', 'closet_storage_organization_0'];
      MockData.HOME_INFO.bannerGoods = bannerGoodIdList.map((v: string) => {
        return MockData.ALL_GOOD_LIST.find((item) => item.id === v)!;
      })
      return [HttpStatusCode.Ok, MockData.HOME_INFO];
    });

    /**
     * 绑定手机号
     */
    adapter.onPost(URL_MAP.BIND_MOBILE_WITH_CODE).reply(() => {
      const resp: BindMobileWithCodeResp = {
        status: '0',
        rebindSecret: '',
      };
      return [HttpStatusCode.Ok, resp];
    });

    /**
     * 绑定手机号-确认换绑
     */
    adapter.onPost(URL_MAP.CONFIRM_REBIND_MOBILE).reply(() => {
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 手机号解绑
     */
    adapter.onPost(URL_MAP.UNBIND_MOBILE).reply(() => {
      MockApi.isBindMobile = false;
      return [HttpStatusCode.Ok, MockApi.isBindMobile];
    });

    /**
     * 更新城市
     */
    adapter.onPost(URL_MAP.UPDATE_CITY_SELECTED).reply((config: AxiosRequestConfig) => {
      const data: IUpdateCity = JSON.parse(config?.data ?? '{}') as IUpdateCity;
      MockData.HOME_INFO.citySelected = data.city;
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 更新当前定位城市
     */
    adapter.onPost(URL_MAP.UPDATE_CITY_CURRENT).reply((config: AxiosRequestConfig) => {
      const data: IUpdateCity = JSON.parse(config?.data ?? '{}') as IUpdateCity;
      MockData.HOME_INFO.currentCity = data.city;
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 获取所有的分类信息
     */
    adapter.onGet(URL_MAP.GET_CATEGORY_INFO).reply(() => {
      MockData.ALL_CATEGORY_SERVICES.forEach((v: IGoodCategory) => {
        if (v.categoryId === 'season_hot') {
          // 当季热门特殊处理下，挑选几个商品
          const hotIdList = ['closet_storage_organization_0', 'window_clean_0', 'digital_product_repair_0'];
          const filterRsp = MockData.ALL_GOOD_LIST.filter(good => hotIdList.includes(good.id));
          v.list.push(...filterRsp);
        } else {
          const filterRsp = MockData.ALL_GOOD_LIST.filter(good => good.classId === v.categoryId);
          v.list.push(...filterRsp);
        }
      })
      return [HttpStatusCode.Ok, MockData.ALL_CATEGORY_SERVICES];
    });

    /**
     * 查询商品列表
     */
    adapter.onGet(URL_MAP.GET_GOOD_LIST).reply((config: AxiosRequestConfig) => {
      const params: IQueryGoodList = config?.params;
      if (params.source === QueryGoodListSource.MINE) {
        const COUNT = 8;
        const list = MockData.ALL_GOOD_LIST.slice(4, 4 + COUNT);
        list.forEach((v) => {
          v.subIndex = MockApi.subIndex++;
        });
        return [HttpStatusCode.Ok, list];
      }

      const list = MockData.ALL_GOOD_LIST.slice();
      list.forEach((v) => {
        v.subIndex = MockApi.subIndex++;
      });

      return [HttpStatusCode.Ok, list];
    });

    /**
     * 获取单个商品
     */
    adapter.onGet(URL_MAP.GET_GOOD).reply((config: AxiosRequestConfig) => {
      const params: IQueryGood = config?.params;
      const item = MockData.ALL_GOOD_LIST.find(v => v.id === params.goodId);
      return [HttpStatusCode.Ok, item];
    });

    /**
     * 查询订单列表
     */
    adapter.onGet(URL_MAP.GET_ORDER_LIST).reply((config: AxiosRequestConfig) => {
      const params: IQueryOrderList = config?.params;
      return [HttpStatusCode.Ok, MockApi.myOrderList.filter((v: IOrderDetail) => {
        // 查询列表时，加上是否已完成的判断逻辑
        if (v.status === OrderStatus.TO_USE && v.appointTime <= new Date().getTime()) {
          v.status = OrderStatus.NORMAL_FINISH;
          v.consumeTime = new Date().getTime();
        }
        if (params.status === OrderStatus.ALL) {
          return true;
        }
        if (params.status === OrderStatus.REFUND) {
          return [OrderStatus.REFUND_ING, OrderStatus.REFUND_DONE].includes(v.status);
        }
        return params.status === v.status;
      }).map((item) => {
        return MockApi.buildOrderFullInfo(item);
      })];
    });

    /**
     * 查询单个订单
     */
    adapter.onGet(URL_MAP.GET_ORDER).reply((config: AxiosRequestConfig) => {
      const params: IOrderUpdate = config?.params;
      const item = MockApi.myOrderList.find(v => v.orderId === String(params.orderId))!;
      return [HttpStatusCode.Ok, MockApi.buildOrderFullInfo(item)];
    });

    /**
     * 预下单
     */
    adapter.onPost(URL_MAP.PRE_ORDER).reply((config: AxiosRequestConfig) => {
      const data: ISubmitOrderRequest = JSON.parse(config?.data ?? '{}') as ISubmitOrderRequest;
      const myOrder = MockApi.generateOrder(data);
      MockApi.myOrderList.splice(0, 0, myOrder);
      return [HttpStatusCode.Ok, myOrder.orderId];
    });

    /**
     * 付款
     */
    adapter.onPost(URL_MAP.PAY_ORDER).reply((config: AxiosRequestConfig) => {
      const data: IOrderUpdate = JSON.parse(config?.data ?? '{}') as IOrderUpdate;
      const item = MockApi.myOrderList.find(v => v.orderId === data.orderId);
      if (item) {
        item.status = OrderStatus.TO_USE;
        item.payTime = new Date().getTime();
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 退款
     */
    adapter.onPost(URL_MAP.REFUND).reply((config: AxiosRequestConfig) => {
      const data: IOrderUpdate = JSON.parse(config?.data ?? '{}') as IOrderUpdate;
      const item = MockApi.myOrderList.find(v => v.orderId === data.orderId);
      if (item) {
        item.status = OrderStatus.REFUND_ING;

        setTimeout(() => {
          item.status = OrderStatus.REFUND_DONE;
          item.refundTime = new Date().getTime();
        }, 1000 * 60);
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 取消订单
     */
    adapter.onPost(URL_MAP.CANCEL_ORDER).reply((config: AxiosRequestConfig) => {
      const data: IOrderUpdate = JSON.parse(config?.data ?? '{}') as IOrderUpdate;
      const item = MockApi.myOrderList.find(v => v.orderId === data.orderId);
      if (item) {
        item.status = OrderStatus.CANCEL;
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 修改预约信息
     */
    adapter.onPost(URL_MAP.UPDATE_APPOINTMENT_INFO).reply((config: AxiosRequestConfig) => {
      const data: IAppointmentUpdate = JSON.parse(config?.data ?? '{}') as IAppointmentUpdate;
      const item = MockApi.myOrderList.find(v => v.orderId === data.orderId);
      if (item) {
        item.setSubscription = data.setSubscription;
        item.setSchedule = data.setSchedule;
        if (data.calendarId) {
          item.calendarId = data.calendarId;
        }
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 发送验证码
     */
    adapter.onPost(URL_MAP.SEND_CODE).reply((config: AxiosRequestConfig) => {
      const data: string = config?.data ?? '';
      const processedData = data.replace(/\*/g, '0');
      return [HttpStatusCode.Ok, processedData.slice(0, 6)];
    });

    /**
     * 校验验证码
     */
    adapter.onGet(URL_MAP.VERIFY_CODE).reply((config: AxiosRequestConfig) => {
      const params: IVerifyCode = config?.params;
      const processedData = params.phone.replace(/\*/g, '0');
      if (processedData.slice(0, 6) === params.code) {
        return [HttpStatusCode.Ok, true];
      }
      return [HttpStatusCode.Ok, false];
    });

    /**
     * 获取历史词条
     */
    adapter.onGet(URL_MAP.GET_HISTORY_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockData.HISTORY_LIST];
    });

    /**
     * 清空历史记录
     */
    adapter.onGet(URL_MAP.DELETE_HISTORY).reply(() => {
      MockData.HISTORY_LIST = [];
      return [HttpStatusCode.Ok, MockData.HISTORY_LIST];
    });

    /**
     * 获取猜你想搜
     */
    adapter.onGet(URL_MAP.GET_GUESS_LIKE_LIST).reply((config: AxiosRequestConfig) => {
      const params: boolean = config?.params.isRefresh;
      MockApi._refreshTimes = params ? (MockApi._refreshTimes + 1) : MockApi._refreshTimes;
      if (MockApi._refreshTimes % 2) {
        return [HttpStatusCode.Ok, MockData.RECOMMEND_LIST.slice(0, 6)];
      } else {
        return [HttpStatusCode.Ok, MockData.RECOMMEND_LIST.slice(-6)];
      }
    });

    /**
     * 获取搜索结果
     */
    adapter.onGet(URL_MAP.GET_RESULT_LIST).reply((config: AxiosRequestConfig) => {
      const params: ISearchResultParams = config?.params;
      let content = '';
      switch (params.searchSource) {
        case SearchSource.USER_INPUT:
          content = params.keyWord as string;
          break;
        case SearchSource.HISTORY:
        case SearchSource.SUGGESTION:
        case SearchSource.RECOMMEND:
          content = (params.keyWord as SearchWordItem).content;
          break;
        default:
          content = (params.keyWord as SearchItem).title;
          break;
      }
      MockApi.addHistoryList(content);
      const result: FilterTagAndList = {
        label: 'goods',
        id: 'goods',
        itemList: MockApi.findSearchResult(content),
      };
      return [HttpStatusCode.Ok, [result]];
    });

    /**
     * 获取搜索联想
     */
    adapter.onGet(URL_MAP.GET_SUGGESTION_LIST).reply((config: AxiosRequestConfig) => {
      const params: string = config?.params.keyWord;
      if (!params) {
        return [HttpStatusCode.Ok, []];
      }
      const suggestions: ISearchWordItem[] = [];
      let content: Set<string> = new Set();
      const category = MockData.ALL_CATEGORY_SERVICES.find(v => v.categoryLabel.includes(params));
      MockData.ALL_GOOD_LIST.map(v => {
        if (v.classId === category?.categoryId) {
          content.add(v.classId);
        }
        if (v.title.includes(params)) {
          content.add(v.title);
        }
        if (v.subTitle.includes(params)) {
          content.add(v.subTitle);
        }
      });
      content.forEach((value) => suggestions.push({ content: value, id: `001-${value}` }));
      return [HttpStatusCode.Ok, [suggestions, [params]]];
    });
  }
}
