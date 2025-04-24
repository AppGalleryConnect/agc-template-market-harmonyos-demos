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
import {
  addAddress,
  AddressInfo,
  AppStorageBank,
  CommonUtils,
  deleteAddress,
  getAddressList,
  IAddrInfo,
  IJumpAddrParam,
  PHONE_REG,
  RouterMap,
  RouterModule,
  updateAddress,
} from 'utils';
import { TypeAddressPage } from '../common/Constant';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class AddressVM {
  @Trace type: TypeAddressPage = TypeAddressPage.NEW;
  @Trace list: AddressInfo[] = [];
  @Trace needPop: boolean = false;
  @Trace selectedId: number = 0;
  listScroller: ListScroller = new ListScroller()
  static _instance: AddressVM;

  static get instance() {
    if (AddressVM._instance) {
      return AddressVM._instance;
    }
    AddressVM._instance = new AddressVM();
    return AddressVM._instance;
  }

  init() {
    this.getRouteParam();
    this.queryList();
  }

  getRouteParam() {
    const paramList: IJumpAddrParam[] = RouterModule.getNavParam({ url: RouterMap.ADDRESS_MANAGE });
    if (paramList.length && paramList[paramList.length - 1]) {
      const item = paramList[paramList.length - 1];
      this.needPop = item.needOnPop ?? false;
      this.selectedId = item.selectedId ?? 0;
    } else {
      this.needPop = false;
      this.selectedId = 0;
    }
  }

  isSelected(item: AddressInfo) {
    return item.id === this.selectedId;
  }

  getObservedAddrInfo(item: IAddrInfo): AddressInfo {
    const observedItem: AddressInfo = new AddressInfo();
    observedItem.id = item.id;
    observedItem.name = item.name;
    observedItem.address = item.address;
    observedItem.contactName = item.contactName;
    observedItem.contactPhone = item.contactPhone;
    return observedItem;
  }

  sortAddrList(a: IAddrInfo, b: IAddrInfo): number {
    if (this.selectedId === 0) {
      return 0;
    }
    if (a.id === this.selectedId) {
      return -1;
    }
    if (b.id === this.selectedId) {
      return 1;
    }
    return 0;
  }

  queryList() {
    CommonUtils.showLoading();
    getAddressList().then((resp) => {
      this.list = resp
        .map((item: IAddrInfo) => this.getObservedAddrInfo(item))
        .sort((a: IAddrInfo, b: IAddrInfo) => this.sortAddrList(a, b));
      AppStorageBank.updateAddrList(this.list);
      CommonUtils.hideLoading();
    });
  }

  isNew() {
    return this.type === TypeAddressPage.NEW;
  }

  validInfo(address: AddressInfo) {
    if (!address.name) {
      promptAction.showToast({ message: '请填写地区' });
      return false;
    }

    if (!address.address) {
      promptAction.showToast({ message: '请填写详细地址与门牌号' });
      return false;
    }

    if (!address.contactName) {
      promptAction.showToast({ message: '请填写收货人姓名' });
      return false;
    }

    if (!address.contactPhone) {
      promptAction.showToast({ message: '请填写手机号码' });
      return false;
    }
    if (!PHONE_REG.test(address.contactPhone)) {
      promptAction.showToast({ message: '请填写正确的手机号码' });
      return false;
    }

    return true;
  }

  savaData(data: AddressInfo) {
    CommonUtils.showLoading();
    const param: IAddrInfo = {
      id: data.id,
      name: data.name,
      address: data.address,
      contactName: data.contactName,
      contactPhone: data.contactPhone,
    };
    if (this.isNew()) {
      this.addAddr(param);
    } else {
      this.updateAddr(param);
    }
  }

  onSubmit(address: AddressInfo) {
    const isValid = this.validInfo(address);
    if (!isValid) {
      return;
    }
    this.savaData(address);
  }

  addAddr(data: IAddrInfo) {
    addAddress(data).then(() => {
      this.afterSave();
    })
  }

  updateAddr(data: IAddrInfo) {
    updateAddress(data).then(() => {
      this.afterSave();
    })
  }

  afterSave() {
    CommonUtils.hideLoading();
    RouterModule.pop();
    this.queryList();
  }

  deleteConfirm(id: number) {
    CommonUtils.openConfirmDialog({
      content: '是否删除此地址',
      priBtnV: '取消',
      secBtnV: '删除',
      secBtnRole: ButtonRole.ERROR,
      confirm: () => {
        this.deleteAddr(id);
      },
      cancel: () => {
        this.listScroller.closeAllSwipeActions();
      },
    })
  }

  deleteAddr(id: number) {
    deleteAddress(id).then(() => {
      this.listScroller.closeAllSwipeActions();
      this.queryList();
    })
  }
}