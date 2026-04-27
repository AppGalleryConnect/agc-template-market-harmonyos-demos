import { ProductInfo } from '../viewmodel/MainPageVM'

@ObservedV2
export class ProductInfoManager {
  // 搜索字段
  @Trace searchField: string = ''
  // 产品列表
  @Trace productList: Array<ProductInfo> = []

  constructor(searchField: string, productList: Array<ProductInfo>) {
    this.searchField = searchField
    this.productList = productList
  }
}