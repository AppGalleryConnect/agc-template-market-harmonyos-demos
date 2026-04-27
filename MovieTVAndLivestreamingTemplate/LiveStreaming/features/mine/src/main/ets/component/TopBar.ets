/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

@ComponentV2
export struct TopBar {
  @Param title: string | Resource = '';
  @Param onClickBack: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize($r('app.float.vp_24'))
          .fontColor([$r('sys.color.icon_primary')])
          .onClick(() => {
            this.onClickBack()
          })
      }
      .justifyContent(FlexAlign.Center)
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding($r('app.float.vp_8'))
      .borderRadius($r('app.float.vp_40'))

      Text(this.title)
        .fontSize(20)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('app.float.vp_8') })
    }
  }
}
 