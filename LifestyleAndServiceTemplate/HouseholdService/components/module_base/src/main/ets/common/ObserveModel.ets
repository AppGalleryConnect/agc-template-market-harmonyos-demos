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
import { TypeGood } from '../common/Constant';
import { IContent, IGoodInfo, IntroItem, IQuestionAnswer, IServiceDetail, } from './Type';

/**
 * 商品信息
 */
@ObservedV2
export class GoodInfo implements IGoodInfo {
  // 商品ID
  @Trace id: string = '';
  // 商品名称
  @Trace title: string = '';
  // 副标题
  @Trace subTitle: string = '';
  // 商品类型
  @Trace type: TypeGood = TypeGood.PAY;
  // 所属类目ID
  @Trace classId: string = '';
  // 主图
  @Trace image: string = '';
  // 详情富文本
  @Trace intro: IntroItem[] = [];
  // 价格
  @Trace price: number = 0;
  // 会员价
  @Trace vipPrice: number = 0;
  // 已售出数量
  @Trace soldNum: number = 0;
  // 服务内容
  @Trace serviceContentList: IContent[] = [];
  // 服务选项
  @Trace serviceDetailList?: IServiceDetail[] = [];
  // 服务流程
  @Trace servicePipeList: string[] = [];
  // 费用说明
  @Trace feeList: string[] = [];
  // 常见问题
  @Trace qaList: IQuestionAnswer[] = [];

  constructor(v?: GoodInfo) {
    this.id = v?.id || '';
    this.title = v?.title || '';
    this.subTitle = v?.subTitle || '';
    this.classId = v?.classId || '';
    this.image = v?.image || '';
    this.intro = v?.intro || [];
    this.price = v?.price || 0;
    this.vipPrice = v?.vipPrice || 0;
  }
}



