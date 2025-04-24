import { site } from '@kit.MapKit';
import { LocationUtil } from 'common';
import { AttractionListItem, GetAttractionsInfoResp } from 'network';
import { ToiletInfo } from 'types';
import { SiteInfo } from '../model/GuideInfo';

export function mapSiteInfo(sitesResp: site.Site[], type: number) {
  let sites: SiteInfo[] = [];
  sitesResp.forEach((item: site.Site) => {
    let siteInfo = new SiteInfo();
    siteInfo.siteId = item.siteId;
    siteInfo.name = item.name ?? '';
    siteInfo.icon = item.poi?.icon ?? '';
    siteInfo.location = item.formatAddress ?? '';
    siteInfo.longitude = item.location?.longitude ?? 0;
    siteInfo.latitude = item.location?.latitude ?? 0;
    siteInfo.audio = '';
    sites.push(siteInfo);
  });
  return sites;
}

export function mapAttractionSite(attractionsInfoResp: GetAttractionsInfoResp) {
  let attractionSites: SiteInfo[] = [];
  attractionsInfoResp.attractions.forEach((item: AttractionListItem) => {
    let siteInfo = new SiteInfo();
    siteInfo.siteId = item.attractionId.toString();
    siteInfo.name = item.name ?? '';
    siteInfo.icon = item.icon;
    attractionSites.push(siteInfo);
  });
  return attractionSites;
}

export function mapperToilet(sites: site.Site[]) {
  let toiletList: ToiletInfo[] = [];
  sites.forEach(site => {
    let toiletInfo = new ToiletInfo();
    toiletInfo.siteId = site.siteId;
    toiletInfo.name = site.name ?? '';
    toiletInfo.longitude = site.location?.longitude ?? LocationUtil.getLocationInfo().longitude;
    toiletInfo.latitude = site.location?.latitude ?? LocationUtil.getLocationInfo().latitude;
    toiletInfo.distance =
      LocationUtil.calDistance(toiletInfo.longitude,
        toiletInfo.latitude);
    // 转换为PixelMap
    toiletInfo.icon = site.poi?.icon ?? '';
    toiletList.push(toiletInfo);
  });
  return toiletList;
}