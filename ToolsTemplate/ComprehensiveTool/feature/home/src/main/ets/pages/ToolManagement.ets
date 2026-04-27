/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ToolsContainer } from '../components/ToolsContainer';
import { ManageStatus } from '../constant/Enum';
import { HomeVM } from '../viewmodel/HomeVM';

@Builder
export function ToolManagementBuilder() {
  ToolManagement();
}

@ComponentV2
export struct ToolManagement {
  vm: HomeVM = HomeVM.instance;

  @Builder
  homeToolBuilder() {
    Column() {
      Text('首页显示')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 12, top: 12 });

      Text('您可以长按拖动以指定出现在[首页]的功能')
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: 12, bottom: 16 })
        .padding({ left: 12 });

      ToolsContainer({ toolList: this.vm.homeToolList, manageStatus: ManageStatus.DELETE });
    };
  }

  @Builder
  calculatorBuilder() {
    Column() {
      Text('计算')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 12, top: 12 });

      ToolsContainer({ toolList: this.vm.calculatorToolList, manageStatus: ManageStatus.ADD });
    };
  }

  @Builder
  lifeToolBuilder() {
    Column() {
      Text('生活')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 12, top: 12 });

      ToolsContainer({ toolList: this.vm.lifeToolList, manageStatus: ManageStatus.ADD });
    };
  }

  build() {
    NavDestination() {
      Column() {
        List({ space: 12 }) {
          ListItem() {
            this.homeToolBuilder();
          };

          ListItem() {
            this.calculatorBuilder();
          };

          ListItem() {
            this.lifeToolBuilder();
          };
        }.nestedScroll({
          scrollForward: NestedScrollMode.SELF_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        });
      }.width('100%').height('calc(100% - 28vp)');
    }.title('管理');
  }
}