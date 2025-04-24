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

import { IntroType, OrderStatus, TypeGood } from '../common/Constant';

/**
 * 静默登录请求响应
 */
export interface LoginWithHuaweiIDResp {
  token: string;
  userId: string;
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
 * 商品模型
 */
export interface IGoodInfo {
  // 商品ID
  id: string;

  // 商品类型
  type: TypeGood;

  // 所属类目ID
  classId: string;

  // 辅助标记
  subIndex?: number;

  // 商品名称
  title: string;

  // 副标题
  subTitle: string;

  // 主图
  image: string;

  // 详情富文本
  intro: IntroItem[];

  // 价格
  price: number;

  // 会员价
  vipPrice: number;

  // 已售出数量
  soldNum: number;

  // 服务内容
  serviceContentList: IContent[];

  // 服务选项
  serviceDetailList?: IServiceDetail[];

  // 服务流程
  servicePipeList: string[];

  // 费用说明
  feeList: string[];

  // 常见问题
  qaList: IQuestionAnswer[];
}

/**
 * 富文本单元
 */
export interface IntroItem {
  type: IntroType,
  value: string;
}

/**
 * 标题内容
 */
export interface IContent {
  title: string;
  content: string;
}

export interface IServiceDetailItem {
  desc: string;
  count: number;
  extraCount?: number;
  price: number;
}

/**
 * 服务详情
 */
export interface IServiceDetail {
  title: string;
  subTitle: string;
  prices: IServiceDetailItem[];
}

/**
 * 问答模型
 */
export interface IQuestionAnswer {
  question: string;
  answer: string;
}

/**
 * 商品分类
 */
export interface IGoodCategory {
  categoryId: string;
  categoryLabel: string;
  list: IGoodInfo[];
}

/**
 * 地址信息
 */
export interface IAddrInfo {
  id?: number;
  name: string;
  address: string;
  contactName: string;
  contactPhone: string;
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
}
