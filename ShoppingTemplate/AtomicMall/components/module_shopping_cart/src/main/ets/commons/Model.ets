import { CartProductInfo, PriceType } from 'lib_network';

@ObservedV2
export class ProductModel implements CartProductInfo {
  public productId: string = '';
  public skuCode: string = '';
  @Trace public skuDesc: string = '';
  @Trace public stock: number = 0;
  @Trace public count: number = 0;
  @Trace public banner: string = '';
  @Trace public title: string = '';
  @Trace public serviceDesc: string = '';
  @Trace public price: number = 0;
  @Trace public dashPrice: number = 0;
  @Trace public isSelected: boolean = false;
  @Trace public priceType: PriceType = PriceType.NORMAL;
  @Trace public slotId?: string | undefined;

  constructor(product?: CartProductInfo) {
    if (product) {
      this.productId = product.productId;
      this.skuCode = product.skuCode;
      this.skuDesc = product.skuDesc;
      this.stock = product.stock;
      this.count = product.count;
      this.banner = product.banner;
      this.title = product.title;
      this.serviceDesc = product.serviceDesc;
      this.price = product.price;
      this.dashPrice = product.dashPrice;
      this.priceType = product.priceType;
      this.slotId = product.slotId;
    }
  }
}

export class PopupSheetController {
  hide: () => void = () => {
  };
}
