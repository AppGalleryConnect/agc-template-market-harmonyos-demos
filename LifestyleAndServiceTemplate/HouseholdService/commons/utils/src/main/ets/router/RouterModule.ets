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

import { Logger } from '../common/Logger';

export enum RouterMap {
  // 入口
  MAIN = 'Main', // 元服务主页面

  // 首页模块
  CITY_LIST = 'CityList', // 城市选择页面
  SEARCH_PAGE = 'SearchPage', // 搜索页面
  GOOD_DETAIL = 'GoodDetail', // 商品详情页
  ORDER_PAGE = 'OrderPage', // 下单页
  TO_PAY = 'ToPay', // 提交订单页
  SUCCESS_PAY = 'SuccessPay', // 下单成功页

  // 全部服务模块
  ALL_CATEGORY = 'AllCategory', // 分类页

  // 我的模块
  MY_ORDER_LIST = 'MyOrderList', // 订单管理页面（包含全部、待付款、已完成、退款售后）
  MY_ORDER_DETAIL = 'MyOrderDetail', // 订单详情
  EDIT_PERSONAL = 'EditPersonal', // 编辑个人信息页面
  COMMON_SERVICE = 'CommonService', // 公共服务
  OFFICIAL_WEB = 'OfficialWeb', // 官网web

  // 地址管理模块
  ADDRESS_MANAGE = 'AddressManage', // 地址管理页面
  EDIT_ADDRESS = 'EditAddress', // 新增/编辑地址页面
}

export interface NavRouterInfo {
  url: string, // 需要跳转的路由名
  mode?: NavDestinationMode, // NavDestination类型
  param?: Object, // 跳转传参
  onPop?: Callback<PopInfo>; // 用于页面出栈触发的回调
  animated?: boolean, // 是否支持转场动画
}

export class RouterModule {
  public static stack: NavPathStack = new NavPathStack()
  public static urlMap: Record<string, string> = {}

  public static getStack(): NavPathStack {
    return RouterModule.stack;
  }

  // 跳转到指定路由栈的指定路由页面
  public static push(info: NavRouterInfo) {
    try {
      RouterModule.stack.pushPathByName(info.url, info.param, info.onPop, info.animated);
    } catch (err) {
      Logger.info('navigation stack push failed::' + JSON.stringify(err));
    }
  }

  // 将指定路由栈的栈顶页面退出，将info指定的NavDestination页面信息入栈
  public static replace(info: NavRouterInfo) {
    try {
      RouterModule.stack.replacePathByName(info.url, info.param);
    } catch (err) {
      Logger.info('navigation stack replace failed::' + JSON.stringify(err));
    }
  }

  // 弹出栈顶元素
  public static pop(result?: Object, animated?: boolean) {
    try {
      RouterModule.stack.pop(result, animated);
    } catch (err) {
      Logger.info('navigation stack pop failed::' + JSON.stringify(err));
    }
  }

  // 回退路由栈到由栈底开始第一个名为name的NavDestination页面
  public static popToName(name: string, animated?: boolean) {
    try {
      RouterModule.stack.popToName(name, animated);
    } catch (err) {
      Logger.info('navigation stack pop to name failed::' + JSON.stringify(err));
    }
  }

  // 清除栈中的所有页面
  public static clear(animated?: boolean) {
    try {
      RouterModule.stack.clear(animated)
    } catch (err) {
      Logger.info('navigation stack clear failed::' + JSON.stringify(err))
    }
  }

  // 获取指定栈中指定页面的参数
  public static getNavParam<T>(info: NavRouterInfo): T[] {
    let params: T[] = [];
    try {
      params = RouterModule.stack.getParamByName(info.url) as T[];
    } catch (err) {
      Logger.info('navigation stack get params failed::' + JSON.stringify(err));
    }
    return params;
  }

  // 获取栈大小
  public static size() {
    return RouterModule.stack.size();
  }
}