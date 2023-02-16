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

import router from '@system.router';
import Logger from '@ohos.hilog';
import agconnect from '@hw-agconnect/api-ohos';
import "@hw-agconnect/core-ohos";
import "@hw-agconnect/credential-ohos";
import "@hw-agconnect/auth-ohos";
import '@hw-agconnect/auth-types-ohos';
import { domain } from '../constants';

const TAG = new String($r('app.string.Auth')).toString();

// 认证服务工具类
export class auth {
  constructor(context) {
    this.initAgc(context);
  }

  // 初始化SDK
  private async initAgc(context) {
    try {
      agconnect.instance().init(context);
      let credentialService = agconnect.credential();
      await credentialService!.removeToken();
      Logger.info(domain, TAG, "init AGC SDK success");
    } catch (err) {
      Logger.error(domain, TAG, "init AGC SDK failed " + err);
    }
  }

  // 获取认证对象
  async getAuthUser() {
    try {
      let user = await agconnect.auth().getCurrentUser();
      return user;
    } catch (err) {
      Logger.error(domain, TAG, "getUid failed " + err);
    }
  }

  // 注销
  signOut() {
    agconnect.auth().signOut().then(() => {
      router.push({
        uri: 'pages/Main'
      })
    })
  }
}



