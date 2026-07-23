/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { QuickLogin, UserInfo } from 'login_info';
import { GlobalContextUtils, RouterMap, RouterModule } from 'commonlib';

@ComponentV2
export struct LoginPage {
  // 半模态or全模态
  isBindContentCover: boolean = false;
  @Local nextRouter: string = '';

  aboutToAppear(): void {
    let temp = RouterModule.getNavParam({ url: RouterMap.LOGIN_PAGE });
    if (temp) {
      this.nextRouter = temp as string;
      this.isBindContentCover = temp as boolean;
    }
  }

  build() {
    Column() {
      QuickLogin({
        isBindContentCover: this.isBindContentCover,
        icon: $r('app.media.exam_icon_login'),
        loginBtnBgColor: '#4B5CC4',
        appName: '备考',
        // 登录回调方法
        onLoginWithHuaweiID: (flag: boolean, phone?: string) => {
          RouterModule.pop(false);
          let prop: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())! as UserInfo;
          if (!prop.name) {
            prop.name = '华为用户';
          }
          prop.isLogin = true;
          prop.id = 0;
          prop.cellphone = phone ?? '177******96';
          prop.address = 'xxx省xxx市';
          if (flag) {
            GlobalContextUtils.showToast({ message: '登录成功' });
          } else {
            GlobalContextUtils.showToast({ message: 'mock登录' });
            if(this.nextRouter && typeof this.nextRouter === 'string') {
              RouterModule.push({ url: this.nextRouter })
            }
          }
        },
        // 备考隐私协议方法
        onPrivacyPolicy: () => {
          RouterModule.replace({ url: RouterMap.PRIVACY_PAGE });
        },
        // 用户服务协议方法
        onServicePolicy: () => {
          RouterModule.replace({ url: RouterMap.TERMS_SERVICE_PAGE });
        },
        // 华为账号用户认证协议
        onHYAccountRouter: () => {
          RouterModule.replace({ url: RouterMap.AUTHENTICATION_PAGE });
        },
        // 模态消失回调
        shouldDismiss: () => {
          let paths: string[] = RouterModule.stack.getAllPathName();
          let isExit = paths.includes(RouterMap.LOGIN_PAGE);
          if (isExit) {
            RouterModule.pop();
          }
        }
      });
    }
    .height('100%')
    .width('100%')
  }
}

@Builder
export function LoginPageBuilder() {
  LoginPage();
}