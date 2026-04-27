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
  isIcon: boolean,
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
 * 优惠券
 */
@ObservedV2
export class Coupon {
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace type: number = 0
  @Trace promotion: number = 0
  @Trace promotionsLimitPrice: number = 0
  @Trace promotionsLimit: string = ''
  @Trace goodsLimit: string = ''
  @Trace time: string = ''
  @Trace isAvailable: boolean = true
  @Trace isShow: boolean = false
  @Trace isUsed: boolean = false
  @Trace instructionList: string[]

  constructor(id: number = 0, name: string = '', type: number = 0, promotion: number = 0,
    promotionsLimitPrice: number = 0,
    promotionsLimit: string = '', goodsLimit: string = '',
    time: string = '', isAvailable: boolean = true, isShow: boolean = false, instructionList: string[] = []) {
    this.id = id
    this.name = name
    this.type = type
    this.promotion = promotion
    this.promotionsLimitPrice = promotionsLimitPrice
    this.promotionsLimit = promotionsLimit
    this.goodsLimit = goodsLimit
    this.time = time
    this.isAvailable = isAvailable
    this.isShow = isShow
    this.instructionList = instructionList
  }
}