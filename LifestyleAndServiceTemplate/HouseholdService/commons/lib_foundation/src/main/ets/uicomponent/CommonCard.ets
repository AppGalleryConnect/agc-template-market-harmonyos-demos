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

import { CommonConstants } from '../common/Constant';

@ComponentV2
export struct CardContainer {
  @Param title: string = '';
  @BuilderParam buildParam: () => void;

  build() {
    Column({ space: 4 }) {
      Text(this.title).fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium)
      if (this.buildParam) {
        this.buildParam()
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }
}