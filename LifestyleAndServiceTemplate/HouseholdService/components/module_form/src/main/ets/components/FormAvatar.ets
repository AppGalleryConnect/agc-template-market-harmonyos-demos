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
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';

@ComponentV2
export struct FormAvatar {
  @Param url: ResourceStr = '';
  @Event onAvatarSelect: (url: ResourceStr) => void;
  context: Context | undefined = this.getUIContext().getHostContext();

  build() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
        label: '',
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .type(ButtonType.Normal)
            .backgroundImage(this.url)
            .backgroundImageSize(ImageSize.Cover)
            .width(32)
            .height(32)
            .borderRadius('50%'),
        },
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
        if (err) {
          return;
        }
        let url = data.avatarUri!;
        let avatarFile: fs.File | null = null;
        try {
          avatarFile = fs.openSync(url, fs.OpenMode.READ_ONLY);
          if (!this.context) {
            return;
          }
          let newPath: string = this.context.cacheDir + `/${util.generateRandomUUID(false)}.png`;
          fs.copyFileSync(avatarFile.fd, newPath);
          url = 'file://' + newPath;
        } finally {
          if (avatarFile) {
            fs.closeSync(avatarFile);
          }
        }

        this.onAvatarSelect(url);
      }),
    })
  }
}