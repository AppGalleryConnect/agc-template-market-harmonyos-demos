/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointSystem } from './BreakpointSystem';
import { LogUtil } from './LogUtil';

const TAG: string = '[WindowUtil]';

export class WindowUtil {
  public static registerBreakPoint(windowStage: window.WindowStage) {
    try {
      windowStage.getMainWindow((err: BusinessError | undefined, data: window.Window) => {
        if (err !== undefined) {
          LogUtil.error(TAG, `Failed to get main window: ${err.message}`);
          return;
        }
        try {
          BreakpointSystem.getInstance().updateWidthBp(windowStage, data);
          data.on('windowSizeChange', () => WindowUtil.onWindowSizeChange(windowStage, data));
        } catch (e) {
          const error = e as BusinessError;
          LogUtil.error(TAG, `registerBreakPoint inner failed. code: ${error.code}, message: ${error.message}`);
        }
      });
    } catch (e) {
      const error = e as BusinessError;
      LogUtil.error(TAG, `getMainWindow threw. code: ${error.code}, message: ${error.message}`);
    }
  }

  public static onWindowSizeChange(windowStage: window.WindowStage, window: window.Window) {
    BreakpointSystem.getInstance().onWindowSizeChange(windowStage, window);
  }
}