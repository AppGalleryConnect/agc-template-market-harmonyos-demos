import { Decimal } from '@kit.ArkTS';
import { map, mapCommon } from '@kit.MapKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  ICompany,
  IGoods,
  IServicePoint,
  RouterModule,
  ShippingMethod,
  BaseViewModel,
  RouterMap,
  ISetting,
  PAY_METHOD_LIST,
  HttpApi,
  Template,
  Parcel,
  ParcelStatus,
  ShippingType,
  ITime,
  getTimeList,
  DAY_LIST,
  CommonUtil,
  PushUtil,
  GRID_PRICE,
  WEIGHT_PRICE_PER_KG,
  DISTANCE_PRICE_PER_KM,
  MIN_DISTANCE_PRICE,
  ToastLoading,
  Logger,
} from 'lib_foundation';
import { AddressInfoModel } from 'module_template';
import { CouponsController } from 'coupons';


@ObservedV2
export class ExpressPageVM extends BaseViewModel {
  private static _instance: ExpressPageVM;
  // 模板
  @Trace templateList: Template[] = [];
  // 选择的模板
  @Trace selectedTemplate: Template = new Template();
  // 寄件人信息
  @Trace senderInfo: AddressInfoModel = new AddressInfoModel();
  // 收件人信息
  @Trace receiverInfo: AddressInfoModel = new AddressInfoModel();
  // 寄件方式
  @Trace selectedShippingMethod: ShippingType = ShippingType.PICKUP_SERVICE;
  // 物品信息
  @Trace selectedGoods: IGoods | undefined;
  @Trace goodsName: string = '';
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
  // 选择服务点
  @Trace selectedServicePoint: IServicePoint | undefined;
  // 最近的服务点
  @Trace nearestServicePoint: IServicePoint | undefined;
  // 选择格口
  @Trace selectedGrid: string = ''
  // 优惠金额
  @Trace couponDiscount: number = 0;
  @Trace selectCouponId: string = '';
  controller = new CouponsController();
  // 预计价格
  @Trace originPrice: number = 0
  @Trace price: string = '--';
  // 是否阅读同意协议
  @Trace isSign: boolean = false;
  // 寄件人位置纬度
  @Trace senderLatitude: number = 0;
  // 寄件人位置经度
  @Trace senderLongitude: number = 0;
  // 收件人位置纬度
  @Trace receiverLatitude: number = 0;
  // 收件人位置经度
  @Trace receiverLongitude: number = 0;
  // 常规模板信息
  commonTemplate: Template = new Template();
  listScroller: ListScroller = new ListScroller();

  static get instance() {
    if (!ExpressPageVM._instance) {
      ExpressPageVM._instance = new ExpressPageVM();
    }
    return ExpressPageVM._instance;
  }

  // 初始化常规模板信息
  initCommonTemplate() {
    const commonTemplate = new Template()
    commonTemplate.name = '常规';
    commonTemplate.userId = this.userInfoModel.id;
    commonTemplate.shippingMethod = 3;
    commonTemplate.paymentMethod = 1;

    this.commonTemplate = commonTemplate;
    this.selectedTemplate = this.commonTemplate;
  }

  // 获取模板列表数据
  async getTemplateList() {
    this.templateList = [this.commonTemplate];
    const resp = await HttpApi.queryTemplateList(this.userInfoModel.id);
    if (resp.length > 0) {
      this.templateList.push(...resp);
    }

    // 如果是从我的模板跳转过来的，需要默认展示对应的模板信息
    const templateId = RouterModule.getNavParam({ url: RouterMap.EXPRESS_PAGE }) as number;
    if (templateId) {
      const curTemp = this.templateList.find((item) => item.id === templateId);
      const curTempIndex = this.templateList.findIndex((item) => item.id === templateId);
      if (curTemp) {
        this.changeTemplate(curTemp);
      }
      if (curTempIndex !== -1) {
        this.listScroller.scrollToIndex(curTempIndex);
      }
    } else {
      if (this.selectedTemplate) {
        const curTemp = this.templateList.find((item) => item.id === this.selectedTemplate.id);
        const curTempIndex = this.templateList.findIndex((item) => item.id === this.selectedTemplate.id);
        this.changeTemplate(curTemp ?? this.commonTemplate);
        const index = curTempIndex === -1 ? 0 : curTempIndex;
        this.listScroller.scrollToIndex(index);
      }
    }
  }

  // 初始化上门时间
  initPickUpTime() {
    this.dayList = getTimeList(DAY_LIST);
  }

