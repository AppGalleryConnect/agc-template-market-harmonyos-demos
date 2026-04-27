/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { common } from '@kit.AbilityKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import {
  FullOrderInfo,
  getOrder,
  ISubmitOrderRequest,
  OrderToPayParam,
  preOrder,
  RouterModule,
} from 'lib_foundation';
import { CommonUtils, GoodInfo, IServiceDetailItem, RouterMap, TypeGood } from 'module_base';
import { AddressDTO, AddressVM, Api } from 'address_management';

const TAG = '[OrderVM]';

@ObservedV2
export class OrderVM {
  static _instance: OrderVM;
  @Trace goodInfo: GoodInfo = new GoodInfo();
  @Trace addrSelected: AddressVM = new AddressVM();
  @Trace confirmServiceOutIndex: number = 0;
  @Trace confirmServiceInsideIndex: number = 0;
  @Trace selectServiceOutIndex: number = 0;
  @Trace selectServiceInsideIndex: number = 0;
  @Trace selectService: boolean = false;
  @Trace selectPayment: boolean = true;
  @Trace selectedDateTime: Date | null = null;
  @Trace remark: string = '';
  @Trace showServiceDetail: boolean = false;
  @Trace showTimeSheet: boolean = false;
  scroller: Scroller = new Scroller();
  context?: UIContext;
  uiAbilityContext: common.UIAbilityContext = this.context?.getHostContext() as common.UIAbilityContext;
  // 由于没有商户环境，不能真实调用华为支付api
  ignoreRequestPayment: boolean = true;
  private _orderId: string = '';

  static instance(isNew?: boolean) {
    if (isNew || !OrderVM._instance) {
      OrderVM._instance = new OrderVM();
      return OrderVM._instance;
    }
    return OrderVM._instance;
  }

  init(context: UIContext) {
    this.context = context;
    const paramList: GoodInfo[] = RouterModule.getNavParam({ url: RouterMap.ORDER_PAGE });
    if (paramList.length && paramList[paramList.length - 1]) {
      this.goodInfo = paramList[paramList.length - 1];
    }
    this.getDefaultAddr()
  }

  getDefaultAddr() {
    for (let data of Api.addressListMock) {
      if (data && data.isDefault) {
        this.jumpAddressManage(data, true)
        break;
      }
    }
  }

  // 是否包含选择服务环节
  showServiceSelect() {
    return Boolean(this.goodInfo.serviceDetailList?.length ?? 0);
  }

  // 是否包含选择上门时间的环节
  showTimeSelect() {
    return this.goodInfo.type === TypeGood.PAY;
  }

  // 是否包含商品信息
  showGoodCard() {
    if (!this.goodInfo.serviceDetailList?.length) {
      this.selectService = true;
      return true;
    }
    return false;
  }

  onClickServiceItem(out: number, inside: number) {
    this.selectServiceOutIndex = out;
    this.selectServiceInsideIndex = inside;
  }

  isServiceItemSelected(out: number, inside: number) {
    return this.selectServiceOutIndex === out && this.selectServiceInsideIndex === inside;
  }

  onClickServiceButton() {
    this.confirmServiceOutIndex = this.selectServiceOutIndex;
    this.confirmServiceInsideIndex = this.selectServiceInsideIndex;
    this.selectService = true;
    this.showServiceDetail = false;
  }

  getSelectServiceOut() {
    if (this.goodInfo?.serviceDetailList?.length) {
      return [this.goodInfo.serviceDetailList[this.confirmServiceOutIndex].title,
        this.goodInfo.serviceDetailList[this.confirmServiceOutIndex].subTitle,
      ]
    }
    return []
  }

  getSelectServiceInside() {
    if (this.goodInfo?.serviceDetailList?.length) {
      return this.goodInfo.serviceDetailList[this.confirmServiceOutIndex].prices[this.confirmServiceInsideIndex];
    }
    return { desc: '', count: 0, price: 0 } as IServiceDetailItem;
  }

