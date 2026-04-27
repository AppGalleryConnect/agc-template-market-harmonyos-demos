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
import { AppStorageV2 } from '@kit.ArkUI';
import { address1, address2, IAddrInfo } from 'module_base';
import { TemplateApi } from '../http/Api';
import { IGoods, ITemplate } from '../http/Type';

@ObservedV2
export class TemplateInfo {
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace sendAddress: IAddrInfo = address1
  @Trace getAddress: IAddrInfo = address2
  @Trace goods: IGoods = {
    id: 1,
    name: '文件',
    weight: 1
  }
  @Trace shippingMethod: number = 1
  @Trace paymentMethod: number = 1
  @Trace weight: number = 1
  @Trace time: string = '8:00 - 9:00'
}

export class CurrentAppStorage {
  static templateInfo: TemplateInfo = AppStorageV2.connect(TemplateInfo, () => new TemplateInfo())!;

  static reset() {
    CurrentAppStorage.templateInfo = new TemplateInfo()
  }
}

@ObservedV2
export class TemplateList {
  @Trace list: ITemplate[] = TemplateApi.TEMPLATE_LIST;
}


/**
 * AppStorageV2应用全局缓存库
 */
export class AppStorageBank {
  static templateList: TemplateList = AppStorageV2.connect(TemplateList, () => new TemplateList())!;

  static updateTemplateList(list: ITemplate[]) {
    AppStorageBank.templateList.list = list;
  }
}


