import { AdapterModel, ProductOnShow } from 'external_interactions';

export class ProductViewModel {
  productsOnShow: ProductOnShow[] = [];

  constructor() {
    this.productsOnShow = AdapterModel.getInstance().getProductsOnShow();
  }
}