import { AdapterModel, ClassifiedProducts } from 'external_interactions';

@ObservedV2
export class ProductListViewModel {
  @Trace products: ClassifiedProducts[] = []

  constructor() {
    this.products = AdapterModel.getInstance().getAllProducts();
  }
}