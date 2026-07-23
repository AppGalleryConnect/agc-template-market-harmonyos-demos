export interface GetCommodityDetailResp {
  commodityId: number;
  banner: ResourceStr;
  banners: ResourceStr[];
  detail: string;
  basicSpu: number;
  introduction: string;
  name: string;
  detailImages: ResourceStr[];
  spuInfo: SpuInfo[];
}

export interface SpecValue {
  name: string;
  value: string;
}

export interface SpuInfo {
  spuId: number,
  spuName: string,
  spuOriginalPrice: number,
  spuDiscountPrice: number,
  specValues?: SpecValue[]
}

export interface GetCommodityDetailsResp extends Array<GetCommodityDetailResp> {}