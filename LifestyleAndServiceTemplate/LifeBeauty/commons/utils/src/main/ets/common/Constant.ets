/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

/**
 * 服务端请求的基础url
 */
export const BASE_URL = '';


/**
 * 和元服务本身相关的信息
 */
export enum CurAppInfo {
  CLIENT_ID = 'xxx', // client_id
  PUSH_TEMPLATE_ID = 'xxx', // 推送，服务通知模板id
  BUNDLE_NAME = 'com.atomicservice.xxx', // 包名
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
 * Common constants
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
  // Skeleton animation config
  static readonly SKELETON_ANIMATION: AnimateParam = {
    duration: 400,
    tempo: 0.6,
    curve: Curve.EaseInOut,
    delay: 200,
    iterations: -1,
    playMode: PlayMode.Alternate,
  }
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
  REFRESH_TOKEN = '/api/hw-atomic/refreshToken',
  BIND_MOBILE_WITH_CODE = '/api/hw-atomic/bindMobileWithCode',
  CONFIRM_REBIND_MOBILE = '/api/hw-atomic/confirmRebindMobileWithSecret',
  GET_USER_INFO = '/api/hw-atomic/getUserInfo',
  UNBIND_MOBILE = '/api/hw-atomic/unbindMobile',
  GET_STORE_INFO = '/api/metaservice/storeInfo',
  GET_STORE_LIST = '/api/metaservice/store/list',
  GET_GOOD_LIST = '/api/metaservice/goods/list',
  GET_APPOINTMENT_LIST = '/api/metaservice/reserv/list',
  CREATE_APPOINTMENT_INFO = '/api/metaservice/reserv/create',
  UPDATE_APPOINTMENT_INFO = '/api/metaservice/reserv/update',
  CANCEL_APPOINTMENT = '/api/metaservice/reserv/cancel',
  ACTIVE_MEMBER_CARD = '/api/metaservice/active/member',
  GET_SINGLE_VISIT_CARD_LIST = '/api/metaservice/card/list',
  GET_GROUP_LIST = '/api/metaservice/group/list',
  PRE_ORDER = '/api/metaservice/order',
  GET_MY_SINGLE_VISIT_CARD_LIST = '/api/metaservice/card/list/buy',
  GET_MY_GROUP_LIST = '/api/metaservice/group/list/buy',
  REFUND_GROUP = '/api/metaservice/group/refund',
}
;

/**
 * 预约状态
 */
export enum AppointState {
  NEW = 10,
  FINISH = 30,
  CANCEL = 40,
  OVER_TIME = 50,
}

/**
 * 团购订单的状态
 */
export enum GroupOrderStatus {
  AVAILABLE = 0,
  USE_UP = 1,
  REFUND = 2,
}

/**
 * 详情中富文本类型
 */
export enum IntroType {
  IMAGE = 'image',
  TEXT = 'text',
}

/**
 * 下单类型，团购/次卡
 */
export enum OrderType {
  SINGLE_CARD = 'single_card',
  GROUP = 'group',
}

// 手机号正则
export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;