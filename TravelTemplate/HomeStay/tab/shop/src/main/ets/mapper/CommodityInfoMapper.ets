import { CommodityResp } from 'network';
import { Commodity, PurchaseInfo } from 'type';

export function mapCommodityInfoResponse(response: CommodityResp): Commodity[] {
  const commodityList: Commodity[] = [];
  let commodityResp: Commodity[] = response.data.records;
  commodityResp.forEach((item: Commodity) => {
    let commodityInfo: Commodity = new Commodity();

    commodityInfo.id = item.id;
    commodityInfo.shopId = item.shopId;
    commodityInfo.goodsSn = item.goodsSn;
    commodityInfo.goodsName = item.goodsName;
    commodityInfo.banner = item.banner;
    commodityInfo.imageList = item.imageList;
    commodityInfo.detailImages = item.detailImages;
    commodityInfo.specification = item.specification;
    commodityInfo.counterPrice = item.counterPrice;
    commodityInfo.retailPrice = item.retailPrice;
    commodityInfo.detail = item.detail;
    commodityInfo.saleRule = item.saleRule;
    commodityInfo.count = item.count;

    commodityList.push(commodityInfo);
  });

  return commodityList;
}

export function mapCommodityParam(commodity: Commodity, count: number, index: number,
  specification: string): PurchaseInfo {
  let purchaseInfo: PurchaseInfo = {
    commodityInfo: commodity,
    count: count,
    index: index,
    sfc: specification,
  };
  return purchaseInfo;
}