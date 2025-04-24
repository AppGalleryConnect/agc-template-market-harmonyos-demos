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

import { RouterModule } from '../router/RouterModule';

/**
 * 自定义返回按钮，模拟系统NavDestination
 */
@ComponentV2
export struct UIBackBtn {
  @Event clickEvent: () => void = () => {
    RouterModule.pop();
  };

  build() {
    Button() {
      Image($r('app.media.ic_public_arrow_left')).width(16).height(16)
    }
    .width(40)
    .height(40)
    .backgroundColor('#0C000000')
    .margin({ left: 16 })
    .onClick(() => {
      this.clickEvent();
    })
  }
}