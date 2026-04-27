import { ValueType } from '@kit.ArkData';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  BaseViewModel,
  BreakpointNameEnum,
  EmitterUtils,
  HttpApi,
  IGoods,
  PopViewUtils,
  RouterMap,
  RouterModule,
  TIME_LIST,
} from 'lib_foundation';
import { AddressDTO } from 'address_management';
import { PageMode, PaymentMethod } from '../common/Constant';
import { Template } from 'lib_foundation/src/main/ets/model/Template';
import { AddressInfoModel } from '../models/Model';
import { DateTimePickerParam, dateTimePickerSheetBuilder } from '../components/DateTimePickerSheet';


@ObservedV2
export class TemplatePageVM extends BaseViewModel {
  @Trace template: Template | undefined
  @Trace goodsList: IGoods[] = []
  @Trace selectedGoodsId: number = 0;
  @Trace selectedShippingMethod: number = 1;
  @Trace selectedPaymentMethod: PaymentMethod = PaymentMethod.PAY_NOW;
  @Trace weight: number = 1;
  @Trace timePickerList: string[] = TIME_LIST;
  @Trace selectedTime: string = '';
  @Trace selectedTimeIndex: number = 0;
  @Trace tempTime: string = '';
  @Trace senderInfo: AddressInfoModel = new AddressInfoModel();
  @Trace receiverInfo: AddressInfoModel = new AddressInfoModel();
  @Trace isFromListAdd: boolean = false;
  @Trace pageMode: PageMode = PageMode.CREATE;

  refreshAddressListener: (data?: ESObject) => void = (data?: ESObject) => {
    if (data) {
      const address = data.address as AddressDTO;
      if (this.senderInfo.addressId === address.addressId) {
        if (address.name) {
          this.senderInfo.name = address.name;
          this.senderInfo.phone = address.phone;
          this.senderInfo.fullAddress = address.detail;
          this.senderInfo.province = address.province;
          this.senderInfo.city = address.city;
        } else {
          this.senderInfo = new AddressInfoModel();
        }
      }
      if (this.receiverInfo.addressId === address.addressId) {
        if (address.name) {
          this.receiverInfo.name = address.name;
          this.receiverInfo.phone = address.phone;
          this.receiverInfo.fullAddress = address.detail;
          this.receiverInfo.province = address.province;
          this.receiverInfo.city = address.city;
        } else {
          this.receiverInfo = new AddressInfoModel();
        }
      }
    }
  }

  @Computed
  get pageTitle() {
    return this.pageMode === PageMode.EDIT ? '编辑模板' : '添加模板';
  }

  @Computed
  get shippingMethodSpace() {
    const isLarge = [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint);
    return isLarge ? 12 : 8;
  }

  // 初始化
  async init() {
    EmitterUtils.on('refreshAddressInfo', this.refreshAddressListener);
    // 默认是添加模板
    this.pageMode = PageMode.CREATE;
    // 获取物品类型列
    this.getGoodsList();
    // 处理参数
    const params = RouterModule.getNavParam({ url: RouterMap.TEMPLATE_PAGE }) as Record<string, ValueType>;
    if (params) {
      // 编辑操作
      if (params.id) {
        this.pageMode = PageMode.EDIT;
        this.getTemplateDetail(params.id as number);
      }
      // 从我的模板列表跳转过来的新增操作
      if (params.isFromListAdd) {
        this.isFromListAdd = true;
        // 获取默认地址
        this.getDefaultAddress();
      }
    } else {
      // 获取默认地址
      this.getDefaultAddress();
    }
  }

