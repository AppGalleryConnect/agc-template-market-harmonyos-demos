import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import { IProductItem, } from 'network/src/main/ets/types/responseTypes/GetProductResp';

const TAG = '[ProductSearchVM]';

@ObservedV2
export class ProductSearchVM {
  private static _instance: ProductSearchVM;
  @Trace public total: number = 0
  @Trace public productList: IProductItem[] = []
  @Trace public searchText: string = ''

  public static get instance() {
    if (!ProductSearchVM._instance) {
      ProductSearchVM._instance = new ProductSearchVM();
    }
    return ProductSearchVM._instance;
  }

  search(value: string) {
    this.getProductList(value)
  }

  clear() {
    this.total = 0
    this.productList = []
    this.searchText = ''
  }

  public async getProductList(searchText: string) {
    const res = await https.getProductList({ searchText: searchText });
    if (res.code === 0) {
      this.productList = res.data;
    }
  }
}
