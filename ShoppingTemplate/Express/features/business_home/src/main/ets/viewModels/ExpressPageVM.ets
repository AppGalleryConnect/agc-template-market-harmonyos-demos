import { AppStorageV2 } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import {
  getCompanyList,
  getCouponList,
  getEstimatedPrice,
  getOrderInfo,
  getServicePointList,
  ICompany,
  IGoods,
  IOrderInfo,
  IPrepayRequest,
  IServicePoint,
  ITemplate,
  OrderType,
  PaymentMethod,
  prepay,
  RouterModule,
  ShippingMethod,
  updateOrder,
  UpdateOrderRequest,
} from 'lib_foundation';
import {
  RouterMap,
  getAddressData,
  sendAddressData,
  IParam,
  ISetting,
  Logger,
  IAddrInfo,
  payMethodList,
  gridList,
  timeList,
  BaseViewModel,
  Coupon,
  toastUtil,
  contextUtil,
  PayMethodListDataSource,
} from 'module_base';
import { TemplateList } from 'module_template';
import { getDefaultAddress } from 'module_address'
import { dayList, getTimeList } from '../constants';
import { ITime } from '../types';

@ObservedV2
export class ExpressPageVM extends BaseViewModel {
  private static _instance: ExpressPageVM;
  context: common.UIAbilityContext = contextUtil.getContext() as common.UIAbilityContext;
  @Trace isLogin: boolean = false
  @Trace tempList: TemplateList = AppStorageV2.connect(TemplateList, () => new TemplateList())!;
  @Trace payMethodListDataSource: PayMethodListDataSource = new PayMethodListDataSource();

  @Monitor('tempList.list')
  onTempChange(monitor: IMonitor) {
    const list = monitor.value()?.now as ITemplate[];
  }

  @Trace public companyList: ICompany[] = []
  @Trace public servicePointList: IServicePoint[] = []
  @Trace public couponList: Coupon[] = []
  @Trace public orderInfo: IOrderInfo | undefined
  @Trace public companyPickerList: string[] = []
  @Trace public timePickerList: string[] = timeList
  @Trace public templateList: ITemplate[] = []
  @Trace public dayList: ITime[] = []
  @Trace public selectedMethod: number = 1
  @Trace public selectedTemplateId: number = 0
  @Trace public sendAddress: IAddrInfo = sendAddressData
  @Trace public getAddress: IAddrInfo = getAddressData
  @Trace public selectedAddress: OrderType = OrderType.SEND
  @Trace public selectedGoods: IGoods | undefined
  @Trace public selectedCompany: string = ''
  @Trace public selectedCompanyIndex: number = 0
  @Trace public tempCompany: string = ''
  @Trace public selectedDay: ITime | undefined
  @Trace public selectedDayText: string = ''
  @Trace public selectedDayIndex: number = 0
  @Trace public tempDay: string = ''
  @Trace public selectedTime: string = ''
  @Trace public selectedTimeIndex: number = 0
  @Trace public tempTime: string = ''
  @Trace public tempDayTime: string = ''
  @Trace public selectedPayMethod: string = ''
  @Trace public selectedPayMethodIndex: number = 0
  @Trace public tempPayMethod: string = ''
  @Trace public selectedCoupon: Coupon | undefined
  @Trace public selectedGrid: string = ''
  @Trace public selectedGridIndex: number = 0
  @Trace public tempGrid: string = ''
  @Trace public selectedServicePoint: IServicePoint | undefined
  @Trace public goodsName: string = ''
  @Trace public couponName: string = ''
  @Trace public originPrice: number = 0
  @Trace public price: string = '--'
  @Trace public isFresh: boolean = true
  @Trace public isSign: boolean = false

  public static get instance() {
    if (!ExpressPageVM._instance) {
      ExpressPageVM._instance = new ExpressPageVM();
    }
    return ExpressPageVM._instance;
  }

