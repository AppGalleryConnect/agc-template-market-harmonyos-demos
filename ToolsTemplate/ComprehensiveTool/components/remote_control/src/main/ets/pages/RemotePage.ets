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
import { AlertDialog } from '@kit.ArkUI';
import { RemotePageVM } from '../viewmodel/RemotePageVM';
import { ControlInfo } from '../model/Index';
import { getInstance, setPathStack } from '../components/RouteModule';

@Builder
export function RemotePageBuilder() {
  RemotePage();
}

@ComponentV2
export struct RemotePage {
  vm: RemotePageVM = RemotePageVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要删除吗？',
      primaryButton: {
        value: '取消',
        action: () => {

        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.myControl.removeControl(this.vm.delId);
        },
      },
    }),
  });

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('我的设备')
          .width('100%')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold);
        Grid() {
          GridItem() {
            Column({ space: 8 }) {
              Image($r('app.media.ic_add')).width(16).height(16);
              Text('添加设备').fontColor('#0A59F7').fontSize($r('sys.float.Body_S')).fontWeight(FontWeight.Regular);
            }.cardExtend().padding(25).onClick(() => {
              getInstance().pushPathByName('BrandPage', null);
            });
          };

          ForEach(this.vm.myControl.list, (item: ControlInfo) => {
            GridItem() {
              Column({ space: 8 }) {
                Image($r('app.media.ic_air')).width(50).height(38);
                Text(item.name)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Regular)
                  .fontWeight(FontWeight.Medium)
                  .constraintSize({ maxWidth: '100%' })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }.cardExtend().padding(12);
            }.gesture(
              // 以下组合手势为顺序识别，当长按手势事件未正常触发时则不会触发拖动手势事件
              GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false })
                .onAction(() => {
                  this.vm.delId = item.id;
                  this.dialogControllerConfirm.open();
                }),
                TapGesture({ count: 1 }).onAction(() => {
                  getInstance().pushPathByName('ControllerPage', item);
                })));

          }, (item: ControlInfo) => item.id + item.name);


        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });

      }.width('100%').layoutWeight(1).padding({ left: 16, right: 16, top: 24 });

    }.backgroundColor($r('sys.color.background_secondary')).title('Hi，万能空调遥控器').onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }
}

@Extend(Column)
function cardExtend() {
  .height(90)
  .width('100%')
  .borderRadius(16)
  .backgroundColor($r('sys.color.comp_background_list_card'));
}
