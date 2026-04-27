import { map, mapCommon } from '@kit.MapKit';
import {
  BaseViewModel,
  CommonUtil,
  DAY_LIST,
  DISTANCE_PRICE_PER_KM,
  EmitterUtils,
  getTimeList,
  GRID_PRICE,
  HttpApi,
  ICompany,
  IGoods,
  ISetting,
  ITime,
  MIN_DISTANCE_PRICE,
  Parcel,
  RouterMap,
  RouterModule,
  ShippingType,
  ToastLoading,
  WEIGHT_PRICE_PER_KG,
} from 'lib_foundation';
import { CouponItem, CouponsController, ReductionTypes } from 'coupons';
import { AddressInfoModel } from 'module_template';


@ObservedV2
export class EditOrderPageVM extends BaseViewModel {
  @Trace showLoadingMask: boolean =  true;
  @Trace orderDetail: Parcel = new Parcel();
  // 寄件人信息
  @Trace senderInfo: AddressInfoModel = new AddressInfoModel();
  // 收件人信息
  @Trace receiverInfo: AddressInfoModel = new AddressInfoModel();
  // 物品名称
  @Trace goodsName: string = '';
  @Trace selectedGoods: IGoods | undefined;
  // 寄件方式
  @Trace selectedShippingMethod: ShippingType = ShippingType.PICKUP_SERVICE;
  // 默认支付方式
  @Trace selectedPayMethod: ISetting = { text: '寄付现结', value: 1 };
  // 快递公司
  @Trace companyList: ICompany[] = [];
  @Trace companyPickerList: string[] = [];
  @Trace selectedCompany: string = '';
  // 上门时间
  @Trace dayList: ITime[] = [];
  @Trace selectedDayText: string = '';
  @Trace selectedDayIndex: number = 0;
  @Trace selectedTime: string = '';
  // 选择格口
  @Trace selectedGrid: string = '';
  // 优惠金额
  @Trace couponDiscount: number = 0;
  @Trace selectCouponId: string = '';
  controller = new CouponsController();
  // 预估总价
  @Trace originPrice: number = 0
  @Trace price: number = 0;
  // 寄件人位置纬度
  @Trace senderLatitude: number = 0;
  // 寄件人位置经度
  @Trace senderLongitude: number = 0;
  // 收件人位置纬度
  @Trace receiverLatitude: number = 0;
  // 收件人位置经度
  @Trace receiverLongitude: number = 0;

  // 初始化数据
  initData() {
    const orderNo = RouterModule.getNavParam<string>({ url: RouterMap.EDIT_ORDER_PAGE });
    if (orderNo) {
      this.queryOrderInfo(orderNo);
    }
    this.dayList = getTimeList(DAY_LIST);
    HttpApi.getCompanyList().then((resp) => {
      this.companyList = resp;
    })
  }

  // 查询订单详情
  async queryOrderInfo(orderNo: string) {
    this.showLoadingMask = true;
    const resp = await HttpApi.queryParcelDetail(orderNo);
    if (resp.detail) {
      this.orderDetail = resp.detail;
      this.initShippingInfo();
      await this.queryCouponInfo();
      if (this.orderDetail.couponId) {
        const currentCouponId = this.orderDetail.couponId.toString();
        // 优惠券ID
        this.selectCouponId = currentCouponId;
        this.controller.selectedId = currentCouponId;
        this.originPrice = this.controller.calcOriginalAmount(currentCouponId, this.orderDetail.price);
        this.controller.totalMoney = this.originPrice;
        this.controller.calcAmount(this.selectCouponId);
        const reduce = Math.round(this.controller.reduce * 100) / 100;
        this.couponDiscount = reduce;
      } else {
        this.originPrice = this.orderDetail.price;
      }
    }
    this.showLoadingMask = false;
  }

