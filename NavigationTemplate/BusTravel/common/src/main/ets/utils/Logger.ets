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

import { hilog } from '@kit.PerformanceAnalysisKit';

//
// export class Logger {
//   private domain: number;
//   private prefix: string;
//   private format: string = '%{public}s, %{public}s';
//
//   /**
//    * constructor.
//    *
//    * @param Prefix Identifies the log tag.
//    * @param domain Domain Indicates the service domain, which is a hexadecimal integer ranging from 0x0 to 0xFFFFF.
//    */
//   constructor(prefix: string) {
//     this.prefix = prefix;
//     this.domain = 0xFF00;
//   }
//
//   debug(...args: string[]): void {
//     hilog.debug(this.domain, this.prefix, this.format, args);
//   }
//
//   info(...args: string[]): void {
//     hilog.info(this.domain, this.prefix, this.format, args);
//   }
//
//   warn(...args: string[]): void {
//     hilog.warn(this.domain, this.prefix, this.format, args);
//   }
//
//   error(...args: string[]): void {
//     hilog.error(this.domain, this.prefix, this.format, args);
//   }
// }
//
// export default new Logger('MultiTravelNavigation');


let domain: number = 0xFF00;
let prefix: string = '';
let format: string = `%{public}s, %{public}s`;

export class Logger {
  static debug(...args: string[]) {
    hilog.debug(domain, prefix, format, args);
  }

  static info(...args: string[]) {
    hilog.info(domain, prefix, format, args);
  }

  static warn(...args: string[]) {
    hilog.warn(domain, prefix, format, args);
  }

  static error(...args: string[]) {
    hilog.error(domain, prefix, format, args);
  }

  static fatal(...args: string[]) {
    hilog.fatal(domain, prefix, format, args);
  }

  static isLoggable(level: LogLevel) {
    hilog.isLoggable(domain, prefix, level);
  }
}

/**
 * Log level define
 *
 * @syscap SystemCapability.HiviewDFX.HiLog
 */
enum LogLevel {
  DEBUG = 3,
  INFO = 4,
  WARN = 5,
  ERROR = 6,
  FATAL = 7
}
