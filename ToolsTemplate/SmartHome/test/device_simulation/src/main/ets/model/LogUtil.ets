/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the  Eclipse Public License -v 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.eclipse.org/legal/epl-2.0/
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const TAG = 'SmartHomeDevice#';

/**
 * 通用的日志打印类
 */
export class LogUtil {
  public static debug(tag: string, msg: string = ''): void {
    console.debug(`${TAG}[${tag}] ${msg}`);
  }

  public static log(tag: string, msg: string = ''): void {
    console.log(`${TAG}[${tag}] ${msg}`);
  }

  public static info(tag: string, msg: string = ''): void {
    console.info(`${TAG}[${tag}] ${msg}`);
  }

  public static warn(tag: string, msg: string = ''): void {
    console.warn(`${TAG}[${tag}] ${msg}`);
  }

  public static error(tag: string, msg: string = ''): void {
    console.error(`${TAG}[${tag}] ${msg}`);
  }
}