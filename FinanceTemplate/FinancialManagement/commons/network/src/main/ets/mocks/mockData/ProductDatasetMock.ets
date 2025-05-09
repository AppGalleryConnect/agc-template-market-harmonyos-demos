import { FormatUtil } from 'commonlib';
import {
  IDatasetRequest,
  IDollarCostAveragingRequest,
  IPrepayRequest,
  IProductRequest,
  IQueryById,
  IQueryData,
  IQueryDataByUser,
  IQueryProduct,
} from '../../types/AxiosRequestParam';
import { IProductItem, SectionLabel } from '../../types/responseTypes/GetProductResp'
import {
  IInvestmentRecordItem,
  IRegularInvestmentInfo,
  IRegularInvestmentItem
} from '../../types/responseTypes/GetRegularInvestmentResp';
import { ITransactionInfo } from '../../types/responseTypes/GetTransactionRecordInfoResp';
import { ITransactionItem } from '../../types/responseTypes/GetTransactionRecordListResp';
import { IPrepayResp } from '../../types/responseTypes/PrepayResp';
import {
  IDollarCostAveragingStorage,
  MockStorageMap,
  product1,
  product10,
  product11,
  product12,
  product2,
  product3,
  product4,
  product5,
  product6,
  product7,
  product8,
  product9,
  buyRule,
  historicalPerformance,
  productInfo,
  profile,
  redemptionRule,
  purchaseProcess,
  redemptionProcess,
  annualizedDataset,
  revenueDataset,
  dollarCostAveraging1,
  dollarCostAveraging2
} from '../Constants';
import { getFormattedResp } from '../Utils';
import { TransactionDatasetMock } from './TransactionDatasetMock';

@ObservedV2
export class ProductDatasetMock {
  static productList: IProductItem[] =
    [product1, product2, product3, product4, product5, product6, product7, product8, product9, product10, product11,
      product12]

  public static getProductList(data: IQueryProduct) {
    if (data.sectionLabel === SectionLabel.FLEXIBLE_ACCESS) {
      const productList: IProductItem[] = [product1, product2];
      return getFormattedResp(productList);
    }
    if (data.sectionLabel === SectionLabel.FINANCIAL_NIGHT_MARKET) {
      const productList: IProductItem[] = [product3, product4, product5, product6, product7, product8];
      return getFormattedResp(productList);
    }
    if (data.searchText) {
      const productList = ProductDatasetMock.productList.filter((item) => {
        return item.name.includes(data.searchText as string)
      })
      return getFormattedResp(productList);
    }
    if (data) {
      const productList = ProductDatasetMock.productList.filter((item) => {
        return item.type === data.productType
      })
        .filter((item) => {
          return item.saleType === data.saleType
        })
        .filter((item) => {
          if (data.eachCost) {
            return item.minimumPurchaseAmount === data.eachCost
          }
          return item.minimumPurchaseAmount >= 1
        })
        .filter((item) => {
          if (data.risk) {
            return item.risk === data.risk
          }
          return item.risk === item.risk
        })
      if (data.arrangement === 2) {
        productList.sort((a, b) => {
          return b.annualizedRate - a.annualizedRate
        })
      }
      return getFormattedResp(productList);
    }
    return getFormattedResp(ProductDatasetMock.productList);
  }

  public static getProductInfo(data: IQueryById) {
    const product = ProductDatasetMock.productList.find((item) => {
      return item.id === data.id
    })
    if (product) {
      const arr = Object.keys(product)
      for (let item of arr) {
        Reflect.set(productInfo, item, Reflect.get(product, item))
      }
    }
    return getFormattedResp(productInfo);
  }

  public static getProductBuyRule(id: number) {
    return getFormattedResp(buyRule);
  }

  public static getProductRedemptionRule(id: number) {
    return getFormattedResp(redemptionRule);
  }

  public static getProductPurchaseProcess(id: number) {
    return getFormattedResp(purchaseProcess);
  }

  public static getProductRedemptionProcess(id: number) {
    return getFormattedResp(redemptionProcess);
  }

  public static getProductHistoricalPerformanceList(id: number) {
    return getFormattedResp(historicalPerformance);
  }

