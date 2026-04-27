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
import { AppPrivacyUtils } from 'common';
import { RouterModule } from '../model/TabBarInfo';

@Entry
@ComponentV2
struct Index {
  @Local privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  @Provider('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear() {
    RouterModule.setStack(this.mainPathStack)
    this.privacyImpl.subscribe();
    if (!this.privacyImpl.CONFIG_SHOW_HOME && !this.privacyImpl.agreeFlag) {
      // 未同意隐私协议，不进入首页
      return;
    }
    this.funcCore();
  }

  aboutToDisappear(): void {
    this.privacyImpl.unSubscribe();
  }

  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange() {
    if (!this.privacyImpl.CONFIG_SHOW_HOME && this.privacyImpl.agreeFlag) {
      this.funcCore();
    }
  }

  funcCore() {
    // 跳转首页
    this.mainPathStack.replacePathByName('Main', null);
  }

  build() {
    Navigation(this.mainPathStack) {
    }.hideNavBar(true);
  }
}