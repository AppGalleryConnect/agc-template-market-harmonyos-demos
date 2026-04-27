import { IAddrInfo, ISetting } from '../types'
import { util } from '@kit.ArkTS'

export interface IGoods {
  id: number,
  name: string,
  weight: number,
  volume?: number,
}

export enum RouterMap {
  ORDER_PAGE = 'OrderPage',
  EDIT_ORDER_PAGE = 'EditOrderPage',
  ORDER_INFO_PAGE = 'OrderInfoPage',
  EXPRESS_PAGE = 'ExpressPage',
  GOODS_PAGE = 'GoodsPage',
  TEMPLATE_PAGE = 'TemplatePage',
  PURCHASE_PAGE = 'PurchasePage',
  QUICK_LOGIN_PAGE = 'QuickLoginPage',
  PERSONAL_INFORMATION_PAGE = 'PersonalInformationPage',
  Edit_Name_Page = 'EditNamePage',
  Edit_Phone_Page = 'EditPhonePage',
  SETTING_PAGE = 'SettingPage',
  ADDRESS_PAGE = 'AddressPage',
  EDIT_ADDRESS_PAGE = 'EditAddressPage',
  TEMPLATE_LIST_PAGE = 'TemplateListPage',
  SERVICE_POINT_PAGE = 'ServicePointPage',
  PRIVACY_PAGE = 'PrivacyPage',
  REAL_NAME_AUTH_PAGE = 'RealNameAuthPage',
  ADDRESS_MANAGE_PAGE = 'AddressManagePage',
  ADDRESS_EDIT_PAGE = 'AddressEditPage',
  AGREE_PRIVACY_PAGE = 'AgreePrivacyPage',
  SAFE_PAGE = 'SafePage',
  MAIN_ENTRY = 'MainEntry',
}

/**
 * AppStorage应用临时缓存映射表
 */
export enum AppStorageMap {
  UI_CONTEXT = 'uiContext',
}

export enum TypeAddressPage {
  NEW = 1,
  EDIT = 2,
}

export enum OrderType {
  ALL = '全部',
  SEND = '寄快递',
  RECEIVE = '收快递',
}

export const goodsList: IGoods[] =
  [
    {
      id: 1,
      name: '文件',
      weight: 1
    },
    {
      id: 2,
      name: '衣服',
      weight: 1
    },
    {
      id: 3,
      name: '发票',
      weight: 1
    },
    {
      id: 4,
      name: '茶叶',
      weight: 1
    },
    {
      id: 5,
      name: '手机',
      weight: 1
    },
    {
      id: 6,
      name: '白酒',
      weight: 1
    },
    {
      id: 7,
      name: '行李',
      weight: 5
    },
    {
      id: 8,
      name: '灯具',
      weight: 2
    }
  ]

export const sendAddressData: IAddrInfo = {
  id: '',
  name: '',
  phone: '',
  countryCode: '',
  country: '',
  province: '',
  city: '',
  district: '',
  street: '',
  detail: '',
  isDefault: false,
  createdAt: 0,
  updatedAt: 0,
}

export const getAddressData: IAddrInfo = {
  id: '',
  name: '',
  phone: '',
  countryCode: '',
  country: '',
  province: '',
  city: '',
  district: '',
  street: '',
  detail: '',
  isDefault: false,
  createdAt: 0,
  updatedAt: 0,
}

export const methodList: ISetting[] = [
  {
    text: '上门取件',
    value: 1,
  },
  {
    text: '服务点自寄',
    value: 2,
  }
]

export const payMethodList: ISetting[] = [
  {
    text: '寄付现结',
    value: 1
  },
  {
    text: '到付',
    value: 2
  }
]


export const gridList: ISetting[] = [
  {
    text: '小格口',
    value: 1
  },
  {
    text: '中格口',
    value: 2
  },
  {
    text: '大格口',
    value: 3
  }
]

export const dayList: ISetting[] = [
  {
    text: '今天',
    value: 1
  },
  {
    text: '明天',
    value: 2
  },
  {
    text: '后天',
    value: 3
  }
]

export const shippingMethodList: ISetting[] = [
  {
    text: '网点自寄',
    value: 1
  },
  {
    text: '自行联系快递员',
    value: 2
  },
  {
    text: '每天固定时间',
    value: 3
  }
]

export const timeList: string[] =
  ['8:00 - 9:00', '9:00 - 10:00', '10:00 - 11:00', '11:00 - 12:00', '12:00 - 13:00', '13:00 - 14:00', '14:00 - 15:00',
    '15:00 - 16:00', '16:00 - 17:00',
    '17:00 - 18:00']

export const address1: IAddrInfo = {
  id: util.generateRandomUUID(false),
  name: '张三',
  phone: '12345678901',
  countryCode: 'CN',
  country: '中国',
  province: '江苏省',
  city: '南京市',
  district: '雨花台区',
  street: '铁心桥街道',
  detail: '软件大道101号',
  isDefault: true,
  createdAt: new Date().getTime(),
  updatedAt: new Date().getTime(),
}

export const address2: IAddrInfo = {
  id: util.generateRandomUUID(false),
  name: '李四',
  phone: '12345678901',
  countryCode: 'CN',
  country: '中国',
  province: '',
  city: '北京市',
  district: '东城区',
  street: '景山前街',
  detail: '景山前街4号',
  isDefault: false,
  createdAt: new Date().getTime(),
  updatedAt: new Date().getTime(),
}