  // 获取寄件人默认填充的地址信息
  async getSenderDefaultAddress() {
    const resp = await HttpApi.queryDefaultAddress(this.userInfoModel.id);
    if (resp) {
      this.senderInfo.addressId = resp.addressId;
      this.senderInfo.name = resp.name;
      this.senderInfo.phone = resp.phone;
      const province = resp.province;
      const city = resp.city;
      const district = resp.district;
      const street = resp.street;
      const detail = resp.detail;
      this.senderInfo.province = province;
      this.senderInfo.city = city;
      this.senderInfo.fullAddress = `${province}${city}${district}${street}${detail}`;
      // 填充常规模板的寄件人信息
      this.commonTemplate.senderAddressId = this.senderInfo.addressId;
      this.commonTemplate.senderName = this.senderInfo.name;
      this.commonTemplate.senderPhone = this.senderInfo.phone;
      this.commonTemplate.senderFullAddress = this.senderInfo.fullAddress;
      this.commonTemplate.senderProvince = this.senderInfo.province;
      this.commonTemplate.senderCity = this.senderInfo.city;

      // 获取寄件人位置的经纬度
      this.handlerCoord(this.senderInfo.fullAddress).then((resp) => {
        if (resp) {
          this.senderLatitude = resp.latitude;
          this.senderLongitude = resp.longitude;
        }
      })
    } else {
      this.senderInfo.addressId = 0;
      this.senderInfo.name = '';
      this.senderInfo.phone = '';
      this.senderInfo.province = '';
      this.senderInfo.city = '';
      this.senderInfo.fullAddress = '';
    }
  }

  // 获取快递公司列表
  async getCompanyList() {
    const resp = await HttpApi.getCompanyList();
    this.companyList = resp;
    this.companyPickerList = resp.map((item) => item.name);
  }

  // 获取最近的服务点
  async getServicePointList() {
    const resp = await HttpApi.getServicePointList()
    this.selectedServicePoint = resp[0];
    this.nearestServicePoint = resp[0];
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
    this.selectedTemplate.senderAddressId = this.senderInfo.addressId;
    this.selectedTemplate.senderName = this.senderInfo.name;
    this.selectedTemplate.senderPhone = this.senderInfo.phone;
    this.selectedTemplate.senderFullAddress = this.senderInfo.fullAddress;
    this.selectedTemplate.senderProvince = this.senderInfo.province;
    this.selectedTemplate.senderCity = this.senderInfo.city;

    ToastLoading.open();
    // 获取寄件人位置的经纬度
    this.handlerCoord(this.senderInfo.fullAddress).then((resp) => {
      if (resp) {
        this.senderLatitude = resp.latitude;
        this.senderLongitude = resp.longitude;
        this.getEstimatedPrice();
      }
    }).finally(() => {
      ToastLoading.close()
    })
  }

  // 选择收件人地址信息
  onChangeReceiverAddress() {
    this.selectedTemplate.receiverAddressId = this.receiverInfo.addressId;
    this.selectedTemplate.receiverName = this.receiverInfo.name;
    this.selectedTemplate.receiverPhone = this.receiverInfo.phone;
    this.selectedTemplate.receiverFullAddress = this.receiverInfo.fullAddress;
    this.selectedTemplate.receiverProvince = this.receiverInfo.province;
    this.selectedTemplate.receiverCity = this.receiverInfo.city;

    ToastLoading.open();
    // 获取收件人位置的经纬度
    this.handlerCoord(this.receiverInfo.fullAddress).then((resp) => {
      if (resp) {
        this.receiverLatitude = resp.latitude;
        this.receiverLongitude = resp.longitude;
        this.getEstimatedPrice();
      }
    }).finally(() => {
      ToastLoading.close()
    })
  }

