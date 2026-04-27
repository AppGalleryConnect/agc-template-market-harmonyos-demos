export interface SpuInfo {
  spuId: number,
  spuName: string,
  spuOriginalPrice: number,
  spuDiscountPrice: number,
}

export class CommodityInfo {
  commodityId: number = 0
  banner: ResourceStr = ''
  banners: ResourceStr[] = []
  detail: string = ''
  basicSpu: number = 0
  introduction: string = ''
  name: string = ''
  detailImages: ResourceStr[] = []
  spuInfo: SpuInfo[] = []
}

export class PurchaseInfo {
  commodityInfo: CommodityInfo = new CommodityInfo()
  selectedSpu: number = 0
}