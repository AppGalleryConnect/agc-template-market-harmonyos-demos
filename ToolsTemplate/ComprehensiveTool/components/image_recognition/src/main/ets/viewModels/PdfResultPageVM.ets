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
import { common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri, picker, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getInstance, RouterMap } from '../util/Route';
import { FileInfo } from '../model/Index';
import { MyLog } from '../util/MyLogUtil';




@ObservedV2
export class PdfResultPageVM {
  @Trace filePath: string = '';
  @Trace fileName: string = '';
  private static _instance: PdfResultPageVM;

  public static get instance() {
    if (!PdfResultPageVM._instance) {
      PdfResultPageVM._instance = new PdfResultPageVM();
    }
    return PdfResultPageVM._instance;
  }

  // 初始化预览
  public initPdfView() {
    const fileInfo = getInstance().getParamByName(RouterMap.PDF_RESULT)[0] as FileInfo;
    this.filePath = fileInfo.filePath;
    this.fileName = fileInfo.fileName;
  }

  // 分享pdf
  shareData(context: common.UIAbilityContext) {
    const uri = fileUri.getUriFromPath(this.filePath);
    const data: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.PDF,
      uri: uri,
    });
    const controller: systemShare.ShareController = new systemShare.ShareController(data);
    // 进行分享面板显示
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DEFAULT,
      selectionMode: systemShare.SelectionMode.SINGLE,
      excludedAbilities: [systemShare.ShareAbilityType.SAVE_AS_FILE],
    });
  }


  async savePdf(uiContext:UIContext) {
    let uris: string = '';
    try {
      const documentSaveOptions = new picker.DocumentSaveOptions(); // 创建文件管理器保存选项实例
      documentSaveOptions.newFileNames =
        [this.fileName + '.pdf']; // 保存文件名（可选），方括号里的文件名自定义，每次不能重复，设备里已有这个文件的话，名字就需要改个不一样的，不然接口会报错
      const documentViewPicker = new picker.DocumentViewPicker();
      try {
        let documentSaveResult = await documentViewPicker.save(documentSaveOptions);
        if (documentSaveResult !== undefined) {
          uris = documentSaveResult[0];
          MyLog.info('save to file succeed and uris are:' + uris);
        }
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        MyLog.error(`save failed, code is ${err.code}, message is ${err.message}`);
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      MyLog.error(`pick failed, code is ${err.code}, message is ${err.message}`);
    }
    let file: fs.File | undefined = undefined;
    let file2: fs.File | undefined = undefined;
    try {
      file = fs.openSync(this.filePath, fs.OpenMode.READ_ONLY);
      file2 = fs.openSync(uris + '', fs.OpenMode.READ_WRITE);
      fs.copyFileSync(file.fd, file2.fd);
      uiContext.getPromptAction().showToast({ message: '导出成功！' });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      MyLog.error(`save failed, code is ${err.code}, message is ${err.message}`);
    } finally {
      if (file) {
        fs.closeSync(file);
      }
      if (file2) {
        fs.closeSync(file2);
      }
    }
  }
}