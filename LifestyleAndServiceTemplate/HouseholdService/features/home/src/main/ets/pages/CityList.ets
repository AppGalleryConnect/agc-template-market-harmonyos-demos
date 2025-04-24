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

import { CitySearchController, UICitySelect } from 'city_select'
import { CommonConstants, RouterModule } from 'utils'
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function CityListBuilder() {
  CityList()
}

@ComponentV2
export struct CityList {
  @Local isShowSearch: boolean = false;
  controller: CitySearchController = new CitySearchController();

  build() {
    NavDestination() {
      Column() {
        UICitySelect({
          controller: this.controller,
          goBack: (citySelected?: string) => {
            RouterModule.pop(citySelected);
          },
          syncShowSearchRsp: (isShow) => {
            this.isShowSearch = isShow;
          },
        })
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .title('服务地址', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor(Color.White)
    .onBackPressed(() => {
      if (this.isShowSearch) {
        this.controller.clearParam();
        return true;
      }
      return false;
    })
  }
}
