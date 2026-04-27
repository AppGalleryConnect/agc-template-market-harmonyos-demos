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

import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';

@ComponentV2
export struct FormAddress {
  @Once @Param value: ResourceStr = '';
  @Event onChooseLocation: (value: ResourceStr) => void;

  build() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_LOCATION,
        label: this.value || '请选择',
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.value ? $r('sys.color.font_primary') : $r('app.color.common_grey'))
            .backgroundColor(Color.Transparent)
            .padding(0)
            .stateEffect(false),
        },
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onChooseLocation((err, data) => {
          if (err) {
            return;
          }
          this.value = data.name;
          this.onChooseLocation(data.name);
        }),
    })
  }
}
