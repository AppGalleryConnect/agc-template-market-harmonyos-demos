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
import { getStack, setStack } from '../common/Route';
import { StandardCalculator } from '../components/StandardCalculator';
import { BreakpointSystem } from '../utils/BreakpointSystem';

@Builder
export function HomePageBuilder() {
  HomePage();
}

@ComponentV2
export struct HomePage {
  aboutToAppear(): void {
    BreakpointSystem.register(this.getUIContext())
  }

  aboutToDisappear(): void {
    BreakpointSystem.unregister()
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          StandardCalculator({ routerModule: getStack() });
          Blank().layoutWeight(1)
        }
      }
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .padding({ left: 8, right: 8, bottom: 8 })
      .scrollBar(BarState.Off)
    }.title('计算器')
    .onReady((ctx) => {
      setStack(ctx.pathStack);
    });
  }
}
