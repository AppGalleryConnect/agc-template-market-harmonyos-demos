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
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'PreferencesUtil';
const DOMAIN: number = 0x0000;
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
      preferences.flush((err: BusinessError | undefined) => {
        if (err !== undefined) {
          hilog.error(DOMAIN, TAG, 'Failed to flush. Code:%{public}d, message:%{public}s', err.code, err.message);
        }
      });
    } catch (e) {
      const err = e as BusinessError;
      hilog.error(DOMAIN, TAG, 'flush threw. Code:%{public}d, message:%{public}s', err.code, err.message);
    }
  }

  preferencesPut(preferences: preferences.Preferences, key: string, value: preferences.ValueType): void {
    preferences.putSync(key, value);
    this.preferencesFlush(preferences);
  }

  // 获取数据
  getPreferencesValue(preferences: preferences.Preferences, key: string): preferences.ValueType {
    if (preferences === null) {
      hilog.error(DOMAIN, TAG, 'preferences is null');
      return '';
    }
    return preferences.getSync(key, '');
  }
  //判断是否包含key
  hasPreferencesKey(preferences: preferences.Preferences, key: string): boolean {
    if (preferences === null) {
      hilog.error(DOMAIN, TAG, 'preferences is null');
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
      hilog.error(DOMAIN, TAG, 'preferences is null');
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
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, 'addFormId failed. Code:%{public}d, message:%{public}s', err.code, err.message);
    }
  }

  removeFormId(context: Context, formId: string) {
    try {
      let preferences = this.getPreferences(context);
      if (preferences === null) {
        hilog.error(DOMAIN, TAG, 'preferences is null');
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
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, 'removeFormId failed. Code:%{public}d, message:%{public}s', err.code, err.message);
    }
  }
}