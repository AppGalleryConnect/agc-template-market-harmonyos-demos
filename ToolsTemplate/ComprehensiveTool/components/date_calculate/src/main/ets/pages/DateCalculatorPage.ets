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

import { DateToolsCalculate } from '../components/DateToolsCalculate';
import { TitleBar } from '../components/TitleBar';
import { setPathStack } from '../utils/Route';

@Builder
export function DateCalculatorPageBuilder() {
  DateCalculatorPage();
}

@ComponentV2
export struct DateCalculatorPage {
  build() {
    NavDestination() {
      Column() {
        TitleBar({ title: '日期计算' });
        Column() {
          DateToolsCalculate({
            startDate: new Date('2025-5-28'),
            buttonColor: $r('sys.color.background_emphasize'),
            textColor: $r('sys.color.font_on_primary'),
          });
        };
      }
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }.hideTitleBar(true).onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }
}
