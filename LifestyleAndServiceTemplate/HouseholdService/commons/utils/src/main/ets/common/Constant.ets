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

import { RouterMap } from '../router/RouterModule';

/**
 * 和元服务本身相关的信息
 */
export enum CurAppInfo {
  BASE_URL = '', // 服务端请求基础url
}

/**
 * AppStorage应用临时缓存映射表
 */
export enum AppStorageMap {
  TOKEN = 'Token',
  CONTEXT = 'Context',
  UI_CONTEXT = 'uiContext',
}

/**
 * 订单状态
 */
export enum OrderStatus {
  ALL = '全部',
  TO_PAY = '待付款',
  TO_USE = '待使用',
  NORMAL_FINISH = '已完成',
  REFUND = '退款标识',
  REFUND_ING = '退款中',
  REFUND_DONE = '已退款',
  CANCEL = '已取消',
}

export enum TypeGood {
  PAY = 1,
  CONSULT = 2,
}

export interface IMenuItem {
  imgUrl: ResourceStr;
  textLabel: string;
  tabLabel?: string;
  routerUrl?: string;
  status?: OrderStatus;
  mainParam?: IJumpCategoryParam;
}

/**
 * 查询商品列表的页面来源
 */
export enum QueryGoodListSource {
  HOME = 0,
  MINE = 1,
  SEARCH = 2,
}

/**
 * 详情中富文本类型
 */
export enum IntroType {
  IMAGE = 'image',
  TEXT = 'text',
}

/**
 * 跳转main页面的参数
 */
export interface IJumpCategoryParam {
  tabIndex: number;
  listInitialIndex: number;
}

/**
 * 跳转地址管理的参数
 */
export interface IJumpAddrParam {
  selectedId?: number;
  needOnPop?: boolean;
}

export const MENU_LIST: IMenuItem[] = [
  {
    imgUrl: $r('app.media.ic_home_daily'),
    textLabel: '日常清洁',
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 1,
    },
  },
  {
    imgUrl: $r('app.media.ic_repair'),
    textLabel: '家电维修',
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 4,
    },
  },
  {
    imgUrl: $r('app.media.ic_baby'),
    textLabel: '保姆月嫂',
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 2,
    },
  },
  {
    imgUrl: $r('app.media.ic_home_pipe'),
    textLabel: '管道疏通',
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 3,
    },
  },
];

export const MY_ORDER_LIST: IMenuItem[] = [
  {
    imgUrl: $r('app.media.ic_mine_whole_order'),
    textLabel: '全部订单',
    tabLabel: '全部',
    status: OrderStatus.ALL,
  },
  {
    imgUrl: $r('app.media.ic_mine_to_pay'),
    textLabel: '待付款',
    status: OrderStatus.TO_PAY,
  },
  {
    imgUrl: $r('app.media.ic_mine_to_use'),
    textLabel: '待使用',
    status: OrderStatus.TO_USE,
  },
  {
    imgUrl: $r('app.media.ic_mine_refund'),
    textLabel: '退款售后',
    status: OrderStatus.REFUND,
  },
];

export const MY_TOOL_LIST: IMenuItem[] = [
  {
    imgUrl: $r('app.media.ic_location'),
    textLabel: '地址管理',
    routerUrl: RouterMap.ADDRESS_MANAGE,
  },
  {
    imgUrl: $r('app.media.ic_call'),
    textLabel: '公共服务',
    routerUrl: RouterMap.COMMON_SERVICE,
  },
];

/**
 * 性别常量
 */
export const GENDER_OPTIONS: string[] = ['男', '女'];

/**
 * 常量类
 */
export class CommonConstants {
  // Font weight
  static readonly DIALOG_TITLE_FONT_WEIGHT: number = 700;
  static readonly DIALOG_BUTTON_FONT_WEIGHT: number = 500;
  static readonly NORMAL_FONT_WEIGHT: number = 400;
  // Opacity
  static readonly FIRST_LEVEL_OPACITY: number = 0.9;
  static readonly SECOND_LEVEL_OPACITY: number = 0.6;
  static readonly HALF_OPACITY: number = 0.5;
  static readonly THIRD_LEVEL_OPACITY: number = 0.3;
  // Blur
  static readonly REGULAR_BLUR: number = 250;
  // Space
  static readonly SPACE_4: number = 4;
  static readonly SPACE_8: number = 8;
  static readonly SPACE_12: number = 12;
  static readonly SPACE_16: number = 16;
  // MaxLines
  static readonly MAX_LINE_TWO: number = 2;
  // Column count
  static readonly SM_COLUMN_COUNT: number = 1;
  static readonly MD_COLUMN_COUNT: number = 2;
  static readonly LG_COLUMN_COUNT: number = 3;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  static readonly SIX_PERCENT: string = '60%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly NAVI_BAR_WIDTH: string = '40%';
}

/**
 * 华为账号登录错误码
 */
export enum ErrorCode {
  // The operation for obtaining the shipping address is canceled.
  SHIPPING_ADDRESS_USER_CANCELED = 1008100006,
  // Authorization revoking is performed.
  AUTHENTICATION_USER_CANCELED = 1001502012,
  // The operation for obtaining the invoice title is canceled.
  INVOICE_ASSISTANT_USER_CANCELED = 1010060001,
  // The operation for obtaining the avatar is canceled.
  EXTEND_SERVICE_USER_CANCELED = 1001600005,
  // A network exception occurred in the API for obtaining the shipping address.
  SHIPPING_ADDRESS_NETWORK_ERROR = 1008100002,
  // A network exception occurs in the authorization API.
  AUTHENTICATION_NETWORK_ERROR = 1001502005,
  // A network exception occurred in the API for obtaining the invoice title.
  INVOICE_ASSISTANT_NETWORK_ERROR = 1010060005,
  // A network exception occurred in the API for obtaining the avatar.
  EXTEND_SERVICE_NETWORK_ERROR = 1001600001
}

// url命名
export enum URL_MAP {
  LOGIN_WITH_HUAWEI_ID = '/api/hw-atomic/loginWithHuaweiID',
  GET_USER_INFO = '/api/hw-atomic/user/info',
  UPDATE_USER_INFO = '/api/hw-atomic/user/info/update',
  GET_HOME_INFO = '/api/hw-atomic/home/info',
  UPDATE_CITY_SELECTED = '/api/hw-atomic/city/selected/update',
  UPDATE_CITY_CURRENT = '/api/hw-atomic/city/current/update',
  GET_CATEGORY_INFO = '/api/hw-atomic/category/info',
  GET_ADDR_LIST = '/api/hw-atomic/addr/list',
  GET_ADDR = '/api/hw-atomic/addr/get',
  UPDATE_ADDR = '/api/hw-atomic/addr/update',
  ADD_ADDR = '/api/hw-atomic/addr/add',
  DELETE_ADDR = '/api/hw-atomic/addr/delete',
  ADD_ADDR_LIST = '/api/hw-atomic/addr/add',
  GET_GOOD_LIST = '/api/hw-atomic/goods/list',
  GET_GOOD = '/api/hw-atomic/good/detail/get',
  GET_ORDER_LIST = '/api/hw-atomic/order/list',
  GET_ORDER = '/api/hw-atomic/order/detail',
  PRE_ORDER = '/api/hw-atomic/pre/order',
  PAY_ORDER = '/api/hw-atomic/pay/order',
  REFUND = '/api/hw-atomic/group/refund',
  CANCEL_ORDER = '/api/hw-atomic/cancel/order',
}

// 手机号正则
export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;