  // 获取默认的寄件地址
  async getDefaultAddress() {
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
      this.senderInfo.fullAddress = `${province}${city}${district}${street}${detail}`;
      this.senderInfo.province = province;
      this.senderInfo.city = city;
    } else {
      this.senderInfo.addressId = 0;
      this.senderInfo.name = '';
      this.senderInfo.phone = '';
      this.senderInfo.fullAddress = '';
      this.senderInfo.province = '';
      this.senderInfo.city = '';
    }
  }

  // 获取物品类型列表
  async getGoodsList() {
    const resp = await HttpApi.queryGoodsList();
    if (resp.length) {
      this.goodsList = resp as IGoods[];
    }
  }

  // 获取模板详情
  async getTemplateDetail(templateId: number) {
    HttpApi.queryTemplateDetail(templateId).then((resp) => {
      if (resp) {
        // 处理模板详情数据
        this.template = resp;
        // 处理寄件人信息
        if (resp.senderAddressId) {
          this.senderInfo.addressId = resp.senderAddressId;
        }
        if (resp.senderName) {
          this.senderInfo.name = resp.senderName;
        }
        if (resp.senderPhone) {
          this.senderInfo.phone = resp.senderPhone;
        }
        if (resp.senderFullAddress) {
          this.senderInfo.fullAddress = resp.senderFullAddress;
        }
        // 处理收件人信息
        if (resp.receiverAddressId) {
          this.receiverInfo.addressId = resp.receiverAddressId;
        }
        if (resp.receiverName) {
          this.receiverInfo.name = resp.receiverName;
        }
        if (resp.receiverPhone) {
          this.receiverInfo.phone = resp.receiverPhone;
        }
        if (resp.receiverFullAddress) {
          this.receiverInfo.fullAddress = resp.receiverFullAddress;
        }
        // 物品选择
        if (resp.goodsId) {
          this.selectedGoodsId = resp.goodsId;
        }
        // 预估重量
        if (resp.weight) {
          this.weight = resp.weight;
        }
        // 寄件方式
        if (resp.shippingMethod) {
          this.selectedShippingMethod = resp.shippingMethod;
        }
        // 付款方式
        if (resp.paymentMethod) {
          this.selectedPaymentMethod = resp.paymentMethod;
        }
        // 固定上门时间
        if (resp.pickupTime) {
          this.selectedTime = resp.pickupTime;
        }
      }
    })
  }

  // 设置固定时间
  openDateTimeSheet() {
    const param: DateTimePickerParam = {
      currentTime: this.selectedTime,
      confirm: (time: string) => {
        this.selectedTime = time;
        PopViewUtils.closeSheet();
      },
      cancel: () => {
        PopViewUtils.closeSheet();
      },
    }
    PopViewUtils.showSheet(wrapBuilder(dateTimePickerSheetBuilder), {
      height: 380,
      preferType: SheetType.CENTER,
      blurStyle: BlurStyle.Thick,
      showClose: true,
      backgroundColor: $r('sys.color.background_primary'),
      title: { title: '时间选择' },
    }, param)
  }

  // 校验模板信息
  checkTemplate(): boolean {
    if (!this.senderInfo.addressId) {
      ToastDialog.showToast({ message: '请填写寄件人信息！' });
      return false
    }
    if (!this.receiverInfo.addressId) {
      ToastDialog.showToast({ message: '请填写收件人信息！' });
      return false
    }
    if (!this.selectedGoodsId) {
      ToastDialog.showToast({ message: '请选择物品！' });
      return false
    }
    if (this.weight <= 0) {
      ToastDialog.showToast({ message: '请填写重量！' });
      return false
    }
    return true
  }

  // 新增模板
  async addTemplate() {
    if (!this.checkTemplate()) {
      return
    }
    const selectedGoods = this.goodsList.find((goods) => goods.id === this.selectedGoodsId);
    const now = Date.now();
    const data = {
      userId: this.userInfoModel.id,
      name: selectedGoods?.name ?? '自定义',
      goodsId: this.selectedGoodsId,
      weight: this.weight,
      senderAddressId: this.senderInfo.addressId,
      senderName: this.senderInfo.name,
      senderPhone: this.senderInfo.phone,
      senderProvince: this.senderInfo.province,
      senderCity: this.senderInfo.city,
      senderFullAddress: this.senderInfo.fullAddress,
      receiverAddressId: this.receiverInfo.addressId,
      receiverName: this.receiverInfo.name,
      receiverPhone: this.receiverInfo.phone,
      receiverProvince: this.receiverInfo.province,
      receiverCity: this.receiverInfo.city,
      receiverFullAddress: this.receiverInfo.fullAddress,
      shippingMethod: this.selectedShippingMethod,
      paymentMethod: this.selectedPaymentMethod,
      createdAt: now,
      updatedAt: now,
    } as Template;
    // 固定上门时间
    if (this.selectedShippingMethod === 3) {
      data.pickupTime = this.selectedTime;
    }

    HttpApi.addTemplate(data).then(() => {
      ToastDialog.showToast({ message: '添加成功！' });
      EmitterUtils.emit('refresh_template');
      RouterModule.popToName(RouterMap.EXPRESS_PAGE);
    })
  }

  // 跳转到我的模板列表页
  jumpToTemplateList() {
    if (this.isFromListAdd) {
      RouterModule.replace({ url: RouterMap.TEMPLATE_LIST_PAGE })
    } else {
      RouterModule.push({ url: RouterMap.TEMPLATE_LIST_PAGE })
    }
  }

  public clear() {
    EmitterUtils.off('refreshAddressInfo', this.refreshAddressListener);
  }


  // 编辑模板
  public async updateTemplate() {
    if (!this.checkTemplate() || !this.template) {
      return
    }
    const data = {
      id: this.template.id,
      goodsId: this.selectedGoodsId,
      senderAddressId: this.senderInfo.addressId,
      senderName: this.senderInfo.name,
      senderPhone: this.senderInfo.phone,
      senderProvince: this.senderInfo.province,
      senderCity: this.senderInfo.city,
      senderFullAddress: this.senderInfo.fullAddress,
      receiverAddressId: this.receiverInfo.addressId,
      receiverName: this.receiverInfo.name,
      receiverPhone: this.receiverInfo.phone,
      receiverProvince: this.receiverInfo.province,
      receiverCity: this.receiverInfo.city,
      receiverFullAddress: this.receiverInfo.fullAddress,
      weight: this.weight,
      shippingMethod: this.selectedShippingMethod,
      paymentMethod: this.selectedPaymentMethod,
      updatedAt: Date.now(),
    } as Template;
    // 固定上门时间
    if (this.selectedShippingMethod === 3) {
      data.pickupTime = this.selectedTime;
    } else {
      data.pickupTime = '';
    }
    HttpApi.updateTemplate(data).then((resp) => {
      if (resp > 0) {
        ToastDialog.showToast({ message: '修改成功！' });
        RouterModule.pop();
        EmitterUtils.emit('refresh_template');
      }
    })
  }
}
