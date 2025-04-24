export interface GetCommodityDetailResp {
  commodityId: number;
  banner: ResourceStr;
  banners: ResourceStr[];
  detail: string;
  basicSpu: number;
  introduction: string;
  name: string;
  detailImages: ResourceStr[];
  spuInfo: SpuInfo[]
}

export interface SpuInfo {
  spuId: number,
  spuName: string,
  spuOriginalPrice: number,
  spuDiscountPrice: number,
}

export interface GetCommodityDetailsResp extends Array<GetCommodityDetailResp> {}