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

export interface SpecOption {
  id: string;
  name: string;
}

export interface SpecCategory {
  id: string;
  name: string;
  options: SpecOption[];
}

export class CommodityInfo {
  commodityId: number = 0;
  banner: ResourceStr = '';
  banners: ResourceStr[] = [];
  detail: string = '';
  basicSpu: number = 0;
  introduction: string = '';
  name: string = '';
  detailImages: ResourceStr[] = [];
  spuInfo: SpuInfo[] = [];
  specCategories: SpecCategory[] = [];
}

export class PurchaseInfo {
  commodityInfo: CommodityInfo = new CommodityInfo();
  selectedSpu: number = 0;
}