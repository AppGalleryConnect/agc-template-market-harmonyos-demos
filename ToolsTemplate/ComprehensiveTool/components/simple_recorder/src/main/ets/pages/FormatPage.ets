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
import { AlertDialog, LoadingDialog } from '@kit.ArkUI';
import { TitleBar } from '../components/TitleBar';
import { FormatPageVM } from '../viewModels/FormatPageVM';
import { BtnBar } from '../components/BtnBar';
import { getInstance } from '../util/Route';

@Builder
export function FormatPageBuilder() {
  FormatPage();
}

@ComponentV2
export struct FormatPage {
  vm: FormatPageVM = FormatPageVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '当前转换音频未保存，是否继续退出？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.dialogControllerConfirm.close();
        },
      },
      secondaryButton: {
        value: '确认',
        action: () => {
          this.dialogControllerConfirm.close();
          // 清除临时文件
          this.vm.clearFile();
          getInstance().pop();

        },
      },
    }),
  });
  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '音频处理中...',
    })
  })

  aboutToAppear(): void {
    this.vm.getRouteParam();
  }

  aboutToDisappear(): void {
    //   强制退出时清除数据
    this.vm.clearFile();
  }

  build() {
    NavDestination() {
      TitleBar({
        title: this.vm.curAudio.fileName.split('.')[0],
        isBlock: true,
        onBlock: () => {
          if (this.vm.isCanSave) {
            this.dialogControllerConfirm.open();
          } else {
            getInstance().pop();
          }
        },
      });
      Column() {
        Column({ space: 12 }) {
          Row({ space: 16 }) {
            Image($r('app.media.ic_play_circle')).width(24);
            Text(this.vm.outputFileName ? this.vm.outputFileName : this.vm.curAudio.fileName)
              .titleExtend()
              .maxLines(1)
              .layoutWeight(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });

          }
          .height(72)
          .width('100%')
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .padding(12);

          Column({ space: 24 }) {
            Column({ space: 12 }) {
              Text('音频格式：').titleExtend();
              BtnBar({
                text: this.vm.curAudio.format,
                isActive: true,
              });
            }.alignItems(HorizontalAlign.Start);

            Column({ space: 12 }) {
              Text('音频格式：').titleExtend();
              Row({ space: 8 }) {
                ForEach(this.vm.formatArr, (item: string, index: number) => {
                  BtnBar({
                    text: item,
                    isActive: this.vm.currentIndex === index,
                    itemClick: () => {
                      this.vm.currentIndex = index;
                      this.vm.chaneFormat(item,this.loadingController);
                    },
                  });

                }, (item: string) => item);
              };
            }.alignItems(HorizontalAlign.Start);

          }
          .padding({
            top: 16,
            bottom: 16,
            left: 12,
            right: 12,
          })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)
          .width('100%');

        }.layoutWeight(1);

        Column() {
          Button('保存').enabled(this.vm.isCanSave).height(40).width('100%').onClick(() => {
            this.vm.saveFile();
          });
        }.padding({ top: 12, bottom: 12 });

      }.padding({ top: 8, left: 16, right: 16 }).layoutWeight(1);

    }.backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (this.vm.isCanSave) {
        this.dialogControllerConfirm.open();
      }
      return this.vm.isCanSave;
    });

  }
}

@Extend(Text)
function titleExtend() {
  .fontColor($r('sys.color.font_primary'))
  .fontSize($r('sys.float.Subtitle_M'))
  .fontWeight(FontWeight.Medium);
}
