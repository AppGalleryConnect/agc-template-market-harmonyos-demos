import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { LocationInfo } from 'types';
import { map, mapCommon } from '@kit.MapKit';

export class LocationUtil {
  private static locationInfo: LocationInfo =
    PersistenceV2.connect(LocationInfo, 'locationInfo', () => new LocationInfo())!;

  public static getLocationInfo() {
    return LocationUtil.locationInfo;
  }

  public static setLocationInfo(longitude: number, latitude: number) {
    LocationUtil.locationInfo.longitude = longitude;
    LocationUtil.locationInfo.latitude = latitude;
  }

  public static calDistance(parkingLot: number, parkingLat: number) {
    let fromLatLng: mapCommon.LatLng = {
      latitude: LocationUtil.locationInfo.latitude,
      longitude: LocationUtil.locationInfo.longitude,
    };
    let toLatLng: mapCommon.LatLng = {
      latitude: parkingLat,
      longitude: parkingLot,
    };

    return map.calculateDistance(fromLatLng, toLatLng);
  }
}