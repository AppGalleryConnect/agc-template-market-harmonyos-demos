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

import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
import { CommonConstants, GridRowColSetting, RouterModule } from 'lib_foundation';

@Builder
export function OfficialWebBuilder() {
  OfficialWeb()
}

@Component
export struct OfficialWeb {
  @State breakpoint: string = '';
  @State controller: AtomicServiceWebController = new AtomicServiceWebController();

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Column() {
            AtomicServiceWeb({
              src: $rawfile('official_web.html'),
              controller: this.controller,
              navPathStack: RouterModule.getStack(),
            })
          }
          .padding({
            top: 8,
            bottom: 8,
            left: GridRowColSetting.getPageMargin(this.breakpoint),
            right: GridRowColSetting.getPageMargin(this.breakpoint)
          })
          .height(CommonConstants.FULL_PERCENT)
          .borderRadius(20)
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .title('官网', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