  getAddressName() {
    if (this.addrSelected.id) {
      return [this.addrSelected.fullAddress, this.addrSelected.title];
    }
    return [];
  }

  jumpAddressManage = (dto: AddressDTO, isDefault: boolean = false) => {
    const address: AddressVM = new AddressVM(dto);
    this.addrSelected.id = address.id;
    this.addrSelected.name = address.name;
    this.addrSelected.phone = address.phone;
    this.addrSelected.countryCode = address.countryCode;
    this.addrSelected.country = address.country;
    this.addrSelected.province = address.province;
    this.addrSelected.city = address.city;
    this.addrSelected.district = address.district;
    this.addrSelected.street = address.street;
    this.addrSelected.detail = address.detail;
    this.addrSelected.isDefault = address.isDefault;
    this.addrSelected.createdAt = address.createdAt;
    this.addrSelected.updatedAt = address.updatedAt;

    if (!isDefault) {
      RouterModule.pop()
    }
  }

  updateAddress = (dto: AddressDTO) => {
    if (this.addrSelected.id === dto.id) {
      this.jumpAddressManage(dto, true)
    }
  }

  deleteAddress = (dto: AddressDTO) => {
    if (this.addrSelected.id === dto.id) {
      this.addrSelected = new AddressVM();
    }
  }

  isValid() {
    if (!this.addrSelected.detail) {
      promptAction.showToast({ message: '请填写地址' });
      return false;
    }

    if (!this.selectService) {
      promptAction.showToast({ message: '请选择服务' });
      return false;
    }

    if (!this.selectedDateTime) {
      promptAction.showToast({ message: '请选择上门时间' });
      return false;
    }

    if (!this.selectPayment) {
      promptAction.showToast({ message: '请勾选支付方式' });
      return false;
    }

    return true;
  }

  getTimeText() {
    if (!this.selectedDateTime) {
      return '';
    }
    return CommonUtils.formatDateTime(this.selectedDateTime.getTime());
  }

  getTotalCash() {
    try {
      if (!this.goodInfo?.serviceDetailList?.length) {
        return CommonUtils.handleCash(this.goodInfo.vipPrice);
      }
      const serviceItem =
        this.goodInfo.serviceDetailList[this.confirmServiceOutIndex].prices[this.confirmServiceInsideIndex];
      if (serviceItem) {
        return CommonUtils.handleCash(serviceItem.count * serviceItem.price * (serviceItem.extraCount ?? 1));
      }
      return CommonUtils.handleCash(this.goodInfo.vipPrice);
    } catch (e) {
      Logger.error(TAG, 'getTotalCash fail, error: ' + JSON.stringify(e));
      return CommonUtils.handleCash(this.goodInfo.vipPrice);
    }
  }

  buildSubmitParam() {
    const selectedDateTime = this.selectedDateTime;
    const param: ISubmitOrderRequest = {
      goodId: this.goodInfo.id,
      addressName: this.addrSelected.detail,
      addressStr: this.addrSelected.fullAddress,
      contactName: this.addrSelected.name,
      contactPhone: this.addrSelected.phone,
      selectServiceId: this.confirmServiceOutIndex + this.confirmServiceInsideIndex,
      appointTime: selectedDateTime?.getTime() || 0,
      remark: this.remark,
      actualPay: Number(this.getTotalCash()),
    };
    return param;
  }

  // 提交订单
  onSubmit() {
    if (!this.isValid()) {
      return;
    }
    CommonUtils.showLoading();
    const param = this.buildSubmitParam();
    preOrder(param).then((resp) => {
      this._orderId = resp;
      getOrder(this._orderId).then(async (resp) => {
        const paramToPay = new OrderToPayParam();
        paramToPay.orderInfo = resp as FullOrderInfo;
        paramToPay.isFromOrderCard = false;
        CommonUtils.hideLoading();
        RouterModule.push({ url: RouterMap.MY_ORDER_DETAIL, param: paramToPay });
      })
    });
  }
}

@ObservedV2
export class AddrList {
  @Trace list: AddressVM[] = [];
}