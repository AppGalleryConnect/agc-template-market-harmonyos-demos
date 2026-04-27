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
import { getInstance, RouterMap } from '../util/Route';
import { fileIo as fs } from '@kit.CoreFileKit';
import { DocumentScannerConfig, FilterId, SaveOption } from '@kit.VisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MyLog } from '../util/MyLogUtil';
import { FileInfo } from '../model/Index';




@ObservedV2
export class DocScanPageVM {
  @Trace filePath: string = '';
  @Trace fileName: string = '';
  file: fs.File | undefined = undefined;
  file2: fs.File | undefined = undefined;
  docScanConfig = new DocumentScannerConfig();
  private static _instance: DocScanPageVM;

  public static get instance() {
    if (!DocScanPageVM._instance) {
      DocScanPageVM._instance = new DocScanPageVM();
    }
    return DocScanPageVM._instance;
  }

  public initConfig(context: Context) {
    this.fileName = this.formatFullDate();
    this.filePath = context.filesDir + `/${this.fileName}.pdf`;
    // 支持图库选图
    this.docScanConfig.isGallerySupported = true;
    this.docScanConfig.isShareable = false;
    // 最多扫描张数
    this.docScanConfig.maxShotCount = 10;
    // 默认为黑白滤镜
    this.docScanConfig.defaultFilterId = FilterId.MONOCHROME;
    // 保存格式为pdf格式
    this.docScanConfig.saveOptions = [SaveOption.PDF];
  }

  public async handleScanResult(code: number, uri: string) {
    if (code === -1) {
      getInstance().pop();
    } else {
      try {
        this.file = fs.openSync(this.filePath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
        this.file2 = fs.openSync(uri, fs.OpenMode.READ_ONLY);
        fs.copyFileSync(this.file2.fd, this.file.fd);
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        MyLog.error(`save failed, code is ${err.code}, message is ${err.message}`);
      } finally {
        if (this.file) {
          fs.closeSync(this.file);
        }
        if (this.file2) {
          fs.closeSync(this.file2);
        }
        const fileInfo: FileInfo = {
          filePath: this.filePath,
          fileName: this.fileName,
        };
        getInstance().replacePathByName(RouterMap.PDF_RESULT, fileInfo);
      }
    }
  }

  // 根据时间戳生成文件名
  private formatFullDate(date: Date = new Date()): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();
    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());
    const seconds = pad(date.getSeconds());
    return `${year}${month}${day}${hours}${minutes}${seconds}`;
  }
}