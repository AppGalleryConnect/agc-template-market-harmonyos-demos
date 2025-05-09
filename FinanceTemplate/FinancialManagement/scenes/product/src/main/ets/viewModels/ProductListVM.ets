import { https } from 'network';
import { RouterMap, RouterModule, } from 'commonlib';
import { IProductItem, SaleState } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { ISettingData } from 'network/src/main/ets/mocks/Constants';

interface IParamData {
  type: number,
  index: number,
}

const TAG = '[ProductListVM]';

@ObservedV2
export class ProductListVM {
  private static _instance: ProductListVM;
  // 接口数据
  @Trace public productList: IProductItem[] = []
  @Trace public saleTypeList: ISettingData[] = []
  @Trace public minimumPurchaseAmountList: ISettingData[] = []
  @Trace public riskLevelList: ISettingData[] = []
  @Trace public arrangementList: ISettingData[] = []
  //页面数据
  @Trace public selectSaleTypeList: SelectOption[] = []
  @Trace public selectArrangementList: SelectOption[] = []
  @Trace public currentIndex: number = 0
  @Trace public selectedIndex: number = 0
  @Trace public searchText: string = ''
  @Trace public saleType: number = 1
  @Trace public minimumPurchaseAmount: number = 1
  @Trace public riskLevel: number = 1
  @Trace public productType: number = 1
  @Trace public arrangement: number = 1
  @Trace public isSelecting: boolean = false

  public static get instance() {
    if (!ProductListVM._instance) {
      ProductListVM._instance = new ProductListVM();
    }
    return ProductListVM._instance;
  }

  init() {
    this.getSaleTypeList()
    this.getMinimumPurchaseAmountList()
    this.getRiskLevelList()
    this.getArrangementList()
    const param: IParamData | undefined = RouterModule.getNavParam({ url: RouterMap.PRODUCT_LIST })
    if (param) {
      this.currentIndex = param.index
      this.selectedIndex = param.index
      this.productType = param.type
      this.getProductList(this.productType, this.saleType, this.arrangement)
    }
  }

  clear() {
    this.selectSaleTypeList = []
    this.selectArrangementList = []
    this.currentIndex = 0
    this.selectedIndex = 0
    this.searchText = ''
    this.saleType = 1
    this.minimumPurchaseAmount = 1
    this.riskLevel = 1
    this.productType = 1
    this.arrangement = 1
  }

  refresh(productType: number) {
    this.saleType = 1
    this.minimumPurchaseAmount = 1
    this.riskLevel = 1
    this.productType = productType + 1
    this.isSelecting = false
    this.getProductList(this.productType, this.saleType, this.arrangement)
  }

  search() {
    this.getProductList(this.productType, this.saleType, this.arrangement)
  }

  filter() {
    const risk = this.getLabel(this.riskLevelList, this.riskLevel)
    this.getProductList(this.productType, this.saleType, this.arrangement, risk, this.minimumPurchaseAmount)
  }

  reset() {
    this.saleType = 1
    this.minimumPurchaseAmount = 1
    this.riskLevel = 1
    this.search()
  }

  public async getProductList(type: number, saleType?: number, arrangement?: number, risk?: string, eachCost?: number) {
    const res = await https.getProductList({
      productType: type,
      saleType,
      arrangement,
      risk,
      eachCost
    });
    if (res.code === 0) {
      this.productList = res.data;
    }
  }

  public async getSaleTypeList() {
    const res = await https.getSaleTypeList();
    if (res.code === 0) {
      this.saleTypeList = res.data;
      this.saleTypeList.forEach((item) => {
        const data: SelectOption = {
          value: item.label
        }
        this.selectSaleTypeList.push(data)
      })
    }
  }

  public async getMinimumPurchaseAmountList() {
    const res = await https.getMinimumPurchaseAmountList();
    if (res.code === 0) {
      this.minimumPurchaseAmountList = res.data;
    }
  }

  public async getRiskLevelList() {
    const res = await https.getRiskLevelList();
    if (res.code === 0) {
      this.riskLevelList = res.data;
    }
  }

  public async getArrangementList() {
    const res = await https.getArrangementList();
    if (res.code === 0) {
      this.arrangementList = res.data;
      this.arrangementList.forEach((item) => {
        const data: SelectOption = {
          value: item.label
        }
        this.selectArrangementList.push(data)
      })
    }
  }

  public getValue(arr: ISettingData[], label: string): number {
    const saleType = arr.find((item) => {
      return item.label === label
    })
    if (saleType) {
      return saleType.value
    }
    return 1
  }

  public getLabel(arr: ISettingData[], value: number): string {
    const saleType = arr.find((item) => {
      return item.value === value
    })
    if (saleType) {
      return saleType.label
    }
    return ''
  }

  public getIsYieldPriority(text: string): boolean {
    switch (text) {
      case '综合排序':
        return false
      case '收益率优先':
        return true
      default:
        return false
    }
  }

  public getProductSaleType(value: number): string {
    switch (value) {
      case SaleState.PRE_SALE:
        return '预售'
      case SaleState.FOR_SALE:
        return '在售'
      case SaleState.SOLD_OUT:
        return '售罄'
      default:
        return '售罄'
    }
  }
}
