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
import { UtilLog } from '@hw-agconnect/util-log';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { getInstance, RouterMap } from '../util/Route';

@ObservedV2
export class TextResultPageVM {
  @Trace textResult: string = '';
  private static _instance: TextResultPageVM;

  public static get instance() {
    if (!TextResultPageVM._instance) {
      TextResultPageVM._instance = new TextResultPageVM();
    }
    return TextResultPageVM._instance;
  }

  public getParam() {
    this.textResult = getInstance().getParamByName(RouterMap.TEXT_RESULT)[0] as string;
  }


  public toCopy(uiContext: UIContext) {
    if (this.textResult) {
      try {
        const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.textResult);
        pasteboard.getSystemPasteboard().setData(pasteData).then(() => {
          uiContext.getPromptAction().showToast({ message: '复制成功' });
        }).catch((err: BusinessError) => {
          uiContext.getPromptAction().showToast({ message: '复制失败' });
        });
      } catch (e) {
        UtilLog.error(`onKeyboardChange failed with error ${JSON.stringify(e)}`);
      }
    } else {
      uiContext.getPromptAction().showToast({ message: '暂无内容!' });
    }
  }
}