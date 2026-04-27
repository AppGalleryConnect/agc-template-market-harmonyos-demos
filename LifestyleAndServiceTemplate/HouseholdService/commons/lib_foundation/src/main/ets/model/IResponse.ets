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

import { IGoodInfo } from 'module_base';
import { OrderStatus } from '../common/Constant';

/**
 * 静默登录请求响应
 */
export interface LoginWithHuaweiIDResp {
  token: string;
  userId: string;
}

/**
 * 绑定手机号响应
 */
export interface BindMobileWithCodeResp {
  status: string;
  rebindSecret: string;
}

/**
 * 用户信息模型
 */
export interface IUserInfo {
  // id
  userId: number;

  // 昵称
  nickName?: string;

  // 头像
  avatar?: string;

  // 姓名
  name?: string;

  // 性别
  gender?: number;

  // 手机号码
  mobile?: string;

  // 生日
  birth?: number;
}

/**
 * 订单信息
 */
export interface IFullOrderInfo {
  // 订单ID
  id: string;

  // 订单标题
  title: string;

  // 订单副标题
  subTitle?: string;

  // 会员价格
  vipPrice: number;

  // 图片链接
  image: string;

  // 预约地址
  addressName: string;

  // 手机号
  contactPhone: string;

  // 预约时间
  appointTime: number;

  // 备注信息
  remark: string;

  // 实际付款
  actualPay: number;

  // 订单ID
  orderId: string;

  // 订单状态
  status: OrderStatus;

  // 下单时间
  orderTime: number;

  // 付款时间
  payTime?: number;

  // 使用时间
  consumeTime?: number;

  // 退款时间
  refundTime?: number;

  // 是否订阅推送
  setSubscription: boolean;

  // 是否添加日程
  setSchedule: boolean;

  // 日程id
  calendarId?: number;
}

/**
 * 首页包含的聚合信息
 */
export interface IHomeInfo {
  // 当前定位城市
  currentCity: string;

  // 当前所选的城市
  citySelected: string;

  // 热线电话
  hotline: string;

  // 官网地址
  officialWebsite: string;

  // 轮播商品
  bannerGoods: IGoodInfo[];
}

/**
 * 历史、猜你想搜、联想词条
 */
export interface ISearchWordItem {
  content: string;
  id: number | string;
}

/**
 * 订单详情
 */
export interface IOrderDetail {
  // 订单id
  orderId: string;

  // 商品id
  goodId: string;

  // 地址名称
  addressName: string;

  // 地址详细
  addressStr: string;

  // 联系人姓名
  contactName: string;

  // 联系电话
  contactPhone: string;

  // 预约时间
  appointTime: number;

  // 备注
  remark: string;

  // 订单状态
  status: OrderStatus;

  // 实际付款
  actualPay: number;

  // 下单时间
  orderTime: number;

  // 付款时间
  payTime?: number;

  // 使用时间
  consumeTime?: number;

  // 退款时间
  refundTime?: number;

  // 是否订阅推送
  setSubscription: boolean;

  // 是否添加日程
  setSchedule: boolean;

  // 日程id
  calendarId?: number;
}
