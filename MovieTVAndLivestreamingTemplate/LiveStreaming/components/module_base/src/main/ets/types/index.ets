import { AppStorageV2 } from '@kit.ArkUI';

enum TypeAddressPage {
  NEW = 1,
  EDIT = 2,
}

export interface ParamAddressPage {
  type: TypeAddressPage;
  param?: IAddrInfo;
}

// 寄件/收件人地址信息
export interface IAddrInfo {
  id: string;
  name: string; // 姓名
  phone: string; // 手机号
  countryCode: string; // 国家代码
  country: string; // 国家
  province: string; // 省
  city: string; // 市
  district: string; // 区
  street: string; // 街道
  detail: string; // 地址详述（如楼栋、门牌号等）
  isDefault: boolean; // 是否为默认地址
  createdAt: number; // 地址创建时间
  updatedAt: number; // 地址更新时间
}

export interface IBuilderType {
  label: string,
  placeholder: string,
  placeholderColor: ResourceStr,
  text: string,
  textColor: ResourceStr,
  isDivider: boolean,
  isTime: boolean,
  func: Function,
}

export interface ISetting {
  text: string,
  value: number,
}

export interface IParam {
  orderId?: number,
  templateId?: number,
}

/**
 * 用户信息
 */
export interface IUserInfo {
  loginToken: string,
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
  isVip: boolean,
  points: number,
  couponList: number[]
  realNameAuthFlag: number,
}

/**
 * 读取用户信息响应
 */
@ObservedV2
export class UserInfo implements IUserInfo {
  @Trace loginToken: string = ''
  @Trace id: number = 0;
  @Trace name: string = '';
  @Trace nickname: string = '';
  @Trace sex: string = '';
  @Trace cellphone: string = '';
  @Trace birthday: string = '';
  @Trace avatar: string = '';
  @Trace isVip: boolean = false;
  @Trace points: number = 0;
  @Trace couponList: number[] = []
  @Trace realNameAuthFlag: number = 0
}

/**
 * AppStorageV2应用全局缓存库
 */
export class AppStorageBank {
  static userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  static updateUserInfo(v: IUserInfo) {
    AppStorageBank.userInfo.loginToken = v.loginToken;
    AppStorageBank.userInfo.id = v.id;
    AppStorageBank.userInfo.name = v.name;
    AppStorageBank.userInfo.nickname = v.nickname;
    AppStorageBank.userInfo.sex = v.sex;
    AppStorageBank.userInfo.cellphone = v.cellphone;
    AppStorageBank.userInfo.birthday = v.birthday;
    AppStorageBank.userInfo.avatar = v.avatar;
    AppStorageBank.userInfo.isVip = v.isVip;
    AppStorageBank.userInfo.points = v.points;
    AppStorageBank.userInfo.couponList = v.couponList;
    AppStorageBank.userInfo.realNameAuthFlag = v.realNameAuthFlag;
  }
}