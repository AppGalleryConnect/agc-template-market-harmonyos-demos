import { Permissions } from '@kit.AbilityKit';
import { map, mapCommon, site } from '@kit.MapKit';
import { PermissionUtil } from './PermissionUtil';
import { geoLocationManager } from '@kit.LocationKit';
import { Logger } from '../../../../Index';

const TAG: string = '[LocationUtil]';

export class LocationUtil {
  public static async getLocationName(): Promise<string | undefined> {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
    let addressName: string | undefined;
    const allowGetPosition = await PermissionUtil.requestPermissions(permissions);
    if (allowGetPosition) {
      const location = await geoLocationManager.getCurrentLocation();
      if (location) {
        let wgs84Position: mapCommon.LatLng = {
          latitude: location.latitude,
          longitude: location.longitude
        }
        try {
          let gcj02Position: mapCommon.LatLng =
            map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
          const res = await site.nearbySearch({
            location: gcj02Position,
            language: 'zh',
            radius: 200
          });
          if (res && res.sites) {
            addressName = res.sites[0].name;
          }
        } catch (err) {
          Logger.error(TAG, `'get address failed with err: ${JSON.stringify(err)}`);
        }
      }
    }

    return addressName;
  }
}