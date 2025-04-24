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

import { AppStorageBank, SystemSceneUtils, updateCurrentCity } from 'utils';
import { ICityGroup } from './Model';

/**
 * 工具类
 */
export class Utils {
  static generateAlphaList(cityGroupList: ICityGroup[]) {
    return cityGroupList.map(v => v.name);
  }

  static applyLocationPermission(): Promise<boolean> {
    return new Promise((resolve) => {
      SystemSceneUtils.applyLocationPermission().then((isGranted) => {
        if (isGranted) {
          SystemSceneUtils.getCurrentCityInfo().then((city: string) => {
            if (city) {
              Utils.updateCityCurrentInfo(city);
              resolve(true);
            } else {
              resolve(true);
            }
          })
        } else {
          resolve(false);
        }
      })
    })
  }

  static updateCityCurrentInfo(city: string) {
    updateCurrentCity(city).then(() => {
      AppStorageBank.updateCityCurrent(city);
    })
  }
}