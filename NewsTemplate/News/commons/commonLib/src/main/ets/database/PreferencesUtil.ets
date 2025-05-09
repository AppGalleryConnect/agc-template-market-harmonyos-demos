/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { GlobalContext } from '../utils/GlobalContext';
import { Logger } from '../utils/Logger';

const TAG = '[PreferencesUtil]';
const PREFERENCES_NAME = 'myPreferences';
const KEY_APP_FONT_SIZE = 'newsAppFontSize';

/**
 * The PreferencesUtil provides preferences of create, save and query.
 */
export class PreferencesUtil {
  constructor() {

  }
  public static createFontPreferences(context: Context) {
    let fontPreferences: Function = (() => {
      let preference: Promise<preferences.Preferences> = preferences.getPreferences(context, PREFERENCES_NAME);
      return preference;
    });
    GlobalContext.getContext().setObject('getFontPreferences', fontPreferences);
  }

  public static saveDefaultFontSize(fontSize: number) {
    let getFontPreferences: Function = GlobalContext.getContext().getObject('getFontPreferences') as Function;
    getFontPreferences().then((preferences: preferences.Preferences) => {
      preferences.has(KEY_APP_FONT_SIZE).then(async (isExist: boolean) => {
        Logger.info(TAG, 'preferences has changeFontSize is ' + isExist);
        if (!isExist) {
          await preferences.put(KEY_APP_FONT_SIZE, fontSize);
          preferences.flush();
        }
      }).catch((err: Error) => {
        Logger.error(TAG, 'Has the value failed with err: ' + err);
      });
    }).catch((err: Error) => {
      Logger.error(TAG, 'Get the preferences failed, err: ' + err);
    });
  }

  public static saveChangeFontSize(fontSize: number) {
    let getFontPreferences: Function = GlobalContext.getContext().getObject('getFontPreferences') as Function;
    getFontPreferences().then(async (preferences: preferences.Preferences) => {
      await preferences.put(KEY_APP_FONT_SIZE, fontSize);
      preferences.flush();
    }).catch((err: Error) => {
      Logger.error(TAG, 'put the preferences failed, err: ' + err);
    });
  }

  public static async getChangeFontSize() {
    let fontSize: number = 0;
    let getFontPreferences: Function = GlobalContext.getContext().getObject('getFontPreferences') as Function;
    fontSize = await (await getFontPreferences()).get(KEY_APP_FONT_SIZE, fontSize);
    return fontSize;
  }

  public static async deleteChangeFontSize() {
    let getFontPreferences: Function = GlobalContext.getContext().getObject('getFontPreferences') as Function;
    const preferences: preferences.Preferences = await getFontPreferences();
    let deleteValue = preferences.delete(KEY_APP_FONT_SIZE);
    deleteValue.then(() => {
      Logger.info(TAG, 'Succeeded in deleting the key appFontSize.');
    }).catch((err: Error) => {
      Logger.error(TAG, 'Failed to delete the key appFontSize. Cause: ' + err);
    });
  }
}

export default new PreferencesUtil();