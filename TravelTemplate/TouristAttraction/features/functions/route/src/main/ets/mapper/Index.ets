import { GetRouteLineDetailResp, GetRouteLineListResp } from 'network';
import { AttractionInfo } from 'types';
import { RouteLineInfo } from '../model/RouteLineInfo';

export function mapperRouteLineList(getRouteListResp: GetRouteLineListResp) {
  let routeLineList: RouteLineInfo[] = [];
  getRouteListResp.forEach(item => {
    let routeLine = new RouteLineInfo();
    routeLine.routeId = item.routeId;
    routeLine.routeName = item.routeName;
    routeLine.routeDistance = item.routeDistance;
    routeLine.duration = item.duration;
    routeLine.routeBanner = item.routeBanner;
    routeLine.attractionIds = item.attractionIds;
    routeLineList.push(routeLine);
  });
  return routeLineList;
}

export function mapperRouteLineDetail(getRouteDetailResp: GetRouteLineDetailResp) {
  let routeLine = new RouteLineInfo();
  let attractions: AttractionInfo [] = [];
  routeLine.routeId = getRouteDetailResp.routeId;
  routeLine.routeName = getRouteDetailResp.routeName;
  routeLine.routeDistance = getRouteDetailResp.routeDistance;
  routeLine.duration = getRouteDetailResp.duration;
  routeLine.routeBanner = getRouteDetailResp.routeBanner;
  routeLine.labels = getRouteDetailResp.labels;
  routeLine.brief = getRouteDetailResp.brief;
  routeLine.introduction = getRouteDetailResp.introduction;
  getRouteDetailResp.attractions.forEach((attraction) => {
    let attractionInfo = new AttractionInfo();
    attractionInfo.attractionId = attraction.attractionId;
    attractionInfo.labels = attraction.labels;
    attractionInfo.detailImages = attraction.detailImages;
    attractionInfo.name = attraction.name;
    attractionInfo.banner = attraction.banner;
    attractions.push(attractionInfo);
  });
  routeLine.attractions = attractions;
  return routeLine;
}