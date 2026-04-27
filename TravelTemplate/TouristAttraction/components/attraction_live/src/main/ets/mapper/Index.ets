import { site } from '@kit.MapKit';
import { SystemUtil } from 'module_base';
import { ParkingSlotInfo } from '../model/Index';

export function  mapperParkingSlot(sites: site.Site[], latitude: number, longitude: number) {
  let parkingSlotList: ParkingSlotInfo[] = [];
  sites.forEach(site => {
    let parkingSlotInfo = new ParkingSlotInfo();
    parkingSlotInfo.siteId = site.siteId;
    parkingSlotInfo.name = site.name ?? '';
    parkingSlotInfo.longitude = site.location?.longitude ?? longitude;
    parkingSlotInfo.latitude = site.location?.latitude ?? latitude;
    parkingSlotInfo.distance =
      SystemUtil.calDistance(parkingSlotInfo.longitude,
        parkingSlotInfo.latitude, latitude, longitude);
    parkingSlotInfo.icon = site.poi?.icon ?? '';
    parkingSlotList.push(parkingSlotInfo);
  });
  return parkingSlotList.sort((a, b) => a.distance - b.distance);
}