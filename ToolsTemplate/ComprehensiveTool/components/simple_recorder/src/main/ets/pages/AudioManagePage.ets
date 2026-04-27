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
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { TitleBar } from '../components/TitleBar';
import { getInstance, RouterMap } from '../util/Route';
import { AudioManagePageVM } from '../viewModels/AudioManagePageVM';
import { AudioInfo, RouteParams } from '../model/Index';
import { EditNameDialog } from '../components/EditNameDialog';

@Builder
export function AudioManagePageBuilder() {
  AudioManagePage();
}

@ComponentV2
export struct AudioManagePage {
  vm: AudioManagePageVM = AudioManagePageVM.instance;
  editController: CustomDialogController = new CustomDialogController({
    builder: this.editDialog,
    customStyle: true,
  });
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: this.vm.tips,
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
          if (this.vm.ids.length > 0) {
            this.vm.batchDelete();
          } else {
            this.vm.removeAudio(this.vm.delId);
          }
          this.dialogControllerConfirm.close();
        },
      },
    }),
  });

  aboutToDisappear(): void {
    this.vm.initData();
  }

  @Builder
  editDialog() {
    EditNameDialog({
      text: this.vm.targetFileName,
      onChange: (text: string) => {
        this.vm.targetFileName = text;
      },
      onSave: () => {
        if (this.vm.targetFileName) {
          this.vm.myAudio.renameAudio(this.vm.targetId, this.vm.targetFileName);
          this.vm.expandIndex = -1;
          this.editController.close();
        } else {
          promptAction.showToast({ message: '请输入文件名！' });
        }
      },
      onCancel: () => {
        this.vm.targetFileName = '';
        this.editController.close();
      },
    });
  }

  @Builder
  itemEnd(id: string) {
    Row() {
      Text('重命名')
        .btnExtend()
        .backgroundColor($r('sys.color.background_emphasize'))
        .onClick(() => {
          this.vm.targetFileName = this.vm.myAudio.getAudioById(id)
            .fileName
            .split('.')[0];
          this.vm.targetId = id;
          this.editController.open();
        });

      Text('删除')
        .btnExtend()
        .borderRadius({
          topRight: 16,
          bottomRight: 16,
        })
        .backgroundColor($r('sys.color.warning'))
        .onClick(() => {
          this.vm.delId = id;
          this.vm.tips = '是否删除此文件？';
          this.dialogControllerConfirm.open();
        });
    };
  }

  build() {
    NavDestination() {
      TitleBar({
        title: '文件管理',
        isShowEdit: true,
        onEdit: () => {
          this.vm.isActive = true;
          this.vm.expandIndex = -1;
        },
        onCancel: () => {
          this.vm.isActive = false;
          this.vm.ids = [];
        },
      });
      if (this.vm.myAudio.list.length) {
        List({ space: 12 }) {
          ForEach(this.vm.myAudio.list, (item: AudioInfo, index) => {
            ListItem() {
              Row({ space: 12 }) {
                if (this.vm.isActive) {
                  Checkbox()
                    .select(this.vm.ids.some((id) => id === item.id))
                    .onChange((res) => {
                      if (res) {
                        this.vm.addId(item.id);
                      } else {
                        this.vm.removeId(item.id);
                      }
                    });
                }
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
                .padding(12)
                .padding({ left: this.vm.expandIndex === index ? 100 : 12, right: 12 })
                .animation({
                  duration: 300,
                  curve: Curve.Linear,
                  playMode: PlayMode.Normal,
                })
                .onClick(() => {
                  if (!this.vm.isActive) {
                    const params: RouteParams = {
                      id: item.id,
                      isOperation: false,
                    };
                    getInstance().pushPathByName(RouterMap.OPERATION, params);
                  }
                });
              };
            }
            .borderRadius({
              topLeft: 16,
              bottomLeft: 16,
              topRight: this.vm.isActive ? 0 : 16,
              bottomRight: this.vm.isActive ? 0 : 16,
            })
            .clip(true)
            .swipeAction({
              end: {
                builder: this.vm.isActive ? undefined : () => {
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
          }, (item: AudioInfo) => item.id + item.fileName);


        }
        .layoutWeight(1)
        .padding({
          top: 8,
          bottom: 8,
          left: 16,
          right: this.vm.isActive ? 0 : 16,
        })
        .scrollBar(BarState.Off);

        if (this.vm.isActive) {
          Row() {
            Column({ space: 3 }) {
              Image($r('app.media.ic_audio_clear')).width(20);
              Text('全选')
                .fontSize($r('sys.float.Caption_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(14);
            }.onClick(() => {
              this.vm.addAllId();
            });

            Column({ space: 3 }) {
              Image(this.vm.ids.length > 0 ? $r('app.media.ic_audio_remove') : $r('app.media.ic_audio_remove_disable'))
                .width(20);
              Text('删除')
                .fontSize($r('sys.float.Caption_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor(this.vm.ids.length > 0 ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
                .lineHeight(14);
            }.onClick(() => {
              if (this.vm.ids.length > 0) {
                this.vm.getTips();
                this.dialogControllerConfirm.open();
              }
            });

          }.width('100%').height(48).justifyContent(FlexAlign.SpaceAround);
        }

      } else {
        Text('——暂无录音——').margin({ top: 40 }).fontColor($r('sys.color.font_secondary'));
      }

    }.backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true);

  }
}


@Extend(Text)
function btnExtend() {
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_on_primary'))
  .textAlign(TextAlign.Center)
  .width(64)
  .height(72);
}
