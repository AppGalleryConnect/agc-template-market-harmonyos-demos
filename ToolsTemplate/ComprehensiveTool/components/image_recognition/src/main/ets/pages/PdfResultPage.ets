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
import { pdfService, PdfView, pdfViewManager } from '@kit.PDFKit';
import { common } from '@kit.AbilityKit';
import { NavTitle } from '../components/NavTitle';
import { PdfResultPageVM } from '../viewModels/PdfResultPageVM';


@Builder
export function PdfResultPageBuilder() {
  PdfResultPage();
}

@ComponentV2
export struct PdfResultPage {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  controller: pdfViewManager.PdfController = new pdfViewManager.PdfController();
  vm: PdfResultPageVM = PdfResultPageVM.instance;

  aboutToAppear(): void {
    this.vm.initPdfView();
    if (this.vm.filePath) {
      this.controller.loadDocument(this.vm.filePath);
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavTitle({
          title: 'pdf扫描结果',
        });
        Column() {
          PdfView({
            controller: this.controller,
            pageLayout: pdfService.PageLayout.LAYOUT_SINGLE,
            pageFit: pdfService.PageFit.FIT_WIDTH,
            showScroll: false,
          })
            .id('pdfview_app_view')
            .layoutWeight(1);

        }
        .layoutWeight(1)
        .padding({
          top: 8,
          left: 16,
          right: 16,
        });
      }.backgroundColor($r('sys.color.background_secondary')).layoutWeight(1)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);


      Row() {
        Column({ space: 4 }) {
          Image($r('app.media.ic_public_save')).width(24);
          Text('保存')
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'));
        }.padding(4).height('100%').onClick(() => {
          this.vm.savePdf(this.getUIContext());
        });

        Column({ space: 4 }) {
          Image($r('app.media.ic_recognition_share')).width(24);
          Text('分享')
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'));
        }.padding(4).height('100%')
        .onClick(() => {
          this.vm.shareData(this.context);
        });

      }.width('100%').justifyContent(FlexAlign.SpaceAround).height(52);
    }
    .hideTitleBar(true);

  }
}