  // 查询优惠券
  async queryCouponInfo() {
    const resp = await HttpApi.queryUserCouponList(this.userInfoModel.id);
    let couponsList: CouponItem[] = [];
    if (resp.length > 0) {
      couponsList = resp.map((item) => {
        const data = {
          couponID: item.id.toString(),
          couponName: item.name,
          usageRestriction: item.usageRestriction,
          startTime: CommonUtil.formatDate(item.startTime, 'YYYY-MM-DD'),
          endTime: CommonUtil.formatDate(item.endTime, 'YYYY-MM-DD'),
          createdTime: CommonUtil.formatDate(item.createdTime, 'YYYY-MM-DD'),
          amountRule: {
            discountType: item.discountType as ReductionTypes,
            fullAmount: item.fullAmount.toString(),
            discountAmount: item.discountAmount.toString(),
            discountCoefficient: item.discountCoefficient.toString(),
          }
        } as CouponItem;
        data.couponStatus = 0;
        return data;
      })
    }
    this.controller.couponList = couponsList;
  }

  // 初始化寄件信息
  initShippingInfo() {
    // 寄/收件人信息
    this.senderInfo.addressId = this.orderDetail.senderAddressId;
    this.senderInfo.name = this.orderDetail.senderName;
    this.senderInfo.phone = this.orderDetail.senderPhone;
    this.senderInfo.fullAddress = this.orderDetail.senderFullAddress;
    this.senderInfo.province = this.orderDetail.senderProvince;
    this.senderInfo.city = this.orderDetail.senderCity;
    this.senderLatitude = this.orderDetail.senderLatitude;
    this.senderLongitude = this.orderDetail.senderLongitude;
    this.receiverInfo.addressId = this.orderDetail.receiverAddressId;
    this.receiverInfo.name = this.orderDetail.receiverName;
    this.receiverInfo.phone = this.orderDetail.receiverPhone;
    this.receiverInfo.fullAddress = this.orderDetail.receiverFullAddress;
    this.receiverInfo.province = this.orderDetail.receiverProvince;
    this.receiverInfo.city = this.orderDetail.receiverCity;
    this.receiverLatitude = this.orderDetail.receiverLatitude;
    this.receiverLongitude = this.orderDetail.receiverLongitude;
    // 寄件方式
    this.selectedShippingMethod = this.orderDetail.shippingMethod;
    // 物品
    this.goodsName = this.orderDetail.goodsName;
    this.selectedGoods = {
      name: this.goodsName.split(' ')[0],
      weight: this.orderDetail.weight,
    } as IGoods;
    // 上门取件
    if (this.orderDetail.shippingMethod === ShippingType.PICKUP_SERVICE) {
      const pickupText = CommonUtil.parsePickupTime(this.orderDetail.pickupTime);
      const arr = pickupText.split(' ')
      this.selectedDayText = arr[0];
      const dayIndex = this.dayList.findIndex((item) => item.text === this.selectedDayText);
      this.selectedDayIndex = dayIndex > -1 ? dayIndex : 0;
      // 判断当前的小时数是否大于模板中选择的上门时间的小时数
      const hours = new Date().getHours();
      const preHoursStr = arr[1];
      const lastHoursStr: string = arr.slice(-1)[0];
      const preHour = preHoursStr.split(':')[0];
      const preHourInt = parseInt(preHour, 10);
      const lastHour = lastHoursStr.split(':')[0];
      const lastHourInt = parseInt(lastHour, 10);
      if (hours <= lastHourInt && hours >= preHourInt && this.selectedDayText === '今天') {
        this.selectedTime = '一小时内';
      } else {
        this.selectedTime = arr.slice(1).join(' ');
      }

      // 快递公司
      this.selectedCompany = this.orderDetail.expressCompany;
    } else { // 服务点自寄的格口
      this.selectedGrid = this.orderDetail.grid;
    }

    // 预计总价
    this.price = this.orderDetail.price;
  }

  // 跳转实名认证页面
  jumpToAuthPage() {
    if (this.userInfoModel.isRealName === 0) {
      RouterModule.push({ url: RouterMap.REAL_NAME_AUTH_PAGE })
    }
  }

  async handlerCoord(address: string) {
    const wgs84Position = await CommonUtil.getAddressesFromLocationName(address);
    let coord: mapCommon.LatLng | undefined = undefined;
    if (wgs84Position) {
      coord = CommonUtil.convertCoordinate(wgs84Position);
    }
    return coord;
  }

