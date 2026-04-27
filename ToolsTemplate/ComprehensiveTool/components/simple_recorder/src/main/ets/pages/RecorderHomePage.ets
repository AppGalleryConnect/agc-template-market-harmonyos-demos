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
import { RecorderHomePageVM } from '../viewModels/RecorderHomePageVM';
import { setPathStack, getInstance, RouterMap } from '../util/Route';
import { TitleBar } from '../components/TitleBar';
import { TabItem } from '../model/Index';


@Builder
export function RecorderHomePageBuilder() {
  RecorderHomePage();
}

@ComponentV2
export struct RecorderHomePage {
  vm: RecorderHomePageVM = RecorderHomePageVM.instance;

  // 录音图标
  @Builder
  RecorderIconBuilder() {
    Column({ space: 8 }) {
      Image($r('app.media.ic_public_mic_filled')).width(64);
      Text('点击录音')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .lineHeight(24);
    }
    .width(172)
    .height(172)
    .linearGradient({ angle: 140.27, colors: [['rgb(32, 112, 243)', 0.14545], ['rgb(108, 209, 255)', 0.83316]] })
    .borderRadius(86)
    .border({
      width: 6,
      color: 'rgb(218, 231, 254)',
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      getInstance().pushPathByName(RouterMap.RECORD, null);
    });
  }

  build() {
    NavDestination() {
      TitleBar({ title: '录音专家' });
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.header_bg')).height(408).width('100%');
        Column() {
          Column() {
            this.RecorderIconBuilder();
          }.padding({ top: 42, bottom: 42 });

          Grid() {
            ForEach(this.vm.tabList, (item: TabItem) => {
              GridItem() {
                Column({ space: 8 }) {
                  Image(item.icon).width(48);
                  Text(item.label)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'));
                }
                .width('100%')
                .borderRadius(16)
                .height(104)
                .padding(14.5)
                .backgroundColor($r('sys.color.comp_background_primary'));
              }.onClick(() => {
                getInstance().pushPathByName(item.url, item.nextRoute);
              });
            }, (item: TabItem) => item.label);

          }.padding({ left: 16, right: 16 })
          .columnsGap(8)
          .rowsGap(8)
          .columnsTemplate('1fr 1fr 1fr');

        }.width('100%').height('100%');

      }.layoutWeight(1);

    }
    .linearGradient({ angle: 180, colors: [['rgb(236, 242, 253)', 0.42994], ['rgb(255, 255, 255)', 0.99802]] })
    .hideTitleBar(true)
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
      AppStorage.setOrCreate('simple_recorder_context', this.getUIContext().getHostContext());
    });
  }
}


