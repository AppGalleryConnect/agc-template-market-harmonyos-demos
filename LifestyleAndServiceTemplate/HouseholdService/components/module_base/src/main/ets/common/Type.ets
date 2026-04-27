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

import { IntroType, TypeGood } from '../common/Constant';

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

/**
 * 服务基本单元
 */
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
