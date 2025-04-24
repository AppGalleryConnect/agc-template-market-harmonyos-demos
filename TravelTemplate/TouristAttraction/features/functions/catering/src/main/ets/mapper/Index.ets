import { site } from '@kit.MapKit';
import { AccommodationInfo, CateringInfo } from 'types';

export function mapAccommodationInfo(sites: site.Site[]) {
  let accommodationList: AccommodationInfo[] = [];
  sites.forEach((item: site.Site) => {
    let accommodationInfo = new AccommodationInfo();
    accommodationInfo.siteId = item.siteId;
    accommodationInfo.distance = item.distance ?? 0;
    accommodationInfo.name = item.name ?? '';
    accommodationInfo.longitude = item.location?.longitude ?? 0;
    accommodationInfo.latitude = item.location?.latitude ?? 0;
    accommodationInfo.address = item.formatAddress ?? '';
    accommodationInfo.phone = item.poi?.phone ?? '';
    accommodationInfo.comments = item.poi?.comment?.total ?? 0;
    accommodationInfo.rating = item.poi?.comment?.averageRating ?? 0;
    // mock图片
    accommodationInfo.banner = item.poi?.icon ?? $r('app.media.app_icon');
    accommodationList.push(accommodationInfo);
  });
  return accommodationList;
}

export function mapCateringInfo(sites: site.Site[]) {
  let cateringList: CateringInfo[] = [];
  sites.forEach((item: site.Site) => {
    let cateringInfo = new CateringInfo();
    cateringInfo.siteId = item.siteId;
    cateringInfo.distance = item.distance ?? 0;
    cateringInfo.name = item.name ?? '';
    cateringInfo.longitude = item.location?.longitude ?? 0;
    cateringInfo.latitude = item.location?.latitude ?? 0;
    cateringInfo.address = item.formatAddress ?? '';
    cateringInfo.phone = item.poi?.phone ?? '';
    cateringInfo.comments = item.poi?.comment?.total ?? 0;
    cateringInfo.rating = item.poi?.comment?.averageRating ?? 0;
    cateringList.push(cateringInfo);
    // mock图片
    cateringInfo.banner = item.poi?.icon ?? $r('app.media.app_icon');
  });
  return cateringList;
}