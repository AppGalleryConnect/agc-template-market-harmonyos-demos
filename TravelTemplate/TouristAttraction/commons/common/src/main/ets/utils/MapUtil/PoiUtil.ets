import { site } from '@kit.MapKit';
import { LocationUtil } from './LocationUtil';

export function getPoiListByType(pageIndex: number, poiType: string, range?: number) {
  let params: site.NearbySearchParams = {
    // 指定关键字
    query: '',
    // 经纬度坐标
    location: {
      latitude: LocationUtil.getLocationInfo().latitude,
      longitude: LocationUtil.getLocationInfo().longitude,
    },
    // 指定地理位置的范围半径
    radius: 1000,
    // 指定需要展示的poi类别
    poiTypes: [poiType],
    language: 'zh_CN',
    pageSize: 20,
    pageIndex: pageIndex,
  };
  // 返回周边搜索结果
  return site.nearbySearch(params);
}

export function getPoiListByText(poiText: string, range?: number) {
  let params: site.SearchByTextParams = {
    query: poiText,
    location: {
      latitude: LocationUtil.getLocationInfo().latitude,
      longitude: LocationUtil.getLocationInfo().longitude,
    },
    radius: range,
    language: 'zh_CN',
  };
  return site.searchByText(params);
}