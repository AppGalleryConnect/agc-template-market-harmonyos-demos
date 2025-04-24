import { GetCommodityDetailResp, GetCommodityListResp } from 'network';
import { CommodityInfo } from '../model/CommodityInfo';

export function mapperCommodityList(getCommodityListResp: GetCommodityListResp) {
  let commodityList: CommodityInfo[] = [];
  getCommodityListResp.forEach(item => {
    let commodityInfo = new CommodityInfo();
    commodityInfo.commodityId = item.commodityId;
    commodityInfo.banner = item.banner;
    commodityInfo.basicSpu = item.basicSpu;
    commodityInfo.name = item.name;
    commodityInfo.spuInfo = item.spuInfo;
    commodityList.push(commodityInfo);
  });
  return commodityList;
}

export function mapperCommodityDetail(getCommodityDetailResp: GetCommodityDetailResp) {
  let commodityInfo = new CommodityInfo();
  commodityInfo.commodityId = getCommodityDetailResp.commodityId;
  commodityInfo.banner = getCommodityDetailResp.banner;
  commodityInfo.basicSpu = getCommodityDetailResp.basicSpu;
  commodityInfo.name = getCommodityDetailResp.name;
  commodityInfo.spuInfo = getCommodityDetailResp.spuInfo;
  commodityInfo.banners = getCommodityDetailResp.banners;
  commodityInfo.introduction = getCommodityDetailResp.introduction;
  commodityInfo.detailImages = getCommodityDetailResp.detailImages;
  commodityInfo.detail = getCommodityDetailResp.detail;
  return commodityInfo;
}