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
import { DocumentScanner, SaveOption } from '@kit.VisionKit';
import { DocScanPageVM } from '../viewModels/DocScanPageVM';


@Builder
export function DocScanPageBuilder() {
  DocScanPage();
}

@ComponentV2
export struct DocScanPage {
  private context = this.getUIContext().getHostContext() as Context;
  private vm: DocScanPageVM = DocScanPageVM.instance;

  aboutToAppear() {
    this.vm.initConfig(this.context);
  }

  build() {
    NavDestination() {
      Stack() {
        DocumentScanner({
          scannerConfig: this.vm.docScanConfig,
          onResult: (code: number, saveType: SaveOption, uris: string[]) => {
            this.vm.handleScanResult(code, uris[0]);
          },
        });
      };
    }.hideTitleBar(true);
  }
}
