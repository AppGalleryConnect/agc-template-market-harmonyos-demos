import { AttractionInfo, AttractionsInfo } from 'types';
import { GetAttractionsInfoResp } from '../types/responseTypes/GetAttractionListResp';

export function mapperAttractionsInfo(attractionListResp: GetAttractionsInfoResp) {
  let attractionsInfo: AttractionsInfo = new AttractionsInfo();
  attractionsInfo.banners = attractionListResp.banners;
  attractionListResp.attractions.forEach(item => {
    let attractionInfo = new AttractionInfo();
    attractionInfo.attractionId = item.attractionId;
    attractionInfo.labels = item.labels;
    attractionInfo.detailImages = item.detailImages;
    attractionInfo.name = item.name;
    attractionInfo.introduction = item.introduction
    attractionInfo.banner = item.banner;
    attractionInfo.isHot = item.isHot;
    attractionInfo.longitude = item.longitude;
    attractionInfo.latitude = item.latitude;
    attractionInfo.icon = item.icon;
    attractionInfo.audio = item.audio;
    attractionsInfo.attractions.push(attractionInfo);
  });
  return attractionsInfo;
}