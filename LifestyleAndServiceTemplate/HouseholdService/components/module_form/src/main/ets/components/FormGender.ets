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

import { GENDER_OPTIONS } from '../common/Constant';

@ComponentV2
export struct FormGender {
  @Once @Param selectIndex: number = 0;
  @Event onGenderSelect: (value: number) => void;

  build() {
    Row({ space: 20 }) {
      ForEach(GENDER_OPTIONS, (v: string, index: number) => {
        Text(v)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .focusOnTouch(true)
          .width(52)
          .height(24)
          .textAlign(TextAlign.Center)
          .borderWidth(1)
          .borderColor(this.selectIndex === index ? '#007DFF' : $r('app.color.grey_20'))
          .borderRadius(21)
          .onClick(() => {
            this.selectIndex = index;
            this.onGenderSelect(this.selectIndex);
          })
      }, (v: string) => v)
    }
  }
}