  public async init() {
    this.payMethodListDataSource.setData(payMethodList)
    this.dayList = getTimeList(dayList)
    this.timePickerList = this.dayList[0].timeList
    const param = RouterModule.getNavParam<IParam>({
      url: RouterMap.EXPRESS_PAGE,
    });
    if ((param && param.orderId) || this.isFresh) {
      if (param && param.orderId && this.isFresh) {
        this.getOrderInfo(param.orderId)
      }
      this.getCompanyList()
      this.getDefaultAddress()
      this.getServicePointList()
    }
    this.getTemplateList()
    if (param && param.templateId) {
      setTimeout(() => {
        this.selectedTemplateId = param.templateId as number
        const template = this.templateList.find((item) => {
          return item.id === param.templateId
        })
        if (template) {
          this.changeTemplate(template)
        }
      }, 300)
    }
  }

  clear() {
    this.orderInfo = undefined
    this.sendAddress = sendAddressData as IAddrInfo
    this.getAddress = getAddressData as IAddrInfo
    this.selectedMethod = 1
    this.selectedTemplateId = 0
    this.selectedGoods = undefined
    this.goodsName = ''
    this.selectedCompany = ''
    this.selectedDay = undefined
    this.selectedDayText = ''
    this.selectedTime = ''
    this.selectedPayMethod = ''
    this.selectedCoupon = undefined
    this.couponName = ''
    this.selectedGrid = ''
    this.selectedServicePoint = undefined
    this.originPrice = 0
    this.price = '--'
    this.isFresh = true
    this.isSign = false
    this.selectedCompanyIndex = 0
    this.selectedDayIndex = 0
    this.selectedTimeIndex = 0
    this.selectedPayMethodIndex = 0
    this.selectedGridIndex = 0
    this.couponList = []
  }

  public async getOrderInfo(id: number) {
    const res = await getOrderInfo({ id })
    this.orderInfo = res;
    this.selectedGoods = this.orderInfo.goods
    this.goodsName = this.selectedGoods.name + this.selectedGoods.weight + 'kg'
    this.tempCompany = this.orderInfo.companyName
    this.selectedCompanyIndex = this.getSelectedIndex(this.tempCompany, this.companyPickerList)
    this.tempPayMethod = this.orderInfo.paymentMethod
    this.selectedPayMethodIndex = this.getSelectedSettingIndex(this.tempPayMethod, payMethodList)
    if (this.orderInfo.grid) {
      this.tempGrid = this.orderInfo.grid
      this.selectedGridIndex = this.getSelectedSettingIndex(this.tempGrid, gridList)
    }
    this.tempDay = this.orderInfo.day
    this.tempTime = this.orderInfo.time
    this.tempDayTime = this.orderInfo.day + ' ' + this.orderInfo.time
    this.selectedTimeIndex = this.getSelectedIndex(this.tempTime, this.timePickerList)
    this.selectedDayIndex = this.getSelectedSettingIndex(this.tempDay, dayList)
  }

  public async getDefaultAddress() {
    const res = await getDefaultAddress()
    if (res) {
      this.sendAddress = res as IAddrInfo
    }
  }

  public getSelectedIndex(value: string, list: string[]) {
    const index = list.findIndex((item) => {
      return item === value
    })
    if (index !== -1) {
      return index
    }
    return 0
  }

  public getSelectedSettingIndex(value: string, list: ISetting[] | ITime[]) {
    const index = list.findIndex((item) => {
      return item.text === value
    })
    if (index !== -1) {
      return index
    }
    return 0
  }

  public async getCompanyList() {
    const res = await getCompanyList()
    this.companyList = res;
    this.companyList.forEach((item) => {
      this.companyPickerList.push(item.name)
    })
  }

  public async getCouponList() {
    const res = await getCouponList({ isVip: this.userInfoModel.isVip })
    if (this.userInfoModel.couponList.length !== 0) {
      for (let coupon of this.userInfoModel.couponList) {
        if (!coupon.isUsed) {
          if (coupon.promotionsLimitPrice === 0 || Number(this.originPrice) >= coupon.promotionsLimitPrice) {
            this.couponList.push(coupon)
          }
        }
      }
    }
  }

