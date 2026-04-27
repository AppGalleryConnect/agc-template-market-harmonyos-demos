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
import { TitleBar } from '../components/TitleBar';
import { getInstance, RouterMap } from '../util/Route';
import { ListPageVM } from '../viewModels/ListPageVM';
import { AudioInfo, RouteParams } from '../model/Index';

@Builder
export function ListPageBuilder() {
  ListPage();
}

@ComponentV2
export struct ListPage {
  vm: ListPageVM = ListPageVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '是否删除此文件？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.dialogControllerConfirm.close();
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.removeAudio();
          this.dialogControllerConfirm.close();
        },
      },
    }),
  });

  @Builder
  itemEnd(id: string) {
    Row() {
      Text('删除')
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .textAlign(TextAlign.Center)
        .width(64)
        .height(72)
        .borderRadius({
          topRight: 16,
          bottomRight: 16,
        })
        .backgroundColor($r('sys.color.warning'))
        .onClick(() => {
          this.vm.delId = id;
          this.dialogControllerConfirm.open();
        });
    };
  }

  aboutToAppear(): void {
    this.vm.getNextUrl();
  }

  aboutToDisappear(): void {
    this.vm.expandIndex = -1;
  }

  build() {
    NavDestination() {
      TitleBar({
        title: this.vm.navTitle,
      });
      if (this.vm.myAudio.list.length) {
        List({ space: 12 }) {
          ForEach(this.vm.myAudio.list, (item: AudioInfo, index) => {
            ListItem() {
              Row({ space: 16 }) {
                Image($r('app.media.ic_play_circle')).width(24);
                Text(item.fileName)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Subtitle_M'))
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .layoutWeight(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              .height(72)
              .width('100%')
              .borderRadius({
                topLeft: 16,
                bottomLeft: 16,
              })
              .backgroundColor($r('sys.color.comp_background_primary'))
              .padding({ left: this.vm.expandIndex === index ? 36 : 12, right: 12 })
              .animation({
                duration: 300,
                curve: Curve.Linear,
                playMode: PlayMode.Normal,
              });
            }.onClick(() => {
              if (this.vm.nextRoute === RouterMap.OPERATION) {
                const params: RouteParams = {
                  id: item.id,
                  isOperation: true,
                };
                getInstance().pushPathByName(this.vm.nextRoute, params);
              } else {
                getInstance().pushPathByName(this.vm.nextRoute, item.id);
              }
            })
            .borderRadius(16)
            .clip(true)
            .swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(item.id);
                },
                onStateChange: (state: SwipeActionState) => {
                  if (state === SwipeActionState.COLLAPSED) {
                    this.vm.expandIndex = -1;
                  }
                  if (state === SwipeActionState.EXPANDED) {
                    this.vm.expandIndex = index;
                  }
                },
              }, edgeEffect: SwipeEdgeEffect.Spring,
            });
          }, (item: AudioInfo) => item.id);


        }
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .scrollBar(BarState.Off);
      } else {
        Text('——暂无录音——').margin({ top: 40 }).fontColor($r('sys.color.font_secondary'));
      }

    }.backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true);

  }
}


