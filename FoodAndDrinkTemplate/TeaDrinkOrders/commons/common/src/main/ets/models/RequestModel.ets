import { PackageSpec } from './ResponseModel';

export interface BaseReq {
  // 商户Id
  storeId: string;

  // 用户Id
  userId: string;
}

export interface CommonReq {
  // 商户Id
  storeId: string;

  // 包名
  packageName: string;

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
  id: string | number;

  // 商品数量
  num: number;

  // 用户昵称
  name: string,

  // 用户性别
  sex: number,
}

export interface AddCarReq {
  // 商品单价
  money: string;

  // 商品id
  goodId?: string;

  // 商户id
  storeId?: string;

  // 用户id
  userId?: string;

  // 商品数量
  num: number;

  // 商品规格
  specType?: string;

  // 已选商品规格字符串
  spec?: string;

  // 已选商品规格
  combination?: PackageSpec[];

  // 商品打包费
  boxMoney: string;
}

export interface GoodReq {
  id: string;

  // 商品id
  goodId: string;

  // 商品图片
  img: string;

  // 商品单价
  money: string;

  // 商品名称
  name: string;

  // 商品数量
  num: number;

  // 已选商品规格字符串
  spec: string;
  specType: string;

  // 已选商品规格
  combination: PackageSpec[];
}

export interface AddDnOrderReq {
  userId: string, //用户ID
  storeId: string, //店铺ID
  money: number, //订单金额
  mjMoney: string, //满减金额
  xyhMoney: string, //新人优惠金额
  note: string, //备注
  type: number, //订单类型，店内订单
  formId: number, //随便填写 1
  formId2: number, //随便填写 1
  payType: number, //支付类型 0 华为支付
  sz: string, //购物车列表
  cutlery: string, //用餐人数
  yhqMoney: string, //优惠券金额
  couponId: string, //抵扣优惠券ID
  orderType: number, //订单使用类型 填写 0 店铺堂食
  boxMoney: number, //打包费
  bagMoney: number, //保温袋费用
  storeName: string, //店铺名称
  address: string, //店铺地址
  tel: string, //店铺电话
  coordinates: string, //店铺经纬度
  addressPre: string,
  addressNum: string,
  latitude: number,
  longitude: number,
  addressName: string,
  addressTel: string,
}


export interface MyOrderReq {
  // 商户id
  storeId: string,

  // 订单状态
  state: string,

  // 用户id
  userId: string,

  // 订单页码
  page: number,

  // 订单页大小
  pagesize: number
  // 订单tab页
  orderListType: number
  // 查询日期
  queryDay: string
}

export interface AddressReq extends BaseReq {
  id: number
  addressPre: string
  addressNum: string
  name: string
  sex: boolean
  tel: string
  tag: number
  latitude: number
  longitude: number
}