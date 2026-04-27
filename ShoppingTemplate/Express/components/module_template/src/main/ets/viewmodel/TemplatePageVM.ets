import { emitter } from '@kit.BasicServicesKit';
import { OrderType, PaymentMethod } from '../common/Constant';
import { IGoods, ITemplate } from '../http/Type';
import { TemplateApi } from '../http/Api';
import { RouterMap, getAddressData, sendAddressData, IAddrInfo, timeList, toastUtil, Logger } from 'module_base';
import { getDefaultAddress } from 'module_address'

@ObservedV2
export class TemplatePageVM {
  private static _instance: TemplatePageVM;
  stack: NavPathStack = new NavPathStack();
  @Trace public template: ITemplate | undefined
  @Trace public goodsList: IGoods[] = []
  @Trace public selectedGoodsId: number = 0
  @Trace public selectedShippingMethod: number = 1
  @Trace public selectedPaymentMethod: PaymentMethod = PaymentMethod.PAY_NOW
  @Trace public weight: number = 0
  @Trace public timePickerList: string[] = timeList
  @Trace public selectedTime: string = ''
  @Trace public selectedTimeIndex: number = 0
  @Trace public tempTime: string = ''
  @Trace public sendAddress: IAddrInfo = sendAddressData
  @Trace public getAddress: IAddrInfo = getAddressData
  @Trace public selectedAddress: OrderType = OrderType.SEND
  @Trace public isFresh: boolean = true

  public static get instance() {
    if (!TemplatePageVM._instance) {
      TemplatePageVM._instance = new TemplatePageVM();
    }
    return TemplatePageVM._instance;
  }

  public async init() {
    if (!this.isFresh) {
      return
    }
    const params: ITemplate[] =
      this.stack.getParamByName(RouterMap.TEMPLATE_PAGE) as ITemplate[];
    if (params.length && params[params.length - 1]) {
      const param = params[params.length - 1];
      if (param) {
        this.template = param
        this.sendAddress = param.sendAddress
        this.getAddress = param.getAddress
        this.selectedGoodsId = param.goods.id
        this.selectedShippingMethod = param.shippingMethod
        this.selectedPaymentMethod = param.paymentMethod
        this.weight = param.weight
        if (param.shippingMethod === 3) {
          this.selectedTime = param.time as string
          this.selectedTimeIndex = this.getSelectedIndex(this.tempTime, this.timePickerList)
        }
      } else {
        this.getDefaultAddress()
      }
    } else {
      this.getDefaultAddress()
    }
    this.getGoodsList()
  }

  public clear() {
    this.isFresh = true
    this.template = undefined
    this.selectedGoodsId = 0
    this.selectedShippingMethod = 1
    this.selectedPaymentMethod = PaymentMethod.PAY_NOW
    this.weight = 0
    this.sendAddress = sendAddressData as IAddrInfo
    this.getAddress = getAddressData as IAddrInfo
  }

  setStack(stack: NavPathStack) {
    this.stack = stack;
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

  public async getGoodsList() {
    const res = await TemplateApi.getGoodsList()
    this.goodsList = res
  }

  public checkTemplate(): boolean {
    if (!this.sendAddress.id) {
      toastUtil.showToast('请填写寄件人信息！');
      return false
    }
    if (!this.getAddress.id) {
      toastUtil.showToast('请填写收件人信息！');
      return false
    }
    if (this.selectedGoodsId === 0) {
      toastUtil.showToast('请选择物品！');
      return false
    }
    if (this.weight <= 0) {
      toastUtil.showToast('请填写重量！');
      return false
    }
    return true
  }

  public async addTemplate() {
    if (!this.checkTemplate()) {
      return
    }
    const goods = this.goodsList.find((item) => {
      return this.selectedGoodsId === item.id
    })
    if (!goods) {
      return
    }
    const data: ITemplate = {
      id: 0,
      name: goods.name,
      sendAddress: this.sendAddress,
      getAddress: this.getAddress,
      goods: goods,
      shippingMethod: this.selectedShippingMethod,
      paymentMethod: this.selectedPaymentMethod,
      weight: this.weight,
      time: this.selectedTime,
    }
    await TemplateApi.addTemplate(data)
    toastUtil.showToast('添加成功！');
    this.clear()
    this.stack.pop()
    let template: emitter.EventData = {
      data: {
        isFresh: true,
      },
    };
    try {
      emitter.emit('template', template);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }

  public async updateTemplate() {
    const goods = this.goodsList.find((item) => {
      return this.selectedGoodsId === item.id
    })
    if (!goods) {
      return
    }
    if (!this.template) {
      return
    }
    const data: ITemplate = {
      id: this.template.id,
      name: this.template.name,
      sendAddress: this.sendAddress,
      getAddress: this.getAddress,
      goods: goods,
      shippingMethod: this.selectedShippingMethod,
      paymentMethod: this.selectedPaymentMethod,
      weight: this.weight,
      time: this.selectedTime,
    }
    await TemplateApi.updateTemplate(data)
    toastUtil.showToast('修改成功！');
    this.clear()
    this.stack.pop()
    let template: emitter.EventData = {
      data: {
        isFresh: true,
      },
    };
    try {
      emitter.emit('template', template);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }
}
