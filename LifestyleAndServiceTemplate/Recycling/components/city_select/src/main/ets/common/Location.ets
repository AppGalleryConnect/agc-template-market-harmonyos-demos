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

import {
  abilityAccessCtrl,
  bundleManager,
  common,
  PermissionRequestResult,
  Permissions
} from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { City } from './Model';

const TAG: string = '[CitySelect]'
const DOMAIN: number = 0xFF00

export const getLocationCity = (): Promise<City | undefined> => {
  return new Promise((resolve) => {
    applyLocationPermission().then((isGranted) => {
      if (isGranted) {
        getCurrentCityInfo().then((city) => {
          resolve(city);
        })
      } else {
        resolve(undefined);
      }
    })
  })
}

/**
 * 向用户申请位置权限
 * @returns
 */
let isApplyLocPermAgain = false;

export function setApplyLocPermAgain(data: boolean) {
  isApplyLocPermAgain = data;
}
const applyLocationPermission = async (): Promise<boolean> => {
  const permission: Permissions = 'ohos.permission.APPROXIMATELY_LOCATION';
  const isGrantedAppLo = await checkPermissionGrant(permission);
  if (isGrantedAppLo) {
    return true;
  }
  const context = getContext() as common.UIAbilityContext
  // 向用户申请
  const atManager = abilityAccessCtrl.createAtManager();
  return atManager.requestPermissionsFromUser(context, [permission])
    .then(async (result: PermissionRequestResult) => {
      if (result.authResults.every(v => v === 0)) {
        return true;
      }
      // 二次向用户申请
      if (isApplyLocPermAgain) {
        const resp = await atManager.requestPermissionOnSetting(context, [permission]);
        return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
      }
      isApplyLocPermAgain = true;
      return false;
    });
}

/**
 * 检查用户是否授权
 * @param permission
 * @returns
 */
const checkPermissionGrant = async (permission: Permissions): Promise<boolean> => {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

  // 获取应用程序的accessTokenID
  let tokenId: number = 0;
  try {
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    tokenId = bundleInfo.appInfo.accessTokenId;
  } catch (error) {
    const err: BusinessError = error as BusinessError;
  }

  // 校验应用是否被授予权限
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
  } catch (error) {
    const err: BusinessError = error as BusinessError;
  }

  return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
}

/**
 * 获取当前所在城市位置
 * @returns
 */
const getCurrentCityInfo = async (): Promise<City | undefined> => {
  try {
    const requestInfo: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      timeoutMs: 1000,
    };
    const currentLocation = await geoLocationManager.getCurrentLocation(requestInfo);

    const reverseGeoCodeReq: site.ReverseGeocodeParams = {
      location: currentLocation,
      language: 'zh_CN',
    };
    const reverseGeocodeResult = await site.reverseGeocode(reverseGeoCodeReq);
    if (reverseGeocodeResult.addressComponent.city?.cityName) {
      return {
        name: reverseGeocodeResult.addressComponent.city.cityName,
        code: reverseGeocodeResult.addressComponent.adminCode ?? '',
      }
    }
    return undefined;
  } catch (e) {
    return undefined;
  }
}