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

@ComponentV2
export struct SingleBtn {
  @Param city: string = '';
  @Param fgColor: ResourceColor = Color.Black;
  @Event onClickEvent: () => void = () => {
  };

  build() {
    Button() {
      Text(this.city)
        .fontSize(14)
        .fontColor(this.fgColor)
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .constraintSize({ minWidth: 44 })
    }
    .backgroundColor($r('app.color.grey_5'))
    .padding({
      top: 4,
      bottom: 4,
      left: 8,
      right: 8,
    })
    .onClick(() => {
      this.onClickEvent();
    })
  }
}