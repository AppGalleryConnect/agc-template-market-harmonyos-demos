export interface RoomFeatureModel {
  value: number;
  title: string;
}

export interface KeyWordModel {
  keyId: number;
  rank: number;
  value: string;
  type: string;
  color: string;
}

export interface CustomerServiceModel {
  key: number,
  ask: string,
  answer: string,
}

export interface CommodityFeatureModel {
  value: number;
  title: string;
}

export interface OtherTabNavModel {
  index: number;
  page: string;
}

export interface OrderTextModel {
  value: number;
  title: string;
  icon: string;
}

export interface Member {
  name: string;
  value: number;
}

export enum OrderTabBarType {
  ALL = 0,
  TO_PAY = 1,
  TO_USE = 2,
  CANCEL = 3,
  READY = 4
}

export enum NavPathName {
  RESERVE = 'Reserve',
  PURCHASE = 'Purchase',
  QUICK_LOGIN_PAGE = 'QuickLoginPage',
  COMMODITY_DETAIL = 'CommodityDetail',
  PAY_SUCCESS = 'PaySuccess',
  ADD_GUEST = 'AddGuest',
  COMMODITY_LIST = 'CommodityList',
  ROOMS = 'Rooms',
  HOTEL_DETAIL = 'HotelDetail',
  PAGE_DETAIL = 'PageDetail',
  ROOM_ORDER_DETAIL = 'RoomOrderDetail',
  COMMODITY_ORDER_DETAIL = 'CommodityOrderDetail',
  TERMS_OF_SERVICE_PAGE = 'TermsOfServicePage',
  PRIVACY_POLICY_PAGE = 'PrivacyPolicyPage',
  ORDER_LIST = 'OrderList',
  PERSONAL_INFO = 'PersonalInfo',
  GUESTS = 'Guests',
  HOTEL = 'Hotel',
}

export class Constants {
  static readonly MONTHS = 12;
  static readonly JANUARY = 1;
  static readonly WEEK_NUMBER = 7;
  static readonly TRANSITION_DURATION = 200;
  static readonly MAX_TO_PAY_TIME: number = 900000;
  static readonly MODE: string = 'MOCK';
  static readonly RECOMMEND_GOODS_COUNT: number = 3;
  static readonly BRAND_TORY_COUNT: number = 3;
  static readonly HOT_SCENIC_SPOT_CATEGORY_COUNT: number = 5;
  static readonly RECOMMEND_SCENIC_SPOT_CATEGORY_COUNT: number = 5;
  static readonly FULL_SCREEN: string = '100%';
  static readonly HALF_SCREEN: string = '50%';
  static readonly CALENDAR_CLOSE_TRANSITION_DURATION = 200;
  static readonly OTHER_NAV_TABLE: Array<OtherTabNavModel> = [
    {
      index: 0,
      page: 'Customer',
    },
    {
      index: 1,
      page: 'Guests',
    },
    {
      index: 2,
      page: 'Complaint',
    },
    {
      index: 3,
      page: 'About',
    },
    {
      index: 4,
      page: 'PersonalInfo',
    },
  ];
  static readonly commodityFeatureTab: Array<CommodityFeatureModel> = [
    {
      value: 0,
      title: '详情',
    },
    {
      value: 1,
      title: '须知',
    },
  ];

  static readonly COMMON_SERVICE_INFO: Array<OrderTextModel> = [
    {
      value: 0,
      title: '常见问题',
      icon: 'app.media.icon_my_question',
    },
    {
      value: 1,
      title: '常用旅客',
      icon: 'app.media.icon_my_passenger',
    },
    {
      value: 2,
      title: '投诉建议',
      icon: 'app.media.icon_my_recommendatio',
    },
    {
      value: 3,
      title: '关于我们',
      icon: 'app.media.icon_my_about',
    },
  ];
  static readonly MEMBER_LIST: Array<Member> = [
    {
      name: '积分',
      value: 0,
    },
    {
      name: '优惠券',
      value: 0,
    },
    {
      name: '预售券',
      value: 0,
    },
  ];
  static readonly roomFeatureTab: Array<RoomFeatureModel> = [
    {
      value: 0,
      title: '预订',
    },
    {
      value: 1,
      title: '简介',
    },
    {
      value: 2,
      title: '须知',
    },
  ];
  static readonly orderText: Array<OrderTextModel> = [
    {
      value: 0,
      title: '全部订单',
      icon: 'app.media.icon_my_order1',
    },
    {
      value: 1,
      title: '待付款',
      icon: 'app.media.icon_my_order2',
    },
    {
      value: 2,
      title: '待使用',
      icon: 'app.media.icon_my_order3',
    },
    {
      value: 3,
      title: '已取消',
      icon: 'app.media.icon_my_order4',
    },
    {
      value: 4,
      title: '已完成',
      icon: 'app.media.icon_my_order5',
    },
  ];
}