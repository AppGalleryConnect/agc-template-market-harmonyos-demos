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

import { InternalAxiosRequestConfig } from '@ohos/axios';
import { OrderStatus, QueryGoodListSource } from '../common/Constant';
import { CommonUtils } from '../common/Utils';
import {
  IQueryOrderList,
  IOrderUpdate,
  ISubmitOrderRequest,
  IUpdateCity,
  IQueryGood,
  IQueryAddr,
  IQueryGoodList,
} from '../model/IRequest';
import { IGoodInfo, IUserInfo, IAddrInfo, IOrderDetail, IGoodCategory } from '../model/IResponse';
import { FullOrderInfo } from '../model/ObserveModel';
import { MockData } from './MockData';

export class MockApi {
  static subIndex: number = 0;
  static myOrderList: IOrderDetail[] = [];

  static loginWithHuaweiID() {
    return MockData.LOGIN_RESP;
  }

  static getUserInfo(): IUserInfo {
    return MockData.USER_INFO;
  }

  static updateUserInfo(config?: InternalAxiosRequestConfig) {
    const data: IUserInfo = JSON.parse(config?.data ?? '{}') as IUserInfo;
    CommonUtils.assign(MockData.USER_INFO, data);
    return true;
  }

  static getHomeInfo() {
    const bannerGoodIdList: string[] = ['home_clean_banner1', 'window_clean_banner2'];
    MockData.HOME_INFO.bannerGoods = bannerGoodIdList.map((v: string) => {
      return MockData.ALL_GOOD_LIST.find((item) => item.id === v)!;
    })
    return MockData.HOME_INFO;
  }

  static updateCitySelected(config?: InternalAxiosRequestConfig) {
    const data: IUpdateCity = JSON.parse(config?.data ?? '{}') as IUpdateCity;
    MockData.HOME_INFO.citySelected = data.city;
    return true;
  }

  static updateCurrentCity(config?: InternalAxiosRequestConfig) {
    const data: IUpdateCity = JSON.parse(config?.data ?? '{}') as IUpdateCity;
    MockData.HOME_INFO.currentCity = data.city;
    return true;
  }

  static getAllCategoryServices() {
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
    return MockData.ALL_CATEGORY_SERVICES;
  }

  static getGoodList(config?: InternalAxiosRequestConfig): IGoodInfo[] {
    const params: IQueryGoodList = config?.params;
    // 存在搜索词的场景
    if (params.source === QueryGoodListSource.SEARCH) {
      const category = MockData.ALL_CATEGORY_SERVICES.find(v => v.categoryLabel.includes(params.keyword));
      return MockData.ALL_GOOD_LIST.filter(v => {
        if (v.classId === category?.categoryId) {
          return true;
        }
        if (v.title.includes(params.keyword)) {
          return true;
        }
        if (v.subTitle.includes(params.keyword)) {
          return true;
        }
        if (JSON.stringify(v.serviceContentList).includes(params.keyword)) {
          return true;
        }
        if (JSON.stringify(v.feeList).includes(params.keyword)) {
          return true;
        }
        return false;
      })
    }

    if (params.source === QueryGoodListSource.MINE) {
      const COUNT = 8;
      const list = MockData.ALL_GOOD_LIST.slice(4, 4 + COUNT);
      list.forEach((v) => {
        v.subIndex = MockApi.subIndex++;
      });
      return list;
    }

    const list = MockData.ALL_GOOD_LIST.slice();
    list.forEach((v) => {
      v.subIndex = MockApi.subIndex++;
    });

    return list;
  }

  static getGood(config?: InternalAxiosRequestConfig): IGoodInfo | undefined {
    const params: IQueryGood = config?.params;
    const item = MockData.ALL_GOOD_LIST.find(v => v.id === params.goodId);
    return item;
  }

  static getAddressList(): IAddrInfo[] {
    return MockData.ADDRESS_LIST;
  }

  static getAddress(config?: InternalAxiosRequestConfig): IAddrInfo | undefined {
    const params: IQueryAddr = config?.params;
    return MockData.ADDRESS_LIST.find(v => v.id === params.addrId);
  }

  static updateAddress(config?: InternalAxiosRequestConfig) {
    const data: IAddrInfo = JSON.parse(config?.data ?? '{}') as IAddrInfo;
    const target = MockData.ADDRESS_LIST.find(v => v.id === data.id);
    if (target) {
      CommonUtils.assign(target, data);
    }
    return true;
  }

