export class BaseResponse {
  status: number
  msg: string

  constructor(status: number, msg: string) {
    this.status = status
    this.msg = msg
  }
}

export class PreloadResponse {
  hmSystem?: GetHmSystemResp
  tableTitleArr?: GetTableTitleResp
}

export class GetHmSystemResp extends BaseResponse {
  storeId: string
  // 商户类型 1 桌号点餐  2 取餐码点餐
  storeType: number

  constructor(status: number, msg: string, storeId: string, storeType: number) {
    super(status, msg)
    this.storeId = storeId
    this.storeType = storeType
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

export class GetLoginHmSystemResp extends BaseResponse {
  data: GetUserInfoResp
  data2: AccessToken
  data3: PhoneInfo

  constructor(status: number, msg: string, data: GetUserInfoResp, data2: AccessToken, data3: PhoneInfo) {
    super(status, msg)
    this.data = data
    this.data2 = data2
    this.data3 = data3
  }
}

export class GetCancelHmSystemResp extends BaseResponse {
  data: string
  data1: string
  data2: string

  constructor(status: number, msg: string, data: string, data1: string, data2: string) {
    super(status, msg)
    this.data = data
    this.data1 = data1
    this.data2 = data2
  }
}

export class GetUserInfoResp extends BaseResponse {
  id: string
  name: string
  img: string
  openId: string
  unionId: string
  storeId: string
  totalScore: string
  wallet: string
  userTel?: string

  constructor(status: number, msg: string, id: string, name: string, img: string, openId: string,
    storeId: string, totalScore: string, wallet: string, unionId: string) {
    super(status, msg)
    this.id = id
    this.name = name
    this.img = img
    this.openId = openId
    this.storeId = storeId
    this.totalScore = totalScore
    this.wallet = wallet
    this.unionId = unionId
  }
}

export class GetStoreInfoResp {
  store: StoreInfo
  reduction: Array<Reduction>
  storeSet: StoreSet

  constructor(store: StoreInfo, reduction: Array<Reduction>, storeSet: StoreSet) {
    this.store = store
    this.reduction = reduction
    this.storeSet = storeSet
  }
}

export class StoreSet {
  // 新用户满减金额
  xyhMoney?: string
  // 备注口味：多个以;；分隔
  taste?: string

  constructor(xyhMoney?: string, taste?: string) {
    this.xyhMoney = xyhMoney
    this.taste = taste
  }
}

export class Reduction {
  id?: string
  name?: string
  full?: string
  reduction?: string
  type?: string
}

export class StoreInfo {
  id?: string
  name?: string
  address?: string
  // 上午营业起止时间
  time?: string
  time2?: string
  // 下午营业起止时间
  time3?: string
  time4?: string
  // 电话
  tel?: string
  // 促销信息
  announcement?: string
  logo?: string
  // 商户详情
  details?: string
  // 位置坐标
  coordinates?: string
  // 营业执照
  dpyyzz?: string
  // 食品经营许可证
  spjyxkz?: string
  environment?: Array<string>
  isRest?: string

  constructor(id?: string, name?: string, address?: string, time?: string, time2?: string, time3?: string,
    time4?: string,
    tel?: string, announcement?: string, logo?: string, details?: string, coordinates?: string,
    dpyyzz?: string, spjyxkz?: string, environment?: Array<string>, isRest?: string) {
    this.id = id
    this.name = name
    this.address = address
    this.time = time
    this.time2 = time2
    this.time3 = time3
    this.time4 = time4
    this.tel = tel
    this.announcement = announcement
    this.logo = logo
    this.details = details
    this.coordinates = coordinates
    this.dpyyzz = dpyyzz
    this.spjyxkz = spjyxkz
    this.environment = environment
    this.isRest = isRest
  }
}

export class GetTableTitleResp extends Array<TableTitle> {
}

export class TableTitle {
  id?: string
  name?: string
  typeName?: string
  num?: string
  status?: string

  constructor(id?: string, name?: string, typeName?: string, num?: string, status?: string) {
    this.id = id
    this.name = name
    this.typeName = typeName
    this.num = num
    this.status = status
  }
}

export class GetTableInfoResp {
  status?: string
  tableName?: string
  typeName?: string
}

export class GoodSpecInfo {
  specValId?: string
  specValName?: string
  specValLogo?: string
  specValNum?: string
}

export class GoodSpec {
  specId: string
  specName: string
  specValId: string
  specVal: Array<GoodSpecInfo>

  constructor(specId: string, specName: string, specValId: string, specVal: Array<GoodSpecInfo>) {
    this.specId = specId
    this.specName = specName
    this.specValId = specValId
    this.specVal = specVal
  }
}

/**
 * 商品
 */
export class Good {
  id?: string
  name?: string
  logo?: string
  bigImg?: Array<string>
  // 现价
  money?: string
  // 原价
  money2?: string
  // 折扣
  discount?: string
  content?: string
  sales?: string
  // 是否有规格 1 无 2有规格 3套餐
  specType?: string
  details?: string
  num?: string
  isMust?: string
  spec?: Array<GoodSpec>
  // 餐盒费
  boxMoney?: string
}

/**
 * 菜品类别
 */
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
 * 菜品类别
 */
export class GetGoodSpecResp {
  id?: string
  money?: string
  money2?: string
  discount?: string
  spec?: string
  combination?: PackageSpec[]
  number?: string
  goodId?: string
  boxMoney?: string
  isMust?: string
  specType?: string
}


export class GetMyCarResp {
  boxMoney?: number
  res?: Array<CarGoodInfo>
  num?: number
  money?: number

  constructor(boxMoney?: number, res?: Array<CarGoodInfo>, num?: number, money?: number) {
    this.boxMoney = boxMoney
    this.res = res
    this.num = num
    this.money = money
  }

  update(item: GetMyCarResp) {
    this.boxMoney = item.boxMoney
    this.res = item.res
    this.num = item.num
    this.money = item.money
  }
}

export class PackageSpec {
  specName?: string
  specNum?: number
}

@Observed
export class CarGoodInfo {
  id?: string
  goodId?: string
  num?: string
  specType?: string
  spec?: string
  combination?: PackageSpec[]
  discount?: string
  money?: string
  money2?: string
  boxMoney?: string
  type?: string
  number?: string
  logo?: string
  name?: string
  isMust?: string
}


export class OrderModel {
  id?: string
  orderNum?: string
  time?: string
  payTime?: string
  money?: string
  reductionMoney?: number
  boxMoney?: string
  mjMoney?: string
  xyhMoney?: string
  note?: string
  payType?: string
  orderType?: string
  tableware?: string
  yhqMoney?: string
  couponId?: string
  dnState?: string
  oid?: string
  tel?: string
  name?: string
  address?: string
  lat?: string
  lng?: string
}

@Observed
export class GoodsOfOrder {
  id: string = ''
  logo: string = ''
  money: string = ''
  money2: string = ''
  discount: string = ''
  name: string = ''
  num: string = ''
  isMust: string = ''
  specType: string = ''
  spec: string = ''
  combination?: PackageSpec[]
}

export class OrderTable {
  id: string = ''
  name: string = ''
  typeName: string = ''
}

// 订单列表
@Observed
export class GetMyOrderResp {
  order?: OrderModel
  num?: number
  good?: Array<GoodsOfOrder>
  table?: OrderTable
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
  // 类型：1 优惠券 2 红包
  type: string = ''
  // 总数量
  num: string = ''
  // 剩余数量
  stock: string = ''
  // 优惠券适用范围：1 外卖 2 店内 3 店内和外卖
  couponsType: string = ''
  state: number = 0

  constructor(id: string, name: string, desc: Array<string>, startTime: string, endTime: string, full: string,
    reduce: string, type: string, num: string, stock: string, couponsType: string, state: number) {
    this.id = id
    this.name = name
    this.desc = desc
    this.startTime = startTime
    this.endTime = endTime
    this.full = full
    this.reduce = reduce
    this.type = type
    this.num = num
    this.stock = stock
    this.couponsType = couponsType
    this.state = state
  }
}

//我的优惠券
export class MyCouponResp {
  id: string = ''
  couponId: string = ''
  state: string = ''
  type: string = ''
  full: string = ''
  reduce: string = ''
  name: string = ''
  //店内、外卖和店内
  couponType: string = ''
  endTime: string = ''
  desc: Array<string> = []
}