  public async getTemplateList() {
    this.templateList = []
    this.tempList.list.forEach((item) => {
      this.templateList.push(item as ITemplate)
    })
    const temp: ITemplate = {
      id: 0,
      name: '常规',
      sendAddress: {} as IAddrInfo,
      getAddress: {} as IAddrInfo,
      goods: {} as IGoods,
      shippingMethod: 1,
      paymentMethod: 1,
      weight: 1,
    }
    this.templateList.unshift(temp)
    this.selectedTemplateId = 0
  }

  public async getServicePointList() {
    const res = await getServicePointList()
    this.servicePointList = res;
    this.selectedServicePoint = res[0]
  }

  public changeTemplate(template: ITemplate) {
    this.selectedTemplateId = template.id
    if (this.selectedTemplateId === 0) {
      this.getAddress = {
        id: '',
        name: '',
        phone: '',
        countryCode: '',
        country: '',
        province: '',
        city: '',
        district: '',
        street: '',
        detail: '',
        isDefault: false,
        createdAt: 0,
        updatedAt: 0,
      }
      this.selectedGoods = undefined
      this.goodsName = ''
      this.selectedPayMethod = ''
      this.tempPayMethod = ''
      this.price = '--'
      this.getDefaultAddress()
    } else {
      this.sendAddress = template.sendAddress
      this.getAddress = template.getAddress
      if (template.shippingMethod === 3) {
        this.tempDay = '今天'
        this.tempTime = template.time!!
      }
      const paymentMethod = payMethodList.find((item) => {
        return item.value === template.paymentMethod
      })
      if (paymentMethod) {
        this.selectedPayMethod = paymentMethod.text
        this.tempPayMethod = paymentMethod.text
      }
      this.selectedGoods = template.goods
      this.goodsName = template.goods.name + template.goods.weight + ' kg'
      if (template.shippingMethod === 2 || template.shippingMethod === 3) {
        this.selectedMethod = 1
      } else {
        this.selectedMethod = 2
        this.getServicePointList()
      }
      this.getEstimatedPrice()
    }
  }

  checkAddress(): boolean {
    if (!this.sendAddress.phone || !this.getAddress.phone) {
      toastUtil.showToast('请先填写地址！');
      return false
    }
    return true
  }

  isPrepayRequestValid(): boolean {
    if (!this.checkParam()) {
      return false
    }
    if (!this.isSign) {
      return false
    }
    return true
  }

  public checkParam(): boolean {
    if (!this.sendAddress.phone || !this.getAddress.phone) {
      return false;
    }
    if (!this.selectedGoods) {
      return false
    }
    if (!this.selectedPayMethod) {
      return false
    }
    if (this.selectedMethod === 1) {
      if (!this.selectedCompany) {
        return false
      }
      if (!this.selectedTime) {
        return false
      }
    } else {
      if (!this.selectedGrid) {
        return false
      }
    }
    return true
  }

  public getPrepayParam() {
    if (!this.isPrepayRequestValid()) {
      return undefined;
    }
    if (!this.selectedGoods) {
      return undefined
    }
    const company = this.companyList.find((item) => {
      return item.name === this.selectedCompany
    })
    const data: IPrepayRequest = {
      sendAddress: this.sendAddress,
      getAddress: this.getAddress,
      goodsInfo: this.selectedGoods,
      expressCompanyId: company?.id ?? 1,
      day: this.selectedDay?.text,
      time: this.selectedTime,
      payMethod: this.selectedPayMethod === '到付' ? PaymentMethod.PAY_ON_DELIVERY : PaymentMethod.PAY_NOW,
      couponId: this.selectedCoupon?.id,
      servicePointId: this.selectedServicePoint?.id,
      grid: this.selectedGrid,
      shippingMethod: ShippingMethod.SELF_SENDING,
    }
    if (this.selectedMethod === 1) {
      data.shippingMethod = ShippingMethod.PICK_UP_AT_HOME
    } else {
      data.shippingMethod = ShippingMethod.SELF_SENDING
    }
    return data
  }

