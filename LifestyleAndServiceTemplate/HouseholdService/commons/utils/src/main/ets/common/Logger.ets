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

import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static domain: number;
  private static prefix: string;
  private static format: string = '%{public}s';

  constructor(prefix: string = '[HouseholdTemplate]', domain: number = 0xFF00) {
    Logger.prefix = prefix;
    Logger.domain = domain;
  }

  static debug(...args: Object[]): void {
    hilog.debug(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static info(...args: Object[]): void {
    hilog.info(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static warn(...args: Object[]): void {
    hilog.warn(Logger.domain, Logger.prefix, Logger.format, args);
  }

  static error(...args: Object[]): void {
    hilog.error(Logger.domain, Logger.prefix, Logger.format, args);
  }
}
