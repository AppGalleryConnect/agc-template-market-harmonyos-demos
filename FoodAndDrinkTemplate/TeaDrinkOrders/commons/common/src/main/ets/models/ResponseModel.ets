import { orderStateMap } from '../constants/Common'

export class BaseResponse<T = undefined> {
  code: number
  msg: string
  data: T

  constructor(status: number, msg: string, data: T) {
    this.code = status
    this.msg = msg
    this.data = data
  }
}

export class HmSystem {
  tel: string

  constructor(tel: string) {
    this.tel = tel
  }
}

export class AccessToken {
  scope: string = ''
  accessToken: string = ''
  refreshToken: string = ''
  tokenType: string = ''
  expiresIn: number = 0
  idToken: string = ''
}

export class PhoneInfo {
  unionID: string = ''
  phoneCountryCode: string = ''
  mobileNumber: string = ''
  openID: string = ''
  purePhoneNumber: string = ''
}

@ObservedV2
export class UserInfo {
  id: string = ''
  @Trace name: string = ''
  totalScore: string = ''
  @Trace userTel?: string = ''
  membershipCode: string = ''
  @Trace sixProcess: number = 0
  @Trace level: number = 1
  @Trace sex: number = 0

  constructor() {
  }
}

@ObservedV2
export class Reduction {
  id: string = ''
  name: string = ''
  full: string = ''
  reduction: string = ''
  @Trace status: number = 0

  constructor(id?: string, name?: string, full?: string, reduction?: string, status?: number) {
    this.id = id || ''
    this.name = name || ''
    this.full = full || ''
    this.reduction = reduction || ''
    this.status = status || 0
  }
}

@ObservedV2
export class StoreInfo {
  id: string = ''
  @Trace name: string = ''
  address: string = ''
  // 营业开始时间
  time1: string = ''
  // 营业结束时间
  time2: string = ''
  // 电话
  tel: string = ''
  // 促销信息
  announcement: string = ''
  logo: string = ''
  // 位置坐标
  coordinates: string = ''
  // 营业执照
  dpyyzz: string = ''
  // 食品经营许可证
  spjyxkz: string = ''
  // 保温袋金额
  bagMoney: number = 0
  environment: Array<string> = []
  // 是否休息
  isRest: boolean = false
  // 距离
  @Trace distance: number = 0
  @Trace distanceStr: string = ''
  // 是否可以外送
  canTakeaways: boolean = true
  // 制作数量
  makingNum: number = 0
  makingWaitTime: number = 0
  // 备注口味：多个以;；分隔
  taste: Array<string> = []
  @Trace reduction: Array<Reduction> = []

  constructor() {
  }
}

/**
 * 商品
 */
@ObservedV2
export class Good {
  id?: string
  name?: string
  logo?: string
  bigImg: Array<string> = []
  money: string = '0'
  content?: string
  sales?: string
  // 是否有规格 1 无 2有规格 3套餐
  specType?: string
  details?: string
  num?: number
  spec?: Array<GoodSpec>
  // 餐盒费
  boxMoney: string = '0'
}

@ObservedV2
export class GoodSpec {
  specId: string
  specName: string
  specValId: string
  @Trace selected: boolean = false
  @Trace specVal: Array<GoodSpecVal>

  constructor(specId: string, specName: string, specValId: string, specVal: Array<GoodSpecVal>) {
    this.specId = specId
    this.specName = specName
    this.specValId = specValId
    this.specVal = specVal
  }
}

@ObservedV2
export class GoodSpecVal extends Good {
  @Trace specValId?: string
  @Trace specValName?: string
  @Trace specValLogo?: string
  @Trace specValNum?: string
  @Trace selected: boolean = false
}

/**
 * 饮品类别
 */
@ObservedV2
export class DishesType {
  id: string
  typeName: string
  good: Array<Good>

  constructor(id: string, typeName: string, good: Array<Good>) {
    this.id = id
    this.typeName = typeName
    this.good = good
  }
}


/**
 * 饮品类别
 */
@ObservedV2
export class GoodSpecInfo {
  id?: string
  specId: string = ''
  money?: string
  @Trace spec?: string
  @Trace combination?: PackageSpec[]
  number?: string
  num: number = 0
  @Trace goodId?: string
  @Trace goodName: string = ''
  @Trace goodLogo: string = ''
  boxMoney: string = '0'
  specType?: string

  @Computed
  get specStr() {
    return this.spec?.split(',').join(' | ')
  }
}

