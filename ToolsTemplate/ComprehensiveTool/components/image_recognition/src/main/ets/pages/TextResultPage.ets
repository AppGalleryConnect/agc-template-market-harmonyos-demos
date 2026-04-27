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
import { NavTitle } from '../components/NavTitle';
import { TextResultPageVM } from '../viewModels/TextResultPageVM';

@Builder
export function TextResultPageBuilder() {
  TextResultPage();
}

@ComponentV2
export struct TextResultPage {
  vm: TextResultPageVM = TextResultPageVM.instance;

  aboutToAppear(): void {
    this.vm.getParam();
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
        NavTitle({
          title: '文字扫描结果',
        });
        Scroll() {
          Column() {
            if (this.vm.textResult) {
              Text(this.vm.textResult)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(19)
                .copyOption(CopyOptions.InApp);
            } else {
              Text('——暂未识别到文字——')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
                .lineHeight(19)
                .margin({ top: 80 });
            }

          }
          .alignItems(this.vm.textResult ? HorizontalAlign.Start : HorizontalAlign.Center)
          .width('100%')
          .constraintSize({ minHeight: 200 })
          .padding({
            top: 10,
            left: 12,
            right: 12,
            bottom: 10,
          })
          .borderRadius(16)
          .backgroundColor($r('sys.color.background_primary'))
          .margin({ bottom: 8 });

        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .borderRadius({
          topLeft: 16,
          topRight: 16,
        })
        .align(Alignment.Top)
        .margin({ left: 16, right: 16 })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });
      }
      .layoutWeight(1)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .backgroundColor($r('sys.color.background_secondary'));


      Row() {
        Column({ space: 4 }) {
          Image($r('app.media.ic_copy')).width(24);
          Text('复制')
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'));
        }.padding(4).height('100%').onClick(() => {
          this.vm.toCopy(this.getUIContext());
        });

      }.width('100%').justifyContent(FlexAlign.Center).height(52);
    }
    .hideTitleBar(true);
  }
}


