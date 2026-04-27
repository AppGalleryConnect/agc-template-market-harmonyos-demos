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
import { UISlider, UISliderValue } from '@hw-agconnect/ui-slider';
import { FormatUtil } from '../util/FormatUtil';
import { TitleBar } from '../components/TitleBar';
import { SheetTitle } from '../components/SheetTitle';
import { EditNameDialog } from '../components/EditNameDialog';
import { OperationPageVM } from '../viewModels/OperationPageVM';
import { getInstance } from '../util/Route';
import { AudioWavePage } from '../components/AudioWave';

@Builder
export function OperationPageBuilder() {
  OperationPage();
}

@ComponentV2
export struct OperationPage {
  vm: OperationPageVM = OperationPageVM.instance;
  editController: CustomDialogController = new CustomDialogController({
    builder: this.editDialog,
    customStyle: true,
  });
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '温馨提示',
      content: '编辑内容尚未保存，是否确定退出？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.dialogControllerConfirm.close();
        },
      },
      secondaryButton: {
        value: '确认',
        action: () => {
          this.vm.released();
          this.dialogControllerConfirm.close();
          getInstance().pop();
        },
      },
    }),
  });
  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '音频处理中...',
    }),
    autoCancel:false
  });

  aboutToAppear(): void {
    this.vm.getRouteParam();
    this.vm.initPlayer();
  }

  aboutToDisappear(): void {
    this.vm.released();
  }

  @Builder
  editDialog() {
    EditNameDialog({
      onChange: (text: string) => {
        this.vm.fileName = text;
      },
      onSave: () => {
        this.vm.saveAudio();
        this.editController.close();
      },
      onCancel: () => {
        this.editController.close();
      },
    });
  }

  // 截取弹框
  @Builder
  splitBuilder() {
    Column() {
      SheetTitle({
        title: '截取',
        onClose: () => {
          this.vm.splitSheetVisible = false;
        },
        onConfirm: () => {
          this.vm.toSplitAudio(this.loadingController);
        },
      });
      Column() {
        Row() {
          ForEach(this.vm.splitBtnArr, (item: string, index: number) => {
            Text(item)
              .btnExtend()
              .fontColor(this.vm.splitBtnIndex === index ? $r('sys.color.font_primary') :
              $r('sys.color.font_secondary'))
              .backgroundColor(this.vm.splitBtnIndex === index ? $r('sys.color.comp_background_primary_contrary') :
                'transparent')
              .shadow(
                this.vm.splitBtnIndex === index ?
                  {
                    radius: this.getUIContext().vp2px(3),
                    color: 'rgba(0, 0, 0, 0.2)',
                  } : undefined)
              .onClick(() => {
                this.vm.splitBtnIndex = index;
              });
          }, (item: string) => item);

        }
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(20)
        .padding(2)
        .height(40);

        Row() {
          Text('起始截取时间')
            .tipExtend();
          Text('结束截取时间')
            .tipExtend();
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 44 });

        Row() {
          Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.startTime)))
            .tipExtend();
          Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.endTime)))
            .tipExtend();
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 10 });

        UISlider({
          sliderId: '2',
          min: 0,
          max: 100, // 最大值固定设置100 优化滑动体验，防止音频较短时滑动卡段
          value: [(this.vm.startTime / this.vm.duration) * 100, (this.vm.endTime / this.vm.duration) * 100],
          trackThickness: 20,
          selectedColor: $r('sys.color.comp_background_emphasize'),
          trackColor: $r('sys.color.comp_background_tertiary'),
          style: SliderStyle.InSet,
          onChange: (value: UISliderValue) => {
            const arr = value as [number, number];
            this.vm.startTime = arr[0] * this.vm.duration / 100;
            this.vm.endTime = arr[1] * this.vm.duration / 100;
          },
        });


      }.padding(8);

    }.width('100%').padding({ top: 8, left: 16, right: 16 }).backgroundColor($r('sys.color.comp_background_primary'));
  }

  // 变速弹框
  @Builder
  speedBuilder() {
    Column() {
      SheetTitle({
        title: '变速',
        onClose: () => {
          this.vm.speedSheetVisible = false;
        },
        onConfirm: () => {
          this.vm.changeAudioSpeed(this.loadingController);
        },
      });
      Column({ space: 10 }) {
        Slider({
          min: 0.5 * 100, // 刻度整体放大100倍，优化滑动体验
          max: 2 * 100,
          value: this.vm.currentSpeed * 100,
          style: SliderStyle.InSet,
          step: 0.5 * 100,
        })
          .trackThickness(20)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .width('100%')
          .padding({ left: 0, right: 0 })
          .showSteps(true)
          .onChange((value) => {
            this.vm.currentSpeed = value / 100;
          });


        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.vm.speedArr, (item: string) => {
            Text(item).baseLabelExtend();
          }, (item: string) => item);
        }.padding({ left: 8, right: 8 });

      }.padding({ top: 59 });

    }.width('100%').padding({ top: 8, left: 16, right: 16 }).backgroundColor($r('sys.color.comp_background_primary'));
  }

  // 变速弹框
  @Builder
  toneBuilder() {
    Column() {
      SheetTitle({
        title: '音调',
        onClose: () => {
          this.vm.toneSheetVisible = false;
        },
        onConfirm: () => {
          this.vm.changeTone(this.loadingController);
        },
      });
      Column({ space: 10 }) {

        Slider({
          min: 0.5 * 100, // 刻度整体放大100倍，优化滑动体验
          max: 1.5 * 100,
          value: this.vm.currentTone * 100,
          style: SliderStyle.InSet,
        }).trackThickness(20)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((value) => {
            this.vm.currentTone = value / 100;
          });

        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Text('低').baseLabelExtend();
          Text('高').baseLabelExtend();
        }.padding({ left: 8, right: 8 });

      }.padding({ top: 59 });

    }.width('100%').padding({ top: 8, left: 16, right: 16 }).backgroundColor($r('sys.color.comp_background_primary'));
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          title: this.vm.curAudio.fileName.split('.')[0],
          isShowBtn: this.vm.isCanSave,
          isBlock: true,
          save: () => {
            this.editController.open();
          },
          onBlock: () => {
            if (this.vm.isCanSave) {
              this.dialogControllerConfirm.open();
            } else {
              getInstance().pop();
            }
          },
        });
        Column({ space: 24 }) {
          AudioWavePage({ inputAudioPath: this.vm.curAudio.pcmPath, controller: this.vm.controller });
          Row({ space: 16 }) {
            if (this.vm.isPlaying) {
              Image($r('app.media.ic_stop_button')).width(40).onClick(() => {
                this.vm.pause();
              });
            } else {
              Image($r('app.media.ic_play_button')).width(40).onClick(() => {
                this.vm.play();
              });
            }

            Stack({ alignContent: Alignment.Top }) {
              Row() {
                Slider({
                  style: SliderStyle.NONE,
                  value: (this.vm.curTime / this.vm.duration) * 100,
                  min: 0,
                  max: 100,
                }).trackColor($r('sys.color.comp_background_secondary'))
                  .selectedColor($r('sys.color.comp_background_emphasize'))
                  .onChange((res, mode: SliderChangeMode) => {
                    if (mode === SliderChangeMode.End) {
                      const targetTime = this.vm.duration * (res / 100);
                      this.vm.seek(targetTime);
                    }
                  });
              }.height(40);

              Row() {
                Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.curTime))).labelExtend();
                Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.duration))).labelExtend();
              }.margin({ top: 22 }).width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 4, right: 4 });
            }.layoutWeight(1).height(40);
          };
        }.padding({ top: 8, left: 16, right: 16 }).layoutWeight(1);

      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

      if (this.vm.isOperation) {
        Row() {
          Column({ space: 2 }) {
            Image($r('app.media.ic_public_cut')).width(24);
            Text('截取').commonText();
          }
          .bindSheet($$this.vm.splitSheetVisible, this.splitBuilder(), {
            preferType: SheetType.CENTER,
            showClose: false,
            height: 304,
            blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          })
          .onClick(() => {
            this.vm.splitSheetVisible = true;
          });

          Column({ space: 2 }) {
            Image($r('app.media.ic_public_speed')).width(24);
            Text('变速').commonText();
          }.bindSheet($$this.vm.speedSheetVisible, this.speedBuilder(), {
            preferType: SheetType.CENTER,
            showClose: false,
            height: 246,
            blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          })
          .onClick(() => {
            this.vm.speedSheetVisible = true;
          });

          Column({ space: 2 }) {
            Image($r('app.media.ic_slider_vertical')).width(24);
            Text('音调').commonText();
          }.bindSheet($$this.vm.toneSheetVisible, this.toneBuilder(), {
            preferType: SheetType.CENTER,
            showClose: false,
            height: 246,
            blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          })
          .onClick(() => {
            this.vm.toneSheetVisible = true;
          });

        }
        .height(48)
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround);
      }
    }.hideTitleBar(true)
    .onBackPressed(() => {
      if (this.vm.isCanSave) {
        this.dialogControllerConfirm.open();
      }
      return this.vm.isCanSave;
    });

  }
}

@Extend(Text)
function tipExtend() {
  .fontSize($r('sys.float.Caption_L'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'))
  .lineHeight(16);
}

@Extend(Text)
function btnExtend() {
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Medium)
  .width('50%')
  .height('100%')
  .borderRadius(18)
  .textAlign(TextAlign.Center);
}


@Extend(Text)
function baseLabelExtend() {
  .fontSize($r('sys.float.Caption_L'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'));
}

@Extend(Text)
function labelExtend() {
  .fontSize($r('sys.float.Caption_M'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'))
  .lineHeight(14);
}


@Extend(Text)
function commonText() {
  .fontSize($r('sys.float.Caption_M'))
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'))
  .lineHeight(14);
}
