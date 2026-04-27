import { Parcel, ParcelStatus, PayStatus } from 'lib_foundation';

export enum TabBtnType {
  SEND_EXPRESS = 1,
  RECEIVE_EXPRESS = 2,
  PENDING_PAY = 3,
}

@ObservedV2
export class TabBtnItem {
  label: string = '';
  @Trace count: number = 0;
  @Trace type: TabBtnType = TabBtnType.SEND_EXPRESS

  constructor(label: string, count: number, type: TabBtnType) {
    this.label = label;
    this.count = count;
    this.type = type;
  }
}

export interface ActionMenuItem {
  label: ResourceStr,
  icon: Resource,
  action: () => void,
}

export interface NavItem {
  label: ResourceStr,
  value: string,
}

export interface CityAndName {
  city: string,
  name: string
}

export interface IActionInfo {
  label: ResourceStr,
  fontColor?: ResourceColor,
  btnBg?: ResourceColor,
  onAction: () => void,
}

export interface INodeItem {
  status: ParcelStatus
  image: ResourceStr,
  selectedImage: ResourceStr,
}

@ObservedV2
export class OrderInfo {
  // 运单id
  @Trace id: number = 0;
  // 运单号
  @Trace parcelNumber: string = '';
  // 快递公司
  @Trace expressCompany: string = '';
  // 使用的优惠券id
  @Trace couponId?: number = 0;
  // 寄件码
  @Trace dropOffCode: string = '';
  // 寄件人姓名
  @Trace senderName: string = '';
  // 寄件人手机号
  @Trace senderPhone: string = '';
  // 寄件人地址id
  @Trace senderAddressId: number = 0;
  // 寄件人地址
  @Trace senderFullAddress: string = '';
  // 寄件人省份
  @Trace senderProvince: string = '';
  // 寄件人城市
  @Trace senderCity: string = '';
  // 寄件人位置纬度
  @Trace senderLatitude: number = 0;
  // 寄件人位置经度
  @Trace senderLongitude: number = 0;
  // 收件人姓名
  @Trace receiverName: string = '';
  // 收件人手机号
  @Trace receiverPhone: string = '';
  // 收件地址id
  @Trace receiverAddressId: number = 0;
  // 收件人地址
  @Trace receiverFullAddress: string = '';
  // 收件人省份
  @Trace receiverProvince: string = '';
  // 收件人城市
  @Trace receiverCity: string = '';
  // 收件人位置纬度
  @Trace receiverLatitude: number = 0;
  // 收件人位置经度
  @Trace receiverLongitude: number = 0;
  // 运单状态
  @Trace status: ParcelStatus = ParcelStatus.AWAITING_PICKUP;
  // 支付金额
  @Trace price: number = 0;
  // 付款方式 1：寄付现结  2：到付
  @Trace payMethod: number = 1;
  // 是否支付 0：待支付  1：已支付
  @Trace paymentStatus: number = PayStatus.PENDING;
  // 寄件方式 1：上门取件  2：服务点自寄
  @Trace shippingMethod: number = 1;
  // 物品名称
  @Trace goodsName: string = '';
  // 格口
  @Trace grid: string = '';
  // 包裹重量
  @Trace weight: number = 0;
  // 创建时间
  @Trace createTime: number = 0;
  // 更新时间
  @Trace updateTime: number = 0;
  // 取消时间
  @Trace cancelTime: number = 0;
  // 预计上门取件时间
  @Trace pickupTime: number = 0;
  // 预计到达时间
  @Trace estimatedArrivalTime: number = 0;
  // 签收时间
  @Trace deliveryTime: number = 0;
  // 备注
  @Trace remark: string = '';

  constructor(parcel?: Parcel) {
    if (parcel) {
      this.id = parcel.id;
      this.parcelNumber = parcel.parcelNumber;
      this.expressCompany = parcel.expressCompany;
      this.dropOffCode = parcel.dropOffCode;
      this.senderName = parcel.senderName;
      this.senderPhone = parcel.senderPhone;
      this.senderAddressId = parcel.senderAddressId;
      this.senderFullAddress = parcel.senderFullAddress;
      this.senderProvince = parcel.senderProvince;
      this.senderCity = parcel.senderCity;
      this.senderLatitude = parcel.senderLatitude;
      this.senderLongitude = parcel.senderLongitude;
      this.receiverName = parcel.receiverName;
      this.receiverPhone = parcel.receiverPhone;
      this.receiverAddressId = parcel.receiverAddressId;
      this.receiverFullAddress = parcel.receiverFullAddress;
      this.receiverProvince = parcel.receiverProvince;
      this.receiverCity = parcel.receiverCity;
      this.receiverLatitude = parcel.receiverLatitude;
      this.receiverLongitude = parcel.receiverLongitude;
      this.status = parcel.status;
      this.price = parcel.price;
      this.payMethod = parcel.payMethod;
      this.paymentStatus = parcel.paymentStatus;
      this.shippingMethod = parcel.shippingMethod;
      this.goodsName = parcel.goodsName;
      this.grid = parcel.grid;
      this.weight = parcel.weight;
      this.createTime = parcel.createTime;
      this.updateTime = parcel.updateTime;
      this.cancelTime = parcel.cancelTime;
      this.pickupTime = parcel.pickupTime;
      this.estimatedArrivalTime = parcel.estimatedArrivalTime;
      this.deliveryTime = parcel.deliveryTime;
      this.remark = parcel.remark;
      if (parcel.couponId) {
        this.couponId = parcel.couponId;
      }
    }
  }
}