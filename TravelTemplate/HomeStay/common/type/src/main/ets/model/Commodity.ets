export class Commodity {
  id: number;
  shopId: number;
  goodsSn: string;
  goodsName: string;
  banner: ResourceStr;
  detailImages: ResourceStr[];
  imageList: ResourceStr[];
  specification: string;
  counterPrice: number[];
  retailPrice: number[];
  detail: string;
  saleRule: string;
  count: number;

  constructor(
    id: number = 0,
    shopId: number = 0,
    goodsSn: string = '',
    goodsName: string = '',
    banner: ResourceStr = '',
    detailImages: ResourceStr[] = [],
    imageList: ResourceStr[] = [],
    specification: string = '',
    counterPrice: number[] = [],
    retailPrice: number[] = [],
    detail: string = '',
    saleRule: string = '',
    count: number = 0,
  ) {
    this.id = id;
    this.shopId = shopId;
    this.goodsSn = goodsSn;
    this.goodsName = goodsName;
    this.banner = banner;
    this.imageList = imageList;
    this.detailImages = detailImages;
    this.specification = specification;
    this.counterPrice = counterPrice;
    this.retailPrice = retailPrice;
    this.detail = detail;
    this.saleRule = saleRule;
    this.count = count;
  }
}

export class PurchaseInfo {
  commodityInfo: Commodity = new Commodity();
  count: number = 0;
  index: number = 0;
  sfc: string = '';
}