  static deleteAddress(config?: InternalAxiosRequestConfig) {
    const data: IQueryAddr = JSON.parse(config?.data ?? '{}') as IQueryAddr;
    const targetIndex = MockData.ADDRESS_LIST.findIndex(v => v.id === data.addrId);
    if (targetIndex !== -1) {
      MockData.ADDRESS_LIST.splice(targetIndex, 1);
    }
    return true;
  }

  static addAddress(config?: InternalAxiosRequestConfig) {
    const data: IAddrInfo = JSON.parse(config?.data ?? '{}') as IAddrInfo;
    data.id = new Date().getTime();
    MockData.ADDRESS_LIST.splice(0, 0, data);
    return true;
  }

  static buildOrderFullInfo(orderInfo: IOrderDetail): FullOrderInfo {
    const goodInfo = MockData.ALL_GOOD_LIST.find(v => v.id === orderInfo.goodId)!;
    const fullInfo = new FullOrderInfo();
    fullInfo.id = goodInfo.id;
    fullInfo.title = goodInfo.title;
    fullInfo.subTitle = goodInfo.subTitle;
    fullInfo.vipPrice = goodInfo.vipPrice;
    fullInfo.image = goodInfo.image;
    fullInfo.addressName = `${orderInfo.addressName} ${orderInfo.addressStr}`;
    fullInfo.contactPhone = orderInfo.contactPhone;
    fullInfo.appointTime = orderInfo.appointTime;
    fullInfo.remark = orderInfo.remark;
    fullInfo.actualPay = orderInfo.actualPay;
    fullInfo.orderId = orderInfo.orderId;
    fullInfo.status = orderInfo.status;
    fullInfo.orderTime = orderInfo.orderTime;
    fullInfo.payTime = orderInfo.payTime;
    fullInfo.consumeTime = orderInfo.consumeTime;
    fullInfo.refundTime = orderInfo.refundTime;
    return fullInfo;
  }

  static getOrderList(config?: InternalAxiosRequestConfig) {
    const params: IQueryOrderList = config?.params;
    return MockApi.myOrderList.filter((v: IOrderDetail) => {
      if (params.status === OrderStatus.ALL) {
        return true;
      }
      if (params.status === OrderStatus.REFUND) {
        return [OrderStatus.REFUND_ING, OrderStatus.REFUND_DONE].includes(v.status);
      }
      return params.status === v.status;
    }).map((item) => {
      return MockApi.buildOrderFullInfo(item);
    });
  }

  static getOrder(config?: InternalAxiosRequestConfig) {
    const params: IOrderUpdate = config?.params;
    const item = MockApi.myOrderList.find(v => v.orderId === params.orderId)!;
    return MockApi.buildOrderFullInfo(item);
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
    };

    return myOrder;
  }

  static preOrder(config?: InternalAxiosRequestConfig) {
    const data: ISubmitOrderRequest = JSON.parse(config?.data ?? '{}') as ISubmitOrderRequest;
    const myOrder = MockApi.generateOrder(data);
    MockApi.myOrderList.splice(0, 0, myOrder);
    return myOrder.orderId;
  }

  static payOrder(config?: InternalAxiosRequestConfig) {
    const data: IOrderUpdate = JSON.parse(config?.data ?? '{}') as IOrderUpdate;
    const item = MockApi.myOrderList.find(v => v.orderId === data.orderId);
    if (item) {
      item.status = OrderStatus.TO_USE;
      item.payTime = new Date().getTime();
      setTimeout(() => {
        if (item.status === OrderStatus.TO_USE) {
          item.status = OrderStatus.NORMAL_FINISH;
          item.consumeTime = new Date().getTime();
        }
      }, 1000 * 60);
    }
    return true;
  }

  static refund(config?: InternalAxiosRequestConfig) {
    const data: IOrderUpdate = JSON.parse(config?.data ?? '{}') as IOrderUpdate;
    const item = MockApi.myOrderList.find(v => v.orderId === data.orderId);
    if (item) {
      item.status = OrderStatus.REFUND_ING;

      setTimeout(() => {
        item.status = OrderStatus.REFUND_DONE;
        item.refundTime = new Date().getTime();
      }, 1000 * 60);
    }
    return true;
  }

  static cancelOrder(config?: InternalAxiosRequestConfig) {
    const data: IOrderUpdate = JSON.parse(config?.data ?? '{}') as IOrderUpdate;
    const item = MockApi.myOrderList.find(v => v.orderId === data.orderId);
    if (item) {
      item.status = OrderStatus.CANCEL;
    }
    return true;
  }
}