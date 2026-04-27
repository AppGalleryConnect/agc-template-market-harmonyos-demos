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
import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { MyLog } from '../util/MyLogUtil';
import { getInstance, RouterMap } from '../util/Route';
import { PermissionUtil } from '../util/PermissionUtil';
import { RecognitionType } from '../model/Index';





@ObservedV2
export class RecognitionHomePageVM {
  @Trace curScanType: RecognitionType = RecognitionType.DEFAULT_SCAN;
  private static _instance: RecognitionHomePageVM;

  public static get instance() {
    if (!RecognitionHomePageVM._instance) {
      RecognitionHomePageVM._instance = new RecognitionHomePageVM();
    }
    return RecognitionHomePageVM._instance;
  }


  // 通用拍照识别
  async toCamera(ctx:Context) {
    const hasPermission = await PermissionUtil._checkPermissions('ohos.permission.CAMERA');
    if (hasPermission) {
      getInstance().pushPathByName(RouterMap.CAMERA, null);
    } else {
      PermissionUtil.requestPermissions(['ohos.permission.CAMERA'],ctx);
    }
  }


  // 二维码扫描
  scanCode(uiContext: UIContext) {
    let options: scanBarcode.ScanOptions =
      { scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true };
    try {
      scanBarcode.startScanForResult(uiContext.getHostContext(), options).then((result: scanBarcode.ScanResult) => {
        getInstance().pushPathByName(RouterMap.TEXT_RESULT, result.originalValue);
      }).catch((error: BusinessError) => {
        uiContext.getPromptAction().showToast({ message: '识别失败！' })
        MyLog.error(`Failed to get ScanResult by promise with options. Code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      uiContext.getPromptAction().showToast({ message: '二维码扫描启动失败！' })
      MyLog.error(`Failed to startScanForResult. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // 根据不同的扫描类型处理扫描逻辑
  handleScanByType() {
    if (this.curScanType === RecognitionType.DEFAULT_SCAN) {
      getInstance().pushPathByName(RouterMap.CAMERA, null);
    } else {
      getInstance().pushPathByName(RouterMap.CARD_RECOGNITION, this.curScanType);
    }
  }
}