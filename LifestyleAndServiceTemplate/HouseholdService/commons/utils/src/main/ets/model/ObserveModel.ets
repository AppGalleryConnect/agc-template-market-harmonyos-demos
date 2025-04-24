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
import { AppStorageV2 } from '@kit.ArkUI';
import { IJumpCategoryParam, OrderStatus, TypeGood } from '../common/Constant';
import {
  IAddrInfo,
  IContent,
  IGoodCategory,
  IGoodInfo,
  IHomeInfo,
  IntroItem,
  IQuestionAnswer,
  IServiceDetail,
  IUserInfo,
} from './IResponse';

@ObservedV2
export class SimpleGoodInfo {
  @Trace id: string = '';
  @Trace title: string = '';
  @Trace subTitle?: string = '';
  @Trace vipPrice: number = 0;
  @Trace image: string = '';
}

@ObservedV2
export class FullOrderInfo extends SimpleGoodInfo {
  // 预约地址
  @Trace addressName: string = '';
  // 手机号
  @Trace contactPhone: string = '';
  // 预约时间
  @Trace appointTime: number = 0;
  // 备注信息
  @Trace remark: string = '';
  // 实际付款
  @Trace actualPay: number = 0;
  // 订单id
  @Trace orderId: string = '';
  // 订单状态
  @Trace status: OrderStatus = OrderStatus.ALL;
  // 下单时间
  @Trace orderTime: number = 0;
  // 付款时间
  @Trace payTime?: number;
  // 使用时间
  @Trace consumeTime?: number;
  // 退款时间
  @Trace refundTime?: number;
}

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

@ObservedV2
export class OrderDetailList {
  @Trace list: FullOrderInfo[] = [];
}

@ObservedV2
export class AddressInfo implements IAddrInfo {
  @Trace id?: number;
  @Trace name: string = '';
  @Trace address: string = '';
  @Trace contactName: string = '';
  @Trace contactPhone: string = '';
}

@ObservedV2
export class AddrList {
  @Trace list: AddressInfo[] = [];
}

/**
 * 读取用户信息响应
 */
@ObservedV2
export class UserInfo implements IUserInfo {
  @Trace userId: number = 0;
  @Trace nickName?: string;
  @Trace avatar?: string;
  @Trace mobile?: string;
  @Trace name?: string;
  @Trace gender?: number;
  @Trace birth?: number;
}

@ObservedV2
export class HomeBaseInfo implements IHomeInfo {
  @Trace currentCity: string = '';
  @Trace citySelected: string = '';
  @Trace hotline: string = '';
  @Trace officialWebsite: string = '';
  @Trace bannerGoods: IGoodInfo[] = [];
}

@ObservedV2
export class RecentVisitList {
  @Trace list: string[] = ['北京', '成都'];
}

@ObservedV2
export class JumpCategoryParam implements IJumpCategoryParam {
  @Trace tabIndex: number = 0;
  @Trace listInitialIndex: number = 0;
}

/**
 * AppStorageV2应用全局缓存库
 */
export class AppStorageBank {
  static userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  static homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  static allCategoryList: IGoodCategory[] = [];
  static addrList: AddrList = AppStorageV2.connect(AddrList, () => new AddrList())!;
  static recentVisitList: RecentVisitList = AppStorageV2.connect(RecentVisitList, () => new RecentVisitList())!;
  static jumpCategoryParam: JumpCategoryParam = AppStorageV2.connect(JumpCategoryParam, () => new JumpCategoryParam())!;

  static updateUserInfo(v: IUserInfo) {
    AppStorageBank.userInfo.userId = v.userId;
    AppStorageBank.userInfo.nickName = v.nickName;
    AppStorageBank.userInfo.avatar = v.avatar;
    AppStorageBank.userInfo.name = v.name;
    AppStorageBank.userInfo.gender = v.gender;
    AppStorageBank.userInfo.birth = v.birth;
    AppStorageBank.userInfo.mobile = v.mobile;
  }

  static setHomeBaseInfo(info: IHomeInfo) {
    AppStorageBank.homeBaseInfo.citySelected = info.citySelected;
    AppStorageBank.homeBaseInfo.hotline = info.hotline;
    AppStorageBank.homeBaseInfo.officialWebsite = info.officialWebsite;
    AppStorageBank.homeBaseInfo.bannerGoods = info.bannerGoods;
  }

  static setAllCategoryList(list: IGoodCategory[]) {
    AppStorageBank.allCategoryList = list;
  }

  static updateCitySelected(city: string) {
    AppStorageBank.homeBaseInfo.citySelected = city;
  }

  static updateCityCurrent(city: string) {
    AppStorageBank.homeBaseInfo.currentCity = city;
  }

  static updateAddrList(list: AddressInfo[]) {
    AppStorageBank.addrList.list = list;
  }

  static updateRecentVisitList(newCity: string) {
    const existIndex = AppStorageBank.recentVisitList.list.findIndex(v => v.includes(newCity));
    if (existIndex !== -1) {
      AppStorageBank.recentVisitList.list.splice(existIndex, 1);
    }
    AppStorageBank.recentVisitList.list.splice(0, 0, newCity);
  }

  static updateJumpCategoryParam(param: IJumpCategoryParam) {
    AppStorageBank.jumpCategoryParam.tabIndex = param.tabIndex;
    AppStorageBank.jumpCategoryParam.listInitialIndex = param.listInitialIndex;
  }
}