  public static getProductProfile(data: IDatasetRequest) {
    return getFormattedResp(profile);
  }

  public static getAnnualizedDataset(data: IDatasetRequest) {
    return getFormattedResp(annualizedDataset);
  }

  public static getRevenueDataset(id: number) {
    return getFormattedResp(revenueDataset);
  }


  public static addProductToCart(data: IProductRequest) {
    let storageList = AppStorage.get<IProductRequest[]>(MockStorageMap.PRODUCT_LIST);
    if (!storageList) {
      storageList = []
      AppStorage.setOrCreate(MockStorageMap.PRODUCT_LIST, [])
    }
    storageList.push(data);
    AppStorage.set(MockStorageMap.PRODUCT_LIST, storageList);
    return getFormattedResp(undefined);
  }

  public static deleteProductFromCart(data: IProductRequest) {
    let storageList = AppStorage.get<IProductRequest[]>(MockStorageMap.PRODUCT_LIST);
    if (storageList) {
      const index = storageList.findIndex((item) => {
        return item.productId === data.productId
      })
      if (index !== -1) {
        storageList.splice(index, 1)
        AppStorage.set(MockStorageMap.PRODUCT_LIST, storageList);
      }
    }
    return getFormattedResp(undefined);
  }

  public static getProductFromCart(data: IProductRequest) {
    let storageList = AppStorage.get<IProductRequest[]>(MockStorageMap.PRODUCT_LIST);
    if (storageList) {
      const index = storageList.findIndex((item) => {
        return item.productId === data.productId
      })
      if (index !== -1) {
        return getFormattedResp(data.productId);
      }
    }
    return getFormattedResp(0);
  }

  public static getMyRegularChoiceList(data: IQueryDataByUser) {
    let storageList = AppStorage.get<IProductRequest[]>(MockStorageMap.PRODUCT_LIST)
    const arr: IProductItem[] = []
    if (storageList) {
      storageList.forEach((item) => {
        const product = ProductDatasetMock.productList.find((product) => {
          return product.id === item.productId
        })
        if (product) {
          arr.push(product)
        }
      })
    } else {
      storageList = []
      AppStorage.setOrCreate(MockStorageMap.PRODUCT_LIST, [])
      storageList.push({ userId: 1, productId: 1 })
      storageList.push({ userId: 1, productId: 2 })
      AppStorage.set(MockStorageMap.PRODUCT_LIST, storageList);
      storageList.forEach((item) => {
        const product = ProductDatasetMock.productList.find((product) => {
          return product.id === item.productId
        })
        if (product) {
          arr.push(product)
        }
      })
    }
    return getFormattedResp(arr);
  }

  public static prepay(data: IPrepayRequest) {
    const transactionItem: ITransactionItem = {
      id: TransactionDatasetMock.transactionList.length + 1,
      type: 2,
      amount: data.amount,
      share: 23,
      date: FormatUtil.formatDate(new Date()),
      productName: '',
      bankCardNo: '6548541256987451145',
    }
    const transactionInfo: ITransactionInfo = {
      id: 1,
      type: 2,
      state: 3,
      date: '',
      productName: '',
      productNumber: 'WE12312',
      bankCardNumber: '6548541256987451145',
      amount: data.amount,
      status: []
    }
    const product = ProductDatasetMock.productList.find((item) => {
      return item.id === data.productId
    })
    if (product) {
      transactionItem.productName = product.name
      TransactionDatasetMock.transactionList.push(transactionItem)
      transactionInfo.id = transactionItem.id
      transactionInfo.date = transactionItem.date
      transactionInfo.productName = product.name
      TransactionDatasetMock.transactionInfoList.push(transactionInfo)
    }
    const timestamp = new Date().getTime();
    const orderNo: string = timestamp.toString();
    const resp: IPrepayResp = {
      orderNo: orderNo,
      orderStr: '',
      timestamp: orderNo,
    };
    return getFormattedResp(resp);
  }