  // 选择寄件人地址信息
  onChangeSenderAddress() {
    ToastLoading.open();
    this.orderDetail.senderAddressId = this.senderInfo.addressId;
    this.orderDetail.senderName = this.senderInfo.name;
    this.orderDetail.senderPhone = this.senderInfo.phone;
    this.orderDetail.senderFullAddress = this.senderInfo.fullAddress;
    this.orderDetail.senderProvince = this.senderInfo.province;
    this.orderDetail.senderCity = this.senderInfo.city;

    // 获取寄件人位置的经纬度
    this.handlerCoord(this.senderInfo.fullAddress).then((resp) => {
      if (resp) {
        this.senderLatitude = resp.latitude;
        this.senderLongitude = resp.longitude;
        this.calcEstimatedPrice();
      }
    }).finally(() => {
      ToastLoading.close()
    })
  }

  // 选择收件人地址信息
  onChangeReceiverAddress() {
    ToastLoading.open();
    this.orderDetail.receiverAddressId = this.receiverInfo.addressId;
    this.orderDetail.receiverName = this.receiverInfo.name;
    this.orderDetail.receiverPhone = this.receiverInfo.phone;
    this.orderDetail.receiverFullAddress = this.receiverInfo.fullAddress;
    this.orderDetail.receiverProvince = this.receiverInfo.province;
    this.orderDetail.receiverCity = this.receiverInfo.city;
    // 获取收件人位置的经纬度
    this.handlerCoord(this.receiverInfo.fullAddress).then((resp) => {
      if (resp) {
        this.receiverLatitude = resp.latitude;
        this.receiverLongitude = resp.longitude;
        this.calcEstimatedPrice();
      }
    }).finally(() => {
      ToastLoading.close()
    })
  }

  onExchangeAddress() {
    ToastLoading.open();
    // 寄件人
    this.orderDetail.senderAddressId = this.senderInfo.addressId;
    this.orderDetail.senderName = this.senderInfo.name;
    this.orderDetail.senderPhone = this.senderInfo.phone;
    this.orderDetail.senderFullAddress = this.senderInfo.fullAddress;
    this.orderDetail.senderProvince = this.senderInfo.province;
    this.orderDetail.senderCity = this.senderInfo.city;
    // 收件人
    this.orderDetail.receiverAddressId = this.receiverInfo.addressId;
    this.orderDetail.receiverName = this.receiverInfo.name;
    this.orderDetail.receiverPhone = this.receiverInfo.phone;
    this.orderDetail.receiverFullAddress = this.receiverInfo.fullAddress;
    this.orderDetail.receiverProvince = this.receiverInfo.province;
    this.orderDetail.receiverCity = this.receiverInfo.city;
    Promise.all([
      this.handlerCoord(this.senderInfo.fullAddress),
      this.handlerCoord(this.receiverInfo.fullAddress),
    ]).then((resp) => {
      // 获取寄件人位置的经纬度
      if (resp[0]) {
        this.senderLatitude = resp[0].latitude;
        this.senderLongitude = resp[0].longitude;
      }
      // 获取收件人位置的经纬度
      if (resp[1]) {
        this.receiverLatitude = resp[1].latitude;
        this.receiverLongitude = resp[1].longitude;
      }
      this.calcEstimatedPrice();
    }).finally(() => {
      ToastLoading.close()
    })
  }

  // 计算预估价格 (mock)
  async calcEstimatedPrice() {
    // 物品重量
    const weight = this.selectedGoods!.weight;
    const weightPrice = weight * WEIGHT_PRICE_PER_KG;

    // 计算距离
    let from: mapCommon.LatLng = {
      latitude: this.senderLatitude,
      longitude: this.senderLongitude,
    };
    let to: mapCommon.LatLng = {
      latitude: this.receiverLatitude,
      longitude: this.receiverLongitude,
    }
    const distance = map.calculateDistance(from, to);
    // 距离
    const tempPrice = distance / 1000 * DISTANCE_PRICE_PER_KM;
    const distancePrice = tempPrice > MIN_DISTANCE_PRICE ? tempPrice : MIN_DISTANCE_PRICE;

    // 计算格口价格
    let gridPrice = 0;
    // 快递公司
    let companyPrice = 0;
    if (this.selectedShippingMethod === ShippingType.SERVICE_POINT) {
      gridPrice = GRID_PRICE[this.selectedGrid];
    } else {
      // 选择快递公司
      const curCompany = this.companyList.find((item) => item.name === this.selectedCompany);
      companyPrice = curCompany?.price ?? 0;
    }
    const total = weightPrice + distancePrice + gridPrice + companyPrice;
    const originPrice = this.userInfoModel.isVip ? total * 0.9 : total;

    this.originPrice = originPrice;
    const selectedCouponId = this.selectCouponId;
    if (selectedCouponId) {
      this.controller.totalMoney = this.originPrice;
      this.controller.calcAmount(selectedCouponId);
      const reduce = Math.round(this.controller.reduce * 100) / 100;
      this.couponDiscount = reduce;
      let resPrice = this.originPrice - reduce;
      if (resPrice < 0) {
        resPrice = 0;
      }
      this.price = Number(resPrice.toFixed(2));
    } else {
      this.price = Number(originPrice.toFixed(2));
    }
  }

