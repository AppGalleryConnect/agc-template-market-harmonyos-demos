/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Logger from '@ohos.hilog';
import agconnect from '@hw-agconnect/api-ohos';
import "@hw-agconnect/core-ohos";
import "@hw-agconnect/credential-ohos";
import "@hw-agconnect/function-ohos";
import { domain } from '../constants';

const TAG = new String($r('app.string.Function')).toString();

// 云函数工具类
export class Function {
  static _instance: Function;

  constructor(context) {
    this.initAgc(context);
  }

  static instance(context) {
    if (!Function._instance) {
      Function._instance = new Function(context);
    }
    return Function._instance;
  }

  private async initAgc(context) {
    try {
      agconnect.instance().init(context);
      let credentialService = agconnect.credential();
      await credentialService!.removeToken();
      Logger.info(domain, TAG, "init AGC SDK success");
    } catch (err) {
      Logger.error(domain, TAG, "initAgcSDK failed" + err);
    }
  }

  // 购物车、订单、地址云函数
  async call(trigger, token, operation, params) {
    let body = {
      "token": token,
      "operation": operation,
      "params": params
    }
    try {
      let functionCallable = agconnect.function().wrap(trigger);
      let functionResult = await functionCallable.call(body);
      return functionResult.getValue().result;
    }
    catch (err) {
      Logger.error(domain, TAG, 'operation with token ' + operation + 'catch a err: ' + err);
    }
  }

  // 首页、搜索云函数
  async callWithParams(trigger, operation, params) {
    let body = {
      "operation": operation,
      "params": params
    }
    try {
      let functionCallable = agconnect.function().wrap(trigger);
      let functionResult = await functionCallable.call(body);
      return functionResult.getValue().result;
    }
    catch (err) {
      Logger.error(domain, TAG, 'operation ' + operation + 'catch a err: ' + err);
    }
  }
}