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
import { BaseLayout } from '../components/BaseLayout';
import { ControllerPageVM } from '../viewmodel/ControllerPageVM';

@Builder
export function ControllerPageBuilder() {
  ControllerPage();
}

@ComponentV2
export struct ControllerPage {
  vm: ControllerPageVM = ControllerPageVM.instance;

  aboutToAppear(): void {
    this.vm.getParam()
  }


  build() {
    NavDestination() {
      BaseLayout({
        onStatusChange: (data) => {
          this.vm.updateMyControl(data)
          this.vm.getInfraredInfo(data);
        },
      });
    }.hideBackButton(true);
  }
}
