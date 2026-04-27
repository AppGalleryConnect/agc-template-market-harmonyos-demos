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

import { ManageStatus, ToolType } from '../constant/Enum';
import { ToolTypeModule } from '../model/Index';
import { HomeVM } from '../viewmodel/HomeVM';
import { abilityAccessCtrl } from '@kit.AbilityKit';

@ComponentV2
export struct ToolsContainer {
  vm: HomeVM = HomeVM.instance;
  @Local text: string = '拖拽移动位置';
  @Local context: Context = this.getUIContext().getHostContext() as Context;
  @Param manageStatus: ManageStatus = ManageStatus.NONE;
  @Param toolList: ToolTypeModule[] = [];

  @Computed
  get manageIcon() {
    if (this.manageStatus === ManageStatus.ADD) {
      return $r('app.media.tool_add');
    } else if (this.manageStatus === ManageStatus.DELETE) {
      return $r('app.media.tool_delete');
    }
    return '';
  }

  aboutToDisappear(): void {
    this.vm.homeToolTypes.list = JSON.stringify(this.vm.homeToolList);
    this.vm.calculatorToolTypes.list = JSON.stringify(this.vm.calculatorToolList);
    this.vm.lifeToolListTypes.list = JSON.stringify(this.vm.lifeToolList);
  }

  async requestPermissionsFn(): Promise<void> {
    let atManager = abilityAccessCtrl.createAtManager();
    if (this.context) {
      let res = await atManager.requestPermissionsFromUser(this.context, ['ohos.permission.CAMERA']);
      for (let i = 0; i < res.permissions.length; i++) {
        if ('ohos.permission.CAMERA' === res.permissions[i] && res.authResults[i] === 0) {
          this.vm.hasPermission = true;
          this.vm.pathStack.pushDestinationByName('ARMeasure', null);
        }
      }
    }
  }

  @Builder
  dragBuilder(tool: ToolTypeModule) {
    Column() {
      this.toolCard(tool);
    }.size({ width: 120, height: 120 }).backgroundColor('rgba(10, 89, 247, 0.05)').borderRadius(16);
  }

  @Builder
  toolCard(tool: ToolTypeModule) {
    Column({ space: 12 }) {
      Image(tool?.icon).size({ height: 48, width: 48 }).draggable(false);
      Text(tool?.title).fontSize(14);
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  build() {
    if (this.toolList.length !== 0) {
      Grid() {
        ForEach(this.toolList, (item: ToolTypeModule, index: number) => {
          GridItem() {
            Stack({ alignContent: Alignment.TopEnd }) {
              this.toolCard(item);

              if (this.manageStatus !== ManageStatus.NONE) {
                Image(this.manageIcon)
                  .size({ width: 16, height: 16 })
                  .alignSelf(ItemAlign.End)
                  .margin({ top: 4, right: 4 });
              }
            }
            .border({ width: 1, radius: 8, color: $r('sys.color.white') })
            .backgroundColor('rgba(10, 89, 247, 0.05)')
            .border({ width: 0 })
            .width('100%')
            .height(104);
          }.onClick(() => {
            if (item.id === ToolType.AR_MEASURE) {
              if (!this.vm.hasPermission) {
                this.requestPermissionsFn();
              } else {
                this.vm.handleToolLayout(this.getUIContext(), this.manageStatus, item, this.toolList, index);
              }
            } else {
              this.vm.handleToolLayout(this.getUIContext(), this.manageStatus, item, this.toolList, index);
            }
          });
        }, (item: ToolTypeModule) => JSON.stringify(item));
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .padding(12)
      .supportAnimation(true)
      .edgeEffect(EdgeEffect.Spring)
      .editMode(this.manageStatus === ManageStatus.DELETE ? true : false)
      .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
        return this.dragBuilder(this.toolList[itemIndex]);
      })
      .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number,
        isSuccess: boolean) => {
        if (!isSuccess || insertIndex >= this.toolList.length || itemIndex === -1 || insertIndex === -1) {
          return;
        }
        this.vm.changeIndex(itemIndex, insertIndex);
      });
    } else {
      Text('暂无可选功能')
        .fontSize(12)
        .opacity(0.6)
        .padding(12)
        .width('100%')
        .textAlign(TextAlign.Center);
    }
  }
}