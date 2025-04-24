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

import { AtomicServiceWeb, AtomicServiceWebController, LengthMetrics } from '@kit.ArkUI';
import { CommonConstants, RouterModule } from 'utils';

@Builder
export function OfficialWebBuilder() {
  OfficialWeb()
}

@Component
export struct OfficialWeb {
  @State controller: AtomicServiceWebController = new AtomicServiceWebController();

  build() {
    NavDestination() {
      Column() {
        AtomicServiceWeb({
          src: $rawfile('official_web.html'),
          controller: this.controller,
          navPathStack: RouterModule.getStack(),
        })
      }
      .padding(10)
      .height(CommonConstants.FULL_PERCENT)
      .borderRadius(4)
    }
    .title('官网', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
