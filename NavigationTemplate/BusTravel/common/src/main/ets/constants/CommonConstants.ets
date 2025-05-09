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

import { Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';

export class CommonConstants {
  /**
   * Permissions.
   */
  static readonly PERMISSIONS: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION'];
  static readonly locationRequest: geoLocationManager.CurrentLocationRequest = {
    'priority': geoLocationManager.LocationRequestPriority.ACCURACY,
    'scenario': geoLocationManager.LocationRequestScenario.UNSET,
    'maxAccuracy': 20
  };
  /**
   * Constant for screen dpi.
   */
  static readonly SCREEN_DPI_CONSTANT: number = 160;
  /**
   * Full width.
   */
  static readonly FULL_WIDTH: string = '100%';
  /**
   * Full height.
   */
  static readonly FULL_HEIGHT: string = '100%';
  /**
   * Column lower height.
   */
  static readonly HEIGHT_LOW: number = 150;
  /**
   * Column middle height.
   */
  static readonly HEIGHT_MIDDLE: number = 369;
  /**
   * Column higher height of md.
   */
  static readonly HEIGHT_MD: number = 599;
  /**
   * Slide up judging distance.
   */
  static readonly UP_SLIDE: number = -20;
  /**
   * Slide down judging distance.
   */
  static readonly DOWN_SLIDE: number = 20;
  /**
   * Column margin left of md.
   */
  static readonly LEFT_MD: number = 24;
  /**
   * Change position line.
   */
  static readonly CHANGE: number = 200;
  /**
   * Column margin right of md.
   */
  static readonly RIGHT_MD: number = 350;
  /**
   * Route avoidance feature array.
   */
  static readonly AVOIDS: Array<number> = [0, 4, 32];
  /**
   * Camera duration.
   */
  static readonly DURATION: number = 200;
  /**
   * LatLng zoom.
   */
  static readonly ZOOM: number = 15;
  static readonly CLOUDCARD: string = 'cloudCard';
  static readonly CLOUDCARD_USE: string = 'close';
}