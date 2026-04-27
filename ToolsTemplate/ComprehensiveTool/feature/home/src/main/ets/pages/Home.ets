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

import { MenuItemContentModifier } from '../components/SelectMenuItemBuilder';
import { ToolsContainer } from '../components/ToolsContainer';
import { ManageStatus } from '../constant/Enum';
import { TOOL_TYPE_MODULES } from '../constant/Index';
import { ToolTypeModule } from '../model/Index';
import { HomeVM } from '../viewmodel/HomeVM';

@Builder
export function HomeBuilder() {
  Home();
}

@ComponentV2
export struct Home {
  @Param pathStack: NavPathStack = new NavPathStack()
  vm: HomeVM = HomeVM.instance;

  aboutToAppear(): void {
    this.vm.pathStack = this.pathStack;
    this.vm.init();
  }

  @Computed
  get allTypes() {
    let types = TOOL_TYPE_MODULES.map((item: ToolTypeModule) => {
      let type: SelectOption = { value: '' };
      type.value = item.title;
      type.icon = $r('app.media.checked');
      return type;
    });
    return types;
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row() {
            Select(this.allTypes)
              .selected(this.vm.selectedToolType.index)
              .value(`默认打开: ${this.vm.selectedToolType.title}`)
              .fontColor($r('sys.color.font_primary'))
              .height(40)
              .borderRadius($r('sys.float.corner_radius_level10'))
              .selectedOptionFont({ weight: FontWeight.Medium })
              .optionFont({ weight: FontWeight.Medium })
              .optionWidth(224)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .menuItemContentModifier(new MenuItemContentModifier())
              .onSelect((index: number, text?: string | undefined) => {
                let type = TOOL_TYPE_MODULES.find((item: ToolTypeModule) => item.id === index);
                this.vm.selectedToolType.title = text ?? '';
                this.vm.selectedToolType.index = index;
                this.vm.selectedToolType.url = type?.url ?? '';
              });
          }.justifyContent(FlexAlign.Start);

          Button('编辑')
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .height(40)
            .onClick(() => {
              this.vm.pathStack.pushPathByName('ToolManagement', null);
            });
        }
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('sys.color.white'));
      Scroll() {
          ToolsContainer({ toolList: this.vm.homeToolList, manageStatus: ManageStatus.NONE })
        }
      }.height('calc(100% - 56vp)').align(Alignment.Start)
    }.hideTitleBar(true)
  }
}