  onExchangeAddress() {
    ToastLoading.open();
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
      this.getEstimatedPrice();
    }).finally(() => {
      ToastLoading.close()
    })
  }

  // 数据重置
  reset() {
    // 模板
    this.selectedTemplate = new Template();
    // 寄件人信息
    this.senderInfo = new AddressInfoModel();
    // 收件人信息
    this.receiverInfo = new AddressInfoModel();
    // 寄件方式
    this.selectedShippingMethod = ShippingType.PICKUP_SERVICE;
    // 物品信息
    this.selectedGoods = undefined;
    this.goodsName = '';
    // 快递
    this.selectedCompany = '';
    // 期望上门时间
    this.selectedDayIndex = 0;
    this.selectedDayText = '';
    this.selectedTime = '';
    // 付款方式
    this.selectedPayMethod = { text: '寄付现结', value: 1 };
    // 优惠券
    this.couponDiscount = 0;
    this.selectCouponId = '';
    // 格口
    this.selectedGrid = '';
    this.originPrice = 0;
    this.price = '--';
    this.isSign = false;
  }

  // 切换模板
  changeTemplate(template: Template) {
    this.selectedTemplate = template;
    // 填充寄件人地址信息
    this.senderInfo.addressId = this.selectedTemplate.senderAddressId;
    this.senderInfo.name = this.selectedTemplate.senderName;
    this.senderInfo.phone = this.selectedTemplate.senderPhone;
    this.senderInfo.fullAddress = this.selectedTemplate.senderFullAddress;
    this.senderInfo.province = this.selectedTemplate.senderProvince;
    this.senderInfo.city = this.selectedTemplate.senderCity;
    // 填充收件人地址信息
    this.receiverInfo.addressId = this.selectedTemplate.receiverAddressId;
    this.receiverInfo.name = this.selectedTemplate.receiverName;
    this.receiverInfo.phone = this.selectedTemplate.receiverPhone;
    this.receiverInfo.fullAddress = this.selectedTemplate.receiverFullAddress;
    this.receiverInfo.province = this.selectedTemplate.receiverProvince;
    this.receiverInfo.city = this.selectedTemplate.receiverCity;
    // 寄件方式
    if (this.selectedTemplate.shippingMethod === ShippingMethod.SELF_DELIVERY) {
      this.selectedShippingMethod = ShippingType.SERVICE_POINT;
      this.selectedServicePoint = this.nearestServicePoint;
    } else {
      this.selectedShippingMethod = ShippingType.PICKUP_SERVICE;
    }
    // 物品信息
    if (this.selectedTemplate.goodsId) {
      this.selectedGoods = {
        id: this.selectedTemplate.goodsId,
        name: this.selectedTemplate.goodsName,
        weight: this.selectedTemplate.weight,
        volume: this.selectedTemplate.goodsVolume,
        count: 1,
      } as IGoods;
      this.goodsName = `${this.selectedGoods.name} ${this.selectedGoods.weight}kg`;
    } else {
      this.selectedGoods = undefined;
      this.goodsName = '';
    }
    // 如果是上门取件
    if (this.selectedShippingMethod === ShippingType.PICKUP_SERVICE) {
      // 快递公司
      this.selectedCompany = '';
      // 期望上门时间
      if (this.selectedTemplate.pickupTime) {
        // 判断当前的小时数是否大于模板中选择的上门时间的小时数
        const hours = new Date().getHours();
        const lastHoursStr = this.selectedTemplate.pickupTime.split(' - ')[1];
        const hour = lastHoursStr.split(':')[0];
        const hourInt = parseInt(hour, 10);
        this.selectedDayIndex = 0;
        // 当前时间超过最晚时间
        if (hours >= 20) {
          this.selectedDayText = '明天';
          this.selectedTime = this.selectedTemplate.pickupTime;
        } else if (hours >= hourInt) {
          this.selectedDayText = '今天';
          this.selectedTime = '一小时内';
        } else {
          this.selectedDayText = '今天';
          this.selectedTime = this.selectedTemplate.pickupTime;
        }
      } else {
        this.selectedDayIndex = 0;
        this.selectedDayText = '';
        this.selectedTime = '';
      }
    } else {
      // 服务点自寄
      this.selectedGrid = '';
    }
    // 付款方式
    const payMethod = PAY_METHOD_LIST.find((pay) => pay.value === this.selectedTemplate.paymentMethod);
    if (payMethod) {
      this.selectedPayMethod = payMethod;
    } else {
      // 默认展示
      this.selectedPayMethod = { text: '寄付现结', value: 1 };
    }

    if (this.senderInfo.fullAddress) {
      // 获取寄件人位置的经纬度
      this.handlerCoord(this.senderInfo.fullAddress).then((senderResp) => {
        if (senderResp) {
          this.senderLatitude = senderResp.latitude;
          this.senderLongitude = senderResp.longitude;
        }

        if (this.receiverInfo.fullAddress) {
          // 获取收件人位置的经纬度
          this.handlerCoord(this.receiverInfo.fullAddress).then((receiveResp) => {
            if (receiveResp) {
              this.receiverLatitude = receiveResp.latitude;
              this.receiverLongitude = receiveResp.longitude;
            }
          })
        }
      })
    }

    this.getEstimatedPrice()
  }

  // 校验地址是否填写
  checkAddress(): boolean {
    if (!this.senderInfo.phone || !this.receiverInfo.phone) {
      ToastDialog.showToast({ message: '请先填写地址！' });
      return false
    }
    return true
  }

  calculatePrice(): number {
    // 物品重量
    const weight = this.selectedGoods!.weight;
    const weightPrice = weight * WEIGHT_PRICE_PER_KG;

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
    return this.userInfoModel.isVip ? total * 0.9 : total;
  }

  // 计算预估价格
  async getEstimatedPrice() {
    if (!this.checkParam()) {
      this.price = '--'
      return
    }

    this.originPrice = this.calculatePrice();
    if (this.selectCouponId) {
      this.controller.totalMoney = this.originPrice;
      this.controller.calcAmount(this.selectCouponId);
      const reduce = Math.round(this.controller.reduce * 100) / 100;
      this.couponDiscount = reduce;
      let resPrice = this.originPrice - reduce;

      if (resPrice < 0) {
        resPrice = 0;
      }
      this.price = resPrice.toFixed(2);
    } else {
      this.price = this.originPrice.toFixed(2);
    }
  }

  isPrepayRequestValid(): boolean {
    if (!this.checkParam()) {
      return false
    }
    if (!this.isSign) {
      return false
    }
    if (this.selectedShippingMethod === ShippingType.PICKUP_SERVICE && !this.selectedTime) {
      return false;
    }
    return true
  }

  checkParam(): boolean {
    if (!this.senderInfo.phone || !this.receiverInfo.phone) {
      return false;
    }
    if (!this.selectedGoods) {
      return false
    }
    if (this.selectedShippingMethod === ShippingType.PICKUP_SERVICE) {
      if (!this.selectedCompany) {
        return false
      }
    } else {
      if (!this.selectedGrid) {
        return false
      }
    }
    return true
  }

  // 下单或保存订单前的逻辑处理
  async preOrder() {
    ToastLoading.open();
    const nowTime = Date.now();
    const data = {
      parcelNumber: this.generateOrderNumber(),
      expressCompany: this.selectedCompany,
      senderName: this.senderInfo.name,
      senderPhone: this.senderInfo.phone,
      senderAddressId: this.senderInfo.addressId,
      senderFullAddress: this.senderInfo.fullAddress,
      senderProvince: this.senderInfo.province,
      senderCity: this.senderInfo.city,
      senderLatitude: this.senderLatitude,
      senderLongitude: this.senderLongitude,
      receiverName: this.receiverInfo.name,
      receiverPhone: this.receiverInfo.phone,
      receiverAddressId: this.receiverInfo.addressId,
      receiverFullAddress: this.receiverInfo.fullAddress,
      receiverProvince: this.receiverInfo.province,
      receiverCity: this.receiverInfo.city,
      receiverLatitude: this.receiverLatitude,
      receiverLongitude: this.receiverLongitude,
      price: Number(this.price),
      payMethod: this.selectedPayMethod.value,
      shippingMethod: this.selectedShippingMethod,
      goodsName: this.goodsName,
      createTime: nowTime,
      updateTime: nowTime,
    } as Parcel;
    // 物品重量
    if (this.selectedGoods?.weight !== undefined) {
      data.weight = this.selectedGoods.weight;
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
      data.status = ParcelStatus.AWAITING_PICKUP;
    } else { // 服务点自寄
      data.status = ParcelStatus.PENDING_LOCKER;
      data.grid = this.selectedGrid;
    }

    // 寄件码
    try {
      data.dropOffCode = Math.floor(Number(Decimal.random()) * 10000).toString().padStart(4, '0')
    } catch (e) {
      Logger.error('ExpressPageVM', `Decimal random failed. error: ${JSON.stringify(e)}`)
    }

    // 是否使用了优惠券
    if (this.selectCouponId) {
      data.couponId = Number(this.selectCouponId);
    }

    const resp = await HttpApi.createParcel(data);
    ToastLoading.close();
    if (resp > 0) {
      this.jumpToOrderPage(data.parcelNumber);
      // 寄一单快递获得10积分
      HttpApi.changeUserPoints(this.userInfoModel.id, 10, '寄件下单');
      // mock一条push消息，同时持久化该条消息
      PushUtil.pushMessageMock();
      // 使用优惠券
      HttpApi.useCoupon(this.userInfoModel.id, Number(this.selectCouponId));
    }
  }

  // 生成随机单号
  generateOrderNumber() {
    const curCompany = this.companyList.find((item) => item.name === this.selectedCompany);
    const prefix = curCompany?.value ?? 'PK';
    const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const random = Math.floor(Number(Decimal.random()) * 1000000).toString().padStart(6, '0');
    return prefix + date + random;
  }

  // 跳转详情
  jumpToOrderPage(orderNo: string) {
    RouterModule.push({
      url: RouterMap.ORDER_DETAIL,
      param: orderNo,
    });
  }
}
