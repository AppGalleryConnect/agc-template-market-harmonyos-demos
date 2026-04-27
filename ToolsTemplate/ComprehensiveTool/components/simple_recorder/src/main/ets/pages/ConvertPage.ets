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
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { TitleBar } from '../components/TitleBar';
import { FormatUtil } from '../util/FormatUtil';
import { ConvertPageVM } from '../viewModels/ConvertPageVM';


@Builder
export function ConvertPageBuilder() {
  ConvertPage();
}

@ComponentV2
export struct ConvertPage {
  vm: ConvertPageVM = ConvertPageVM.instance;

  aboutToAppear(): void {
    this.vm.getRouteParam();
    this.vm.initPlayer();
  }

  aboutToDisappear(): void {
    this.vm.released();
    this.vm.shutdown();
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          title: this.vm.curAudio.fileName.split('.')[0],
        });

        Column({ space: 12 }) {
          Row({ space: 16 }) {
            Image(this.vm.isPlaying ? $r('app.media.ic_pause_circle') : $r('app.media.ic_play_circle'))
              .width(24)
              .onClick(() => {
                if (this.vm.isPlaying) {
                  this.vm.pause();
                } else {
                  this.vm.play();
                }

              });
            Column() {
              Text(this.vm.curAudio.fileName)
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 12 })
                .width('100%')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Slider({
                style: SliderStyle.NONE,
                value: (this.vm.curTime / this.vm.duration) * 100,
                min: 0,
                max: 100,
              })
                .trackColor($r('sys.color.comp_background_tertiary'))
                .selectedColor($r('sys.color.comp_background_emphasize'))
                .height(4)
                .onChange((res, mode: SliderChangeMode) => {
                  if (mode === SliderChangeMode.End) {
                    const targetTime = this.vm.duration * (res / 100);
                    this.vm.seek(targetTime);
                  }
                });
              Row() {
                Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.curTime))).labelExtend();
                Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.duration))).labelExtend();
              }.margin({ top: 2 }).width('100%').justifyContent(FlexAlign.SpaceBetween);

            }.layoutWeight(1).alignItems(HorizontalAlign.Start);

          }
          .height(85)
          .width('100%')
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .padding(12);

          Refresh({ refreshing: $$this.vm.isRefresh }) {
            Column() {
              if (!this.vm.generatedText && !this.vm.progressText) {
                Column() {
                  Text('下拉刷新查看结果')
                    .fontSize($r('sys.float.Subtitle_S'))
                    .fontColor($r('sys.color.font_tertiary'));
                }.height('100%').justifyContent(FlexAlign.Center).width('100%');
              } else {
                Text(this.vm.isFinal ? this.vm.generatedText : this.vm.generatedText + this.vm.progressText)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Subtitle_M'))
                  .lineHeight(40);
              }
            }
            .borderRadius(16)
            .width('100%')
            .height('100%')
            .padding(12)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('sys.color.comp_background_primary'));

          }
          .width('100%')
          .layoutWeight(1)
          .borderRadius(16)
          .onRefreshing(async () => {
            if (!this.vm.asrEngine) {
              await this.vm.createByCallback();
            }
            this.vm.audioToText();
          });
        }
        .padding({
          top: 8,
          left: 16,
          right: 16,
          bottom: 15,
        })
        .layoutWeight(1);

      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

      Row() {
        Column({ space: 2 }) {
          Image($r('app.media.ic_public_copy')).width(24);
          Text('复制').commonTextExtend();
        }.onClick(() => {
          this.vm.toCopy();
        });

        Column({ space: 2 }) {
          Image($r('app.media.ic_public_output')).width(24);
          Text('导出').commonTextExtend();
        }.onClick(() => {
          if (this.vm.generatedText || this.vm.progressText) {
            this.vm.saveText();
          } else {
            promptAction.showToast({ message: '暂无可导出的文本！' });
          }

        });

      }.width('100%').height(48).padding({ top: 4 }).justifyContent(FlexAlign.SpaceAround);

    }.hideTitleBar(true)
    .onHidden(() => {
      this.vm.pause();
    });

  }
}


@Extend(Text)
function commonTextExtend() {
  .lineHeight(14)
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Caption_M'));
}


@Extend(Text)
function labelExtend() {
  .fontSize($r('sys.float.Caption_M'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'));
}