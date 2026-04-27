export interface IPhoneRequest {
  phone: string
}

// 根据用户id获取数据
export interface IUserIdRequest {
  userId: number
}

// 设置默认地址
export interface ISetDefaultAddress {
  isSetDefault: boolean;
}

// 删除地址
export interface IDeleteAddress {
  addressId: number
}

// 寄件模板Id
export interface ICommonTemplateReq {
  templateId: number
}

export interface ISignWeekRequest {
  userId: number,
  monday: number,
}

export interface IClaimCouponRequest {
  userId: number,
  couponId: number,
}

export interface IUserSignRequest {
  userId: number,
  dayIndex: number,
  points: number,
  monday: number,
}

export interface IUserPointRequest {
  userId: number,
  amount: number,
  desc: string
}

export interface IPointHistoryRequest {
  userId: number,
  startTime: number,
  endTime: number,
}

export interface IParcelDetailRequest {
  orderNo: string,
}

/**
 * 订单操作入参
 */
export interface OrderActionReq {
  orderNo: string;
  callback?: () => void;
  data?: ESObject;
}