@ObservedV2
export class MyCar {
  @Trace boxMoney?: number
  @Trace carGoods: Array<CarGoodInfo> = []
  @Trace num?: number
  @Trace money?: number

  constructor(boxMoney?: number, res: Array<CarGoodInfo> = [], num?: number, money?: number) {
    this.boxMoney = boxMoney
    this.carGoods = res
    this.num = num
    this.money = money
  }

  update(item: MyCar) {
    this.boxMoney = item.boxMoney
    this.carGoods = item.carGoods
    this.num = item.num
    this.money = item.money
  }
}

@ObservedV2
export class PackageSpec {
  @Trace specId?: string = ''
  @Trace specValId?: string = ''
  @Trace specName?: string = ''
  @Trace specLogo?: string = ''
  @Trace specVal?: string = ''
  @Trace specNum?: number = 0
}

@ObservedV2
export class CarGoodInfo {
  id: string = ''
  goodId?: string = ''
  logo?: string = ''
  name?: string = ''
  type?: string = ''
  @Trace num: number = 0
  specType?: string = ''
  @Trace spec?: string = ''
  @Trace combination?: PackageSpec[] = []
  money: string = ''
  boxMoney?: string = ''
  number?: string = ''
  isCheck?: boolean = true
}

@ObservedV2
export class OrderModel {
  id?: string
  orderNum?: string
  time?: string
  payTime: number = 0
  money?: number
  boxMoney?: number
  mjMoney?: string
  xyhMoney?: string
  note?: string
  payType?: number
  orderType: number = 0
  cutlery?: string
  yhqMoney?: string
  couponId?: string
  @Trace state: number = 0
  oid?: string
  tel?: string
  storeName?: string
  address?: string
  coordinates?: string
  bagMoney?: number

  getState() {
    return orderStateMap[this.state]
  }
}

@ObservedV2
export class GoodsOfOrder {
  id: string = ''
  logo: string = ''
  money: string = ''
  name: string = ''
  num: number = 0
  specType: string = ''
  spec: string = ''
  combination?: PackageSpec[]
}

// 订单列表
@ObservedV2
export class MyOrderInfo {
  @Trace order: OrderModel = new OrderModel()
  num?: number
  @Trace good?: Array<GoodsOfOrder>
  storeInfo: StoreInfo = new StoreInfo()
  address: AddressInfo = new AddressInfo()
  delivery: DeliveryInfo = new DeliveryInfo()
}

//个人中心--帮助信息
export class GetHelpMsgResp {
  id: string
  question: string
  answer: string

  constructor(id: string, question: string, answer: string) {
    this.id = id
    this.question = question
    this.answer = answer
  }
}

//优惠券
export class CouponResp {
  id: string = ''
  // 优惠券名称
  name: string = ''
  // 描述
  desc: Array<string> = []
  // 优惠开始时间
  startTime: string = ''
  // 优惠结束时间
  endTime: string = ''
  // 满减额
  full: string = ''
  // 优惠金额
  reduce: string = ''
  // 总数量
  num: number = 0
  // 剩余数量
  stock: string = ''
  state: number = 0

  constructor(id: string, name: string, desc: Array<string>, startTime: string, endTime: string, full: string,
    reduce: string, num: number, stock: string, state: number) {
    this.id = id
    this.name = name
    this.desc = desc
    this.startTime = startTime
    this.endTime = endTime
    this.full = full
    this.reduce = reduce
    this.num = num
    this.stock = stock
    this.state = state
  }
}

//我的优惠券
@ObservedV2
export class MyCoupon {
  id: string = ''
  couponId: string = ''
  name: string = ''
  // 描述
  desc: Array<string> = []
  @Trace state: number = 0
  full: string = ''
  reduce: string = ''
  // 优惠开始时间
  startTime: string = ''
  endTime: string = ''
}

//店铺制作信息
export class StoreMakeInfo {
  storeId: string = ''
  waitNum: number = 0
  waitTime: number = 2
}

//地址信息
@ObservedV2
export class AddressInfo {
  @Trace id: number = 0
  @Trace addressPre: string = ''
  @Trace addressNum: string = ''
  @Trace name: string = ''
  @Trace sex: boolean = true
  @Trace tel: string = ''
  @Trace tag: number = 0
  @Trace latitude: number = 0
  @Trace longitude: number = 0
}


//配送信息
@ObservedV2
export class DeliveryInfo {
  @Trace name: string = ''
  @Trace tel: string = ''
  @Trace latitude: number = 0
  @Trace longitude: number = 0
  @Trace distance: number = 0
  @Trace remainingTime: number = 0
  @Trace estimatedTime: string = ''
}