  // 更新保存订单
  save() {
    ToastLoading.open();
    const nowTime = Date.now();
    const data = {
      id: this.orderDetail.id,
      parcelNumber: this.orderDetail.parcelNumber,
      expressCompany: this.selectedCompany,
      senderName: this.orderDetail.senderName,
      senderPhone: this.orderDetail.senderPhone,
      senderAddressId: this.orderDetail.senderAddressId,
      senderFullAddress: this.orderDetail.senderFullAddress,
      senderProvince: this.orderDetail.senderProvince,
      senderCity: this.orderDetail.senderCity,
      senderLatitude: this.senderLatitude,
      senderLongitude: this.senderLongitude,
      receiverName: this.orderDetail.receiverName,
      receiverPhone: this.orderDetail.receiverPhone,
      receiverAddressId: this.orderDetail.receiverAddressId,
      receiverFullAddress: this.orderDetail.receiverFullAddress,
      receiverProvince: this.orderDetail.receiverProvince,
      receiverCity: this.orderDetail.receiverCity,
      receiverLatitude: this.receiverLatitude,
      receiverLongitude: this.receiverLongitude,
      price: this.price,
      payMethod: this.selectedPayMethod.value,
      goodsName: this.goodsName,
      updateTime: nowTime,
    } as Parcel;

    if (this.selectedGoods?.weight) {
      data.weight  = this.selectedGoods.weight;
    }

    // 上门取件
    if (this.selectedShippingMethod === ShippingType.PICKUP_SERVICE) {
      const value = this.dayList[this.selectedDayIndex].value;
      const today = new Date();
      const tempDate = new Date();
      tempDate.setDate(today.getDate() + value);
      if (this.selectedTime === '一小时内') {
        const curHour = new Date().getHours();
        const maxHour = curHour + 1;
        tempDate.setHours(Number(maxHour), 0, 0, 0);
      } else {
        const tempMaxTime = this.selectedTime.split(' - ')[1];
        const hour = tempMaxTime.split(':')[0];
        tempDate.setHours(Number(hour), 0, 0, 0);
      }
      data.pickupTime = tempDate.getTime();
    } else { // 服务点自寄
      data.grid = this.selectedGrid;
    }

    if (this.selectCouponId) {
      data.couponId = Number(this.selectCouponId);
    } else {
      data.couponId = 0;
    }

    HttpApi.updateOrder(data).then((resp) => {
      if (resp) {
        const userId = this.userInfoModel.id;
        const oldCouponId = this.orderDetail.couponId ? Number(this.orderDetail.couponId) : undefined;
        const newCouponId = this.selectCouponId ? Number(this.selectCouponId) : undefined;

        // 只有当选择的券发生变化时，才执行数据库/接口操作
        if (oldCouponId !== newCouponId) {
          // 场景 1：如果之前用过券，无论现在是换券还是取消，都要先退还旧券
          if (oldCouponId) {
            HttpApi.refundCoupon(userId, oldCouponId);
          }
          // 场景 2：如果现在新选了券，无论之前是有券还是无券，都要执行使用新券
          if (newCouponId) {
            HttpApi.useCoupon(userId, newCouponId);
          }
          // 场景 3：同步订单详情中的优惠券 ID (即使 newCouponId 为空，也要同步，即取消优惠券)
          this.orderDetail.couponId = newCouponId;
        }

        EmitterUtils.emit('refreshOrderDetail');
        RouterModule.pop();
      }
    }).finally(() => {
      ToastLoading.close();
    })
  }
}