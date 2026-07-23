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

import { fileIo } from '@kit.CoreFileKit';
import Logger from './Logger';

export class FileUtil {
  // Create and open a file.
  static createOrOpen(path: string): fileIo.File | undefined {
    let file: fileIo.File | undefined = undefined;
    try {
      let isExist = fileIo.accessSync(path);
      if (isExist) {
        file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE);
      } else {
        file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      }
    } catch (error) {
      Logger.error('FileUtil', `open file failed. error is: ${JSON.stringify(error)}`);
    }
    return file;
  }

  // Save the arraybuffer to a file.
  static writeBufferToFile(path: string, arrayBuffer: ArrayBuffer): number {
    try {
      let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      let value = fileIo.writeSync(file.fd, arrayBuffer);
      fileIo.closeSync(file);
      return value;
    } catch (err) {
      Logger.error('FileUtil', 'writeFile err:' + err);
      return -1;
    }
  }

  // Save the text content to a file.
  static writeStrToFile(path: string, text: string): number {
    try {
      let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      let value = fileIo.writeSync(file.fd, text);
      fileIo.closeSync(file);
      return value;
    } catch (err) {
      Logger.error('FileUtil', 'writeFile err:' + err);
      return -1;
    }
  }
}