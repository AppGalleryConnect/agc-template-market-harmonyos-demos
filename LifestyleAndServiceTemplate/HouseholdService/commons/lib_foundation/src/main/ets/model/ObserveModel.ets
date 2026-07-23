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
import { IGoodCategory, IGoodInfo, } from 'module_base';
import { IJumpCategoryParam, OrderStatus } from '../common/Constant';
import { IFullOrderInfo, IHomeInfo, IUserInfo, } from './IResponse';

// 系统的分享参数模型
export interface ShareInfo {
  showShareMenu: boolean; // 当前页面是否允许分享，面板分享开关是否打开, 不填默认为不允许
  title?: string; // 系统分享面板标题，默认为元服务名称
  description?: string; // 系统分享面板简介，默认为元服务一句话描述
  previewUri?: string; // 分享图片缩略图，为本地文件uri，预留字段，不起作用
  parameters?: Object; // 开发者自定参数
  preview?: string; // 分享缩略图的base64编码，大小限制在32kb，太大会导致分享按钮置灰
}

/**
 * 服务卡片列表item模型
 */
export class FormItemModel {
  goodId: string
  orderId: string
  title: string
  appointTime: string
  addressName: string
  isShow: boolean
  subTitle?: string
  appointTimeRaw: number

  constructor(goodId: string, orderId: string, title: string, appointTime: string, addressName: string,
    isShow: boolean = true, appointTimeRaw: number = 0) {
    this.goodId = goodId;
    this.orderId = orderId;
    this.title = title;
    this.appointTime = appointTime;
    this.addressName = addressName;
    this.isShow = isShow;
    this.appointTimeRaw = appointTimeRaw;
  }
}

/**
 * 服务卡片-数据模型
 */
export class FormCardData {
  data: string = '';
}

/**
 * 服务卡片-跳转模型
 */
@ObservedV2
export class FormCardRouter {
  @Trace id: number = 0;
  @Trace pageUrl: string = '';
  @Trace orderId: string = '';
  @Trace goodId: string = '';
  @Trace categoryParam: IJumpCategoryParam = {
    tabIndex: 1,
    listInitialIndex: 0
  };
}

/**
 * 分享参数模型
 */
@ObservedV2
export class CustomShareParams {
  @Trace id: number = 0;
  @Trace pageName: string = '';
  @Trace goodId: string = '';
  @Trace goodName: string = '';
}

/**
 * 扫码直达/AppLink跳转参数
 */
@ObservedV2
export class CustomLinkModel {
  @Trace id: number = 0;
  @Trace pageUrl: string = '';
  @Trace goodName: string = '';
}

@ObservedV2
export class SimpleGoodInfo {
  @Trace id: string = '';
  @Trace title: string = '';
  @Trace subTitle?: string = '';
  @Trace vipPrice: number = 0;
  @Trace image: string = '';
}

@ObservedV2
export class FullOrderInfo implements IFullOrderInfo {
  // 订单ID
  @Trace id: string = '';
  // 订单标题
  @Trace title: string = '';
  // 订单副标题
  @Trace subTitle?: string = '';
  // 会员价格
  @Trace vipPrice: number = 0;
  // 图片链接
  @Trace image: string = '';
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
  // 是否订阅推送
  @Trace setSubscription: boolean = false;
  // 是否添加日程
  @Trace setSchedule: boolean = false;
  // 日程id
  @Trace calendarId?: number;
}

@ObservedV2
export class OrderToPayParam {
  @Trace orderInfo: FullOrderInfo = new FullOrderInfo();
  @Trace isFromOrderCard: boolean = false;
}


@ObservedV2
export class OrderDetailList {
  @Trace list: FullOrderInfo[] = [];
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
export class LinkState {
  @Trace isLink: boolean = false;
}

@ObservedV2
export class ClickId {
  @Trace clickId: number = 0;
}

@ObservedV2
export class OpenId {
  @Trace openId: string = '';
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
  static openId: OpenId = AppStorageV2.connect(OpenId, () => new OpenId())!;
  static linkState: LinkState = AppStorageV2.connect(LinkState, () => new LinkState())!;
  static clickId: ClickId = AppStorageV2.connect(ClickId, () => new ClickId())!;
  static userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  static homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  static allCategoryList: IGoodCategory[] = [];
  static recentVisitList: RecentVisitList = AppStorageV2.connect(RecentVisitList, () => new RecentVisitList())!;
  static jumpCategoryParam: JumpCategoryParam = AppStorageV2.connect(JumpCategoryParam, () => new JumpCategoryParam())!;

  static setLinkState(status: boolean) {
    AppStorageBank.linkState.isLink = status;
  }

  static setOpenId(id: string) {
    AppStorageBank.openId.openId = id;
  }

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

  static updateRecentVisitList(newCity: string) {
    const existIndex = AppStorageBank.recentVisitList.list.findIndex(v => v.includes(newCity));
    if (existIndex !== -1) {
      AppStorageBank.recentVisitList.list.splice(existIndex, 1);
    }
    AppStorageBank.recentVisitList.list.splice(0, 0, newCity);
  }

  static updateJumpCategoryParam(param: IJumpCategoryParam) {
    AppStorageBank.clickId.clickId = (AppStorageBank.clickId.clickId + 1) % 101;
    AppStorageBank.jumpCategoryParam.tabIndex = param.tabIndex;
    AppStorageBank.jumpCategoryParam.listInitialIndex = param.listInitialIndex;
  }
}


