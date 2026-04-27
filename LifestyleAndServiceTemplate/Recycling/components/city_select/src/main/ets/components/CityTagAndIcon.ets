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
export struct CityTagAndIcon {
  @Require @Param city: string;
  @Local showPopup: boolean = false;

  build() {
    Button() {
      Row({ space: Constants.SPACE_XS }) {
        SymbolGlyph($r('sys.symbol.local_fill'))
          .width(Constants.ICON_WIDTH)
          .height(Constants.ICON_WIDTH)
          .fontColor([$r('sys.color.icon_emphasize')])

        Text(this.city)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .maxLines(1)
          .ellipsisMode(EllipsisMode.END)
          .constraintSize({ maxWidth: '57vp' })
      }
    }
    .constraintSize({
      maxWidth: Constants.BUTTON_WIDTH + Constants.PADDING_S * 2,
      minWidth: Constants.BUTTON_WIDTH
    })
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .height(Constants.CITY_TAG_HEIGHT)
    .padding({
      top: Constants.PADDING_XS,
      bottom: Constants.PADDING_XS,
      right: Constants.PADDING_S,
      left: Constants.PADDING_S
    })
    .gesture(
      LongPressGesture({ duration: 500 })
        .onAction(() => {
          this.showPopup = true
        })
        .onActionEnd(() => {
          this.showPopup = false
        })
    )
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Cancel) {
        this.showPopup = false
      }
    })
    .bindPopup(this.showPopup, {
      message: this.city,
    })
  }
}