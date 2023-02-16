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

import { SettingProps } from '../model';
import { Constants } from '../constants/Constants';

@Component
export struct Setting {
  private setting: SettingProps

  @Styles itemMargin(){
    .margin({ left: $r('app.float.setting_margin_left'), right: $r('app.float.setting_margin_right') })
  }

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.setting.text).fontSize($r('app.float.font_large'))
        Text('>').fontSize($r('app.float.font_small')).fontColor(Color.Gray)
      }.height(Constants.SETTINGITEM_HIGH)
    }
    .onClick(() => {
      this.setting.click()
    })
    .itemMargin()
  }
}