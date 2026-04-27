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
import { Constants } from '../common/Constant';

@ComponentV2
export struct CityTag {
  @Require @Param city: string;

  build() {
    Button() {
      Text(this.city)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .width(Constants.FULL_PERCENT)
        .textAlign(TextAlign.Center)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .constraintSize({ maxWidth: '57vp' })
    }
    .padding({
      top: Constants.PADDING_XXS,
      bottom: Constants.PADDING_XXS,
      right: Constants.PADDING_S,
      left: Constants.PADDING_S
    })
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .height(Constants.CITY_TAG_HEIGHT)
    .constraintSize({ minWidth: Constants.MIN_BUTTON_WIDTH })
  }
}
