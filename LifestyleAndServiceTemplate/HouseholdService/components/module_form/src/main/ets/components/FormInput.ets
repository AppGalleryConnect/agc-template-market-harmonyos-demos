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
export struct FormInput {
  @Param inputType: InputType = InputType.Normal;
  @Param value: ResourceStr = '';
  @Event onInputChange: (value: ResourceStr) => void;

  build() {
    TextInput({ text: this.value, placeholder: '请填写' })
      .type(this.inputType)
      .placeholderFont({ size: $r('sys.float.Body_L') })
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor(Color.Transparent)
      .layoutWeight(1)
      .textAlign(TextAlign.End)
      .padding(0)
      .borderRadius(0)
      .onChange((value) => {
        this.onInputChange(value);
      })
  }
}
