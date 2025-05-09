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

import { geoLocationManager } from '@kit.LocationKit';
import { map } from '@kit.MapKit';
import { CommonConstants } from '../constants/CommonConstants';
import { Logger } from './Logger';

export class LocationUtil {
  async getLocation(mapController?: map.MapComponentController): Promise<geoLocationManager.Location> {
    let promise = geoLocationManager.getCurrentLocation();
    Logger.info('getCurrentLocation' + JSON.stringify(promise));
    promise.then(async (location: geoLocationManager.Location) => {
      mapController?.setMyLocation(location);
      mapController?.animateCamera(map.newLatLng({
        latitude: location.latitude,
        longitude: location.longitude
      }, CommonConstants.ZOOM), CommonConstants.DURATION);
      return location;
    }).catch((error: Error) => {
      Logger.error('getCurrentLocation failed', 'getCurrentLocation error: ' + JSON.stringify(error));
    });
    return promise;
  }
}

export default new LocationUtil();