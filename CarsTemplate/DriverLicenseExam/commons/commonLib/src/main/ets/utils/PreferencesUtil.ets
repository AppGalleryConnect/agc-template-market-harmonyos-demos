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
import { Logger } from './Logger';

const TAG: string = 'PreferencesUtil';
const MY_STORE: string = 'myStore';

export class PreferencesUtil {
  private static preferencesUtil: PreferencesUtil;

  public static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.preferencesUtil) {
      PreferencesUtil.preferencesUtil = new PreferencesUtil();
    }
    return PreferencesUtil.preferencesUtil;
  }

  getPreferences(context: Context): preferences.Preferences {
    try {
      preferences.removePreferencesFromCacheSync(context, MY_STORE);
    } catch (e) {
    }

    return preferences.getPreferencesSync(context, { name: MY_STORE });
  }

  preferencesFlush(preferences: preferences.Preferences) {
    try {
      preferences.flush((err) => {
        if (err) {
          Logger.error(TAG, `Failed to flush. Code:${err.code}, message:${err.message}`);
        }
      })
    } catch (e) {
      Logger.error(TAG, `Failed to call preferences.flush: ${JSON.stringify(e)}`);
    }
  }

  preferencesPut(preferences: preferences.Preferences, key: string, value: preferences.ValueType): void {
    preferences.putSync(key, value);
    this.preferencesFlush(preferences);
  }

  // 获取数据
  getPreferencesValue(preferences: preferences.Preferences, key: string): preferences.ValueType {
    if (preferences === null) {
      Logger.error(TAG, `preferences is null`);
      return '';
    }
    return preferences.getSync(key, '');
  }
  //判断是否包含key
  hasPreferencesKey(preferences: preferences.Preferences, key: string): boolean {
    if (preferences === null) {
      Logger.error(TAG, `preferences is null`);
      return false;
    }
    return preferences.hasSync(key);
  }

  removePreferencesFromCache(context: Context): void {
    try {
      preferences.removePreferencesFromCache(context, MY_STORE);
    } catch (e) {
    }
  }

  getFormIds(preferences: preferences.Preferences): Array<string> {
    if (preferences === null) {
      Logger.error(TAG, `preferences is null`);
      return [];
    }
    return preferences.getSync('formIdList', ['']) as Array<string>;
  }

  addFormId(preferences: preferences.Preferences, formId: string): void {
    try {
      if (preferences.hasSync('formIdList')) {
        let formIds = this.getFormIds(preferences);
        if (formIds.indexOf(formId) === -1) {
          formIds.push(formId);
          this.preferencesPut(preferences, 'formIdList', formIds);
        }
      } else {
        this.preferencesPut(preferences, 'formIdList', [formId]);
      }
      this.preferencesFlush(preferences);
    } catch (error) {
      Logger.error(TAG, `Failed to check the key 'formIds'. Code:${error.code}, message:${error.message}`);
    }
  }

  removeFormId(context: Context, formId: string) {
    try {
      let preferences = this.getPreferences(context);
      if (preferences === null) {
        Logger.error(TAG, `preferences is null`);
        return;
      }
      if (preferences.hasSync('formIdList')) {
        let formIds = this.getFormIds(preferences);
        let index = formIds.indexOf(formId);
        if (index !== -1) {
          formIds.splice(index, 1);
        }
        this.preferencesPut(preferences, 'formIdList', formIds);
        if (preferences.hasSync(`${formId}_show_index`)) {
          preferences.deleteSync(`${formId}_show_index`);
        }
        this.preferencesFlush(preferences);
      }
    } catch (error) {
      Logger.error(TAG, `Failed to get preferences. Code:${error.code}, message:${error.message}`);
    }
  }
}