  public async getEstimatedPrice() {
    if (!this.checkParam()) {
      this.price = '--'
      return
    }
    const res = await getEstimatedPrice()
    this.originPrice = res
    this.price = res.toString()
    this.getCouponPrice(Number(this.price))
  }

  public getCouponPrice(price: number) {
    if (this.selectedCoupon) {
      this.price = price - this.selectedCoupon.promotion + ''
    }
    this.getVipPrice()
  }

  public getVipPrice() {
    if (this.userInfoModel.isVip) {
      this.price = Number(this.price) * 0.9 + ''
    }
  }

  public async prepay() {
    const data: IPrepayRequest | void = this.getPrepayParam();
    if (!data) {
      return;
    }
    const res = await prepay(data);
    const index = this.userInfoModel.couponList.findIndex((data: Coupon) => {
      return data.id === this.selectedCoupon?.id
    })
    if (index !== -1) {
      this.userInfoModel.couponList[index].isUsed = true
    }
    try {
      paymentService
        .requestPayment(this.context, res.orderStr)
        .then(() => {
          Logger.info('succeeded in paying');
        })
        .catch((error: BusinessError) => {
          if (data.payMethod === PaymentMethod.PAY_ON_DELIVERY) {
            toastUtil.showToast('订单已提交');
          } else {
            toastUtil.showToast('支付成功！');
          }
          const timer = setTimeout(() => {
            RouterModule.push({
              url: RouterMap.EDIT_ORDER_PAGE,
              param: res.timestamp,
            });
            this.clear()
            RouterModule.stack.removeByName(RouterMap.EXPRESS_PAGE)
            clearTimeout(timer);
          });
          let order: emitter.EventData = {
            data: {
              isFresh: true,
            },
          };
          try {
            emitter.emit('order', order);
          } catch (e) {
            Logger.error(JSON.stringify(e))
          }
        });
    } catch (e) {
      if (data.payMethod === PaymentMethod.PAY_ON_DELIVERY) {
        toastUtil.showToast('订单已提交');
      } else {
        toastUtil.showToast('支付成功！');
      }
      const timer = setTimeout(() => {
        RouterModule.push({
          url: RouterMap.EDIT_ORDER_PAGE,
          param: res.timestamp,
        });
        this.clear()
        RouterModule.stack.removeByName(RouterMap.EXPRESS_PAGE)
        clearTimeout(timer);
      });
      let order: emitter.EventData = {
        data: {
          isFresh: true,
        },
      };
      try {
        emitter.emit('order', order);
      } catch (e) {
        Logger.error(JSON.stringify(e))
      }
    }
  }

  public async updateOrder() {
    if (!this.orderInfo) {
      return
    }
    const data: UpdateOrderRequest = {
      id: this.orderInfo.id,
    }
    if (this.sendAddress.id) {
      data.sendAddress = this.sendAddress
    }
    if (this.getAddress.id) {
      data.getAddress = this.getAddress
    }
    if (this.selectedGoods) {
      data.goodsInfo = this.selectedGoods
    }
    if (this.selectedMethod === 1) {
      if (this.selectedCompany) {
        const company = this.companyList.find((item) => {
          return item.name === this.selectedCompany
        })
        data.expressCompanyId = company?.id
      }
      if (this.selectedTime) {
        data.day = this.selectedDay?.text
        data.time = this.selectedTime
      }
    } else {
      if (this.selectedGrid) {
        data.grid = this.selectedGrid
      }
    }
    await updateOrder(data)
    this.clear()
    toastUtil.showToast('修改成功！');
  }

  getButtonColor(): ResourceStr {
    if (this.orderInfo && this.isSign) {
      return '#0A59F7'
    }
    if (this.isPrepayRequestValid() && this.isSign) {
      return '#0A59F7'
    }
    return $r('sys.color.font_tertiary')
  }
}
