export interface CommodityListItem {
  commodityId: number;
  banner: ResourceStr;
  basicSpu: number;
  name: string;
  spuInfo: SpuInfo[]
}

export interface SpuInfo {
  spuId: number,
  spuName: string,
  spuOriginalPrice: number,
  spuDiscountPrice: number,
}

export interface GetCommodityListResp extends Array<CommodityListItem> {}