  public static submitDollarCostAveraging(data: IDollarCostAveragingRequest) {
    let storageList = AppStorage.get<IDollarCostAveragingStorage[]>(MockStorageMap.DOLLAR_COST_AVERAGING);
    if (!storageList) {
      storageList = []
      AppStorage.setOrCreate(MockStorageMap.DOLLAR_COST_AVERAGING, [])
    }
    const item: IDollarCostAveragingStorage = {
      regularInvestmentItem: {
        id: storageList.length + 1,
        productName: '',
        productNumber: '',
        state: 3,
        money: data.money,
        times: 0,
        date: FormatUtil.formatDate(new Date()),
        amount: 0,
        bankCardNo: ''
      },
      investmentRecordList: []
    }
    item.regularInvestmentItem.amount = item.regularInvestmentItem.money * item.regularInvestmentItem.times
    item.regularInvestmentItem.bankCardNo = data.bankCardNo
    const product = ProductDatasetMock.productList.find((item) => {
      return item.id === data.productId
    })
    if (product) {
      item.regularInvestmentItem.productName = product.name
      item.regularInvestmentItem.productNumber = product.number as string
    }
    storageList.push(item);
    AppStorage.set(MockStorageMap.DOLLAR_COST_AVERAGING, storageList);
    const timestamp = new Date().getTime();
    const orderNo: string = timestamp.toString();
    const resp: IPrepayResp = {
      orderNo: orderNo,
      orderStr: '',
      timestamp: orderNo,
    };
    return getFormattedResp(resp);
  }

  public static getRegularInvestmentList(data: IQueryDataByUser) {
    let storageList = AppStorage.get<IDollarCostAveragingStorage[]>(MockStorageMap.DOLLAR_COST_AVERAGING);
    const arr: IRegularInvestmentItem[] = []
    if (storageList) {
      storageList.forEach((item) => {
        const regularInvestmentItem: IRegularInvestmentItem = item.regularInvestmentItem
        arr.push((regularInvestmentItem))
      })
    } else {
      storageList = []
      AppStorage.setOrCreate(MockStorageMap.DOLLAR_COST_AVERAGING, [])
      storageList.push(dollarCostAveraging1)
      storageList.push(dollarCostAveraging2)
      AppStorage.set(MockStorageMap.DOLLAR_COST_AVERAGING, storageList);
      storageList.forEach((item) => {
        const regularInvestmentItem: IRegularInvestmentItem = item.regularInvestmentItem
        arr.push((regularInvestmentItem))
      })
    }
    return getFormattedResp(arr);
  }

  public static getInvestmentRecordList(data: IQueryData) {
    let storageList = AppStorage.get<IDollarCostAveragingStorage[]>(MockStorageMap.DOLLAR_COST_AVERAGING);
    let arr: IInvestmentRecordItem[] = []
    if (storageList) {
      storageList.forEach((item) => {
        if (item.regularInvestmentItem.id === data.id) {
          const investmentRecordItem: IInvestmentRecordItem[] = item.investmentRecordList
          arr = investmentRecordItem
        }
      })
    }
    return getFormattedResp(arr);
  }

  public static getRegularInvestmentInfo(data: IQueryData) {
    let storageList = AppStorage.get<IDollarCostAveragingStorage[]>(MockStorageMap.DOLLAR_COST_AVERAGING);
    const info: IRegularInvestmentInfo = {
      id: 1,
      productName: '测试1号',
      productNumber: '测试2号',
      state: 1,
      amount: 5000.00,
      times: 10,
      date: '2022/06/02',
      money: 500,
      bankCardNo: '54587852154878564151',
      status: [
        {
          date: '2023/02/27',
          status: 1,
        },
        {
          date: '2023/02/27',
          status: 0,
        },
        {
          date: '2023/03/03',
          status: 0,
        },
      ]
    }
    if (storageList) {
      storageList.forEach((item) => {
        if (item.regularInvestmentItem.id === data.id) {
          info.id = item.regularInvestmentItem.id
          info.state = item.regularInvestmentItem.state
          info.amount = item.regularInvestmentItem.times * item.regularInvestmentItem.money
          info.times = item.regularInvestmentItem.times
          info.date = item.regularInvestmentItem.date
          info.money = item.regularInvestmentItem.money
          info.productName = item.regularInvestmentItem.productName
          info.productNumber = item.regularInvestmentItem.productNumber
          info.bankCardNo = item.regularInvestmentItem.bankCardNo
        }
      })
    }
    return getFormattedResp(info);
  }
}