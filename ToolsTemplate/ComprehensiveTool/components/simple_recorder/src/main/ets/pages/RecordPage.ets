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
import { fileIo as fs } from '@kit.CoreFileKit';
import { LoadingDialog } from '@kit.ArkUI';
import { RecorderToolDialog } from '../components/RecorderToolDialog';
import { RecordPageVM } from '../viewModels/RecordPageVM';
import { PermissionUtil } from '../util/PermissionUtil';
import { RecordStatus, SaveType } from '../model/Index';



@Builder
export function RecordPageBuilder() {
  RecordPage();
}

@ComponentV2
export struct RecordPage {
  vm: RecordPageVM = RecordPageVM.instance;
  controller: CustomDialogController = new CustomDialogController({
    builder: this.buildDialog,
    customStyle: true,
  });

  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '录音保存中...',
    })
  })

  aboutToAppear(): void {
    PermissionUtil.requestPermissions(['ohos.permission.MICROPHONE']);
    this.vm.initData();
  }

  async aboutToDisappear(): Promise<void> {
    if (this.vm.recordStatus === RecordStatus.PROGRESS) {
      await this.vm.stop();
    }
    if (this.vm.curFile) {
      fs.unlinkSync(this.vm.curFile.filePath);
    }
  }

  @Builder
  buildDialog() {
    RecorderToolDialog({
      save: async () => {
        await this.vm.saveAudio(SaveType.ONLY_SAVE,this.loadingController);
        this.controller.close();
      },
      convert: async () => {
        await this.vm.saveAudio(SaveType.CONVERT_SAVE,this.loadingController);
        this.controller.close();
      },
      edit: async () => {
        await this.vm.saveAudio(SaveType.EDIT_SAVE,this.loadingController);
        this.controller.close();
      },
      cancel: () => {
        this.controller.close();
      },
    });
  }

  // 录音图标
  @Builder
  RecorderIconBuilder() {
    Column({ space: 8 }) {
      if (this.vm.myAmplitude.amplitude !== 0) {
        Row({ space: 4 }) {
          ForEach(this.vm.waveIndex, (i: number, index) => {
            Column()
              .width(6)
              .height(this.vm.getWaveHeight())
              .backgroundColor($r('sys.color.icon_on_primary'))
              .borderRadius(3);
          }, (i: number, index) => index.toString());
        }
        .width(80)
        .height(80)
        .justifyContent(FlexAlign.Center);
      }
    }
    .width(172)
    .height(172)
    .linearGradient({ angle: 140.27, colors: [['rgb(32, 112, 243)', 0.14545], ['rgb(108, 209, 255)', 0.83316]] })
    .borderRadius(86)
    .border({
      width: 6,
      color: 'rgb(218, 231, 254)',
    })
    .justifyContent(FlexAlign.Center);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.header_bg')).height(408).width('100%');
        Column() {
          Column() {
            this.RecorderIconBuilder();
          }.padding({ top: 42, bottom: 42 });

          Row() {
            if (this.vm.recordStatus === RecordStatus.OFF) {
              Image($r('app.media.ic_close_btn')).width(40).onClick(() => {
                this.vm.delAudio();
              });
            }

            if (this.vm.recordStatus === RecordStatus.PROGRESS) {
              Image($r('app.media.ic_stop_button')).width(56).onClick(() => {
                this.vm.stop();
              });
            } else {
              Image($r('app.media.ic_play_button')).width(56).onClick(() => {
                if (this.vm.recordStatus === RecordStatus.PENDING) {
                  this.vm.start(this.getUIContext());
                }

              });
            }
            if (this.vm.recordStatus === RecordStatus.OFF) {
              Image($r('app.media.chevron_backward')).width(40).onClick(() => {
                this.controller.open();
              });
            }
          }
          .width('100%')
          .padding({
            top: 24,
            bottom: 24,
            left: 40,
            right: 40,
          })
          .justifyContent(this.vm.recordStatus === RecordStatus.OFF ? FlexAlign.SpaceBetween : FlexAlign.Center);
        }.height('100%').justifyContent(FlexAlign.SpaceBetween);
      }.height('100%');

    }.title('录音')
    .linearGradient({ angle: 180, colors: [['rgb(236, 242, 253)', 0.42994], ['rgb(255, 255, 255)', 0.99802]] });

  }
}


