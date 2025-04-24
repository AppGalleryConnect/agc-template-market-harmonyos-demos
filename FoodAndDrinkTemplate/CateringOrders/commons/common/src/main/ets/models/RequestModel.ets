import { PackageSpec } from './ResponseModel';

export interface CommonReq {
  // 商户Id
  storeId: string;
  // 用户Id
  userId: string;
  // 用户OpenID
  openId: string;
  // 用户UnionID。
  unionId: string;
  // 鸿蒙应用AppId
  hmAppid: string;
  // 订单Id
  orderId: string;
  // 商品Id
  goodId: string;
  // 商品规格字符串
  spec: string;
  // 已选商品规格
  combination: PackageSpec[];
  // 抵扣优惠券ID
  couponId: string;
  // 华为登录返回code
  code: string;
  // Id
  id: string;
  // 商品数量
  num: string;
}

export interface AddCarReq {
  // 商品单价
  money?: string;
  // 商品id
  goodId?: string;
  // 商户id
  storeId?: string;
  // 用户id
  userId?: string;
  // 商品数量
  num?: string;
  // 商品规格
  specType?: string;
  // 已选商品规格字符串
  spec?: string;
  // 已选商品规格
  combination?: PackageSpec[];
  // 商品打包费
  boxMoney?: string;
}

export interface GoodReq {
  // 商品id
  id: string;
  // 商品图片
  img: string;
  // 商品单价
  money: string;
  // 商品名称
  name: string;
  // 商品数量
  num: string;
  // 已选商品规格字符串
  spec: string;
  // 已选商品规格
  combination: PackageSpec[];
}

export interface AddDnOrderReq {
  tableId: string, //桌号
  userId: string, //用户ID
  storeId: string, //店铺ID
  money: number, //订单金额
  discount: string, //优惠金额
  mjMoney: string, //满减金额
  xyhMoney: string, //新人优惠金额
  note: string, //备注
  type: number, //订单类型，店内订单
  formId: number, //随便填写 1
  formId2: number, //随便填写 1
  payType: number, //支付类型 0 华为支付
  sz: string, //购物车列表
  tableware: number, //用餐人数
  yhqMoney: string, //优惠券金额
  couponId: string, //抵扣优惠券ID
  orderType: number, //订单使用类型 填写 0 店铺堂食
  boxMoney: number, //打包费
  reductionMoney: number, //优惠金额
}


export interface MyOrderReq {
  // 商户id
  storeId: string,

  // 订单状态
  dnState: string,

  // 用户id
  userId: string,

  // 订单页码
  page: number,

  // 订单页大小
  pagesize: number
}