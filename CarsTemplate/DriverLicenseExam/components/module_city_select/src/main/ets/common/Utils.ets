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
  Context,
  Permissions
} from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ICityGroup } from './Model';

/**
 * 日志类
 */
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

/**
 * 工具类
 */
export class Utils {
  static generateAlphaList(cityGroupList: ICityGroup[]) {
    return cityGroupList.map(v => v.name);
  }

  static applyLocationPermission(): Promise<string> {
    return new Promise((resolve) => {
      SystemSceneUtils.applyLocationPermission().then((isGranted) => {
        if (isGranted) {
          SystemSceneUtils.getCurrentCityInfo().then((city: string) => {
            resolve(city);
          })
        } else {
          resolve('');
        }
      })
    })
  }
}

/**
 * 系统Utils
 */
export class SystemSceneUtils {
  static isApplyLocPermAgain: boolean = false;
  static context: Context = getContext() as common.UIAbilityContext;

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  static async checkPermissionGrant(permission: Permissions): Promise<boolean> {
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
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 向用户申请位置权限
   * @returns
   */
  static async applyLocationPermission(): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];
    const isGrantedAppLo = await SystemSceneUtils.checkPermissionGrant(permissions[0]);

    if (isGrantedAppLo) {
      Logger.info('already granted location and approximate location permissions')
      return true;
    }
    if (!SystemSceneUtils.context) {
      SystemSceneUtils.context = getContext() as common.UIAbilityContext;
    }
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const result =
        await atManager.requestPermissionsFromUser(SystemSceneUtils.context, permissions);
      if (result.authResults.every(v => v === 0)) {
        return true;
      }
      if (SystemSceneUtils.isApplyLocPermAgain) {
        const resp = await atManager.requestPermissionOnSetting(SystemSceneUtils.context, permissions);
        return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
      }
      SystemSceneUtils.isApplyLocPermAgain = true;
      return false;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to request location permissions. Code is ${err.code}, message is ${err.message}`);
      return false;
    }
  }

  /**
   * 获取当前所在城市位置
   * @returns
   */
  static async getCurrentCityInfo(): Promise<string> {
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
      Logger.info('reverseGeocodeResult=' + JSON.stringify(reverseGeocodeResult));
      return reverseGeocodeResult.addressComponent.city?.cityName ?? '';
    } catch (e) {
      Logger.error('getCurrentCityInfo fail, error: ' + JSON.stringify(e));
      return '';
    }
  }
}