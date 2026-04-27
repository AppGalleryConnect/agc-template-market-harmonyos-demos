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

export class CommonUtils {
  /**
   * 时间戳转换年月日xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() + 1)}-${CommonUtils.padZero(date.getDate())}`;
  }

  /**
   * 不足的补零
   * @param input
   * @returns
   */
  static padZero(input: number): string {
    return input.toString().padStart(2, '0');
  }
}