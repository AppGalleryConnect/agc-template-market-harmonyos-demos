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

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';

export class PreferConstant {
  // 意见反馈记录
  static readonly FEEDBACK_RECORDS: string = 'FEEDBACK_RECORDS';
  // 启动页隐私协议
  public static readonly PRIVACY_POLICY_KEY = 'PRIVACY_POLICY';
}

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName)
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName })
      Logger.info(`PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`)
    } catch (e) {
      Logger.error(`Failed to remove preferences from cacheSync. error: ${JSON.stringify(e)}`)
    }
  }

  public static getInstance(fileName: string = 'default', context?: Context) {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!
    }
    let ctx = context || AppStorage.get('context') as common.UIAbilityContext
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(ctx, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil)
    return preferenceUtil
  }

  public put(key: string, value: preferences.ValueType) {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    try {
      this.dataPreferences?.putSync(key, value)
      this.dataPreferences?.flush()
      Logger.info(`PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`)
    } catch (e) {
      Logger.info(`PreferenceUtil: put error: ${JSON.stringify(e)}`)
    }
  }

  public get(key: string, defaultValue?: preferences.ValueType) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue)
      Logger.info(`PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`)
      return data
    } catch (e) {
      Logger.info(`PreferenceUtil: get error: ${JSON.stringify(e)}`)
      return defaultValue
    }
  }

  public hasSync(key: string): boolean {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return false
    }
    return this.dataPreferences?.hasSync(key)
  }

  public getAllSync(): object | null {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return null
    }
    return this.dataPreferences.getAllSync()
  }

  public delete(key: string) {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    try {
      // 删除
      this.dataPreferences?.deleteSync(key)
      this.dataPreferences?.flush()
      Logger.info('PreferenceUtil', '删除Preferences[${key} = ${value}]成功');
    } catch (e) {
      Logger.info('PreferenceUtil', '删除Preferences[${key} = ${value}]失败' + JSON.stringify(e));
    }
  }

  clear() {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return;
    }
    try {
      this.dataPreferences.clearSync()
      this.dataPreferences?.flush()
    } catch (e) {
      Logger.info('PreferenceUtil', 'clear失败' + JSON.stringify(e));
    }
  }

  isClear(): boolean {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
      return true
    }
    let arr: [] = [];
    let value = this.dataPreferences.getAllSync()
    if (value) {
      arr = Object.values(value) as [];
    }
    if (arr.length === 0) {
      return true
    }
    return false
  }
}