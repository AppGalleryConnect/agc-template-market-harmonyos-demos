import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import {
  IBuyRule,
  IDataset,
  IHistoricalPerformance,
  IProcess,
  IProductInfo,
  IRedemptionRule,
} from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { IUserAccount } from 'network/src/main/ets/types/responseTypes/GetUserAccountResp';
import { IProfile } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { dateButton, initProductInfoData } from '../constants';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';

const TAG = '[ProductInfoVM]';

@ObservedV2
export class ProductInfoVM {
  private static _instance: ProductInfoVM;
  // 接口数据
  @Trace public isAccountInformationEmpty: boolean = false
  @Trace public userAccount: IUserAccount = {
    id: 0,
    userId: 0,
    bankName: '--',
    bankCardNo: '--',
    bankAmount: 0,
    positionAmount: 0,
    accumulatedEarnings: 0,
  }
  @Trace public productInfo: IProductInfo = initProductInfoData
  @Trace public productBuyRule: IBuyRule | undefined
  @Trace public productRedemptionRule: IRedemptionRule | undefined
  @Trace public purchaseProcess: IProcess | undefined
  @Trace public productHistoricalPerformance: IHistoricalPerformance[] = []
  @Trace public productProfile: IProfile | undefined
  @Trace public annualizedDataset: IDataset | undefined
  @Trace public revenueDataset: IDataset | undefined
  // 页面数据
  @Trace public isSelected: boolean = false
  @Trace public currentIndex: number = 0
  @Trace public selectedIndex: number = 0
  @Trace public xData: string[] = []
  @Trace public seriesData: number[] = []
  @Trace public annualizedSelectedIndex: number = 0
  @Trace public revenueSelectedIndex: number = 0
  @Trace public isLogin: boolean = false

  public static get instance() {
    if (!ProductInfoVM._instance) {
      ProductInfoVM._instance = new ProductInfoVM();
    }
    return ProductInfoVM._instance;
  }

  init() {
    const isLogin = AppStorage.get<boolean>('isLogin');
    if (isLogin) {
      this.isLogin = isLogin
    }
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.PRODUCT_INFO,
    });
    const userAccountMockData = AppStorage.get<IUserAccount>(MockStorageMap.USER_ACCOUNT);
    if (userAccountMockData) {
      this.userAccount = userAccountMockData
    }
    if (param) {
      this.getProductInfo(param)
      this.getProductBuyRule(param)
      this.getProductRedemptionRule(param)
      this.getProductPurchaseProcess(param)
      this.getProductHistoricalPerformanceList(param)
      this.getProductFromCart(param)
      this.getAnnualizedDataset(param, dateButton[this.annualizedSelectedIndex].value)
      this.getProductProfile(param)
    }
  }

  clear() {
    this.isAccountInformationEmpty = false
    this.productInfo = initProductInfoData
    this.productBuyRule = undefined
    this.productRedemptionRule = undefined
    this.purchaseProcess = undefined
    this.productHistoricalPerformance = []
    this.productBuyRule = undefined
    this.isSelected = false
    this.isLogin = false
  }

  tabChange(index: number) {
    this.currentIndex = index
    this.selectedIndex = index
    if (this.productInfo) {
      if (index === 0) {
        this.getAnnualizedDataset(this.productInfo.id, dateButton[this.annualizedSelectedIndex].value)
      } else {
        this.getRevenueDataset(this.productInfo.id, dateButton[this.revenueSelectedIndex].value)
      }
    }
  }

  public async getProductInfo(id: number) {
    const res = await https.getProductInfo(id);
    if (res.code === 0) {
      this.productInfo = res.data;
    }
  }

  public async getProductBuyRule(id: number) {
    const res = await https.getProductBuyRule(id);
    if (res.code === 0) {
      this.productBuyRule = res.data;
    }
  }

  public async getProductRedemptionRule(id: number) {
    const res = await https.getProductRedemptionRule(id);
    if (res.code === 0) {
      this.productRedemptionRule = res.data;
    }
  }

  public async getProductPurchaseProcess(id: number) {
    const res = await https.getProductPurchaseProcess(id);
    if (res.code === 0) {
      this.purchaseProcess = res.data;
    }
  }

  public async getProductHistoricalPerformanceList(id: number) {
    const res = await https.getProductHistoricalPerformanceList(id);
    if (res.code === 0) {
      this.productHistoricalPerformance = res.data;
    }
  }


  public async getProductProfile(id: number) {
    const res = await https.getProductProfile(id);
    if (res.code === 0) {
      this.productProfile = res.data;
    }
  }

  public async getAnnualizedDataset(id: number, time: number) {
    const res = await https.getAnnualizedDataset({ id, time });
    if (res.code === 0) {
      this.annualizedDataset = res.data;
      const xDataArr: string[] = []
      const seriesDataArr: number[] = []
      this.annualizedDataset.data.forEach((item) => {
        xDataArr.push(item.date)
        seriesDataArr.push(item.rate)
      })
      this.xData = xDataArr
      this.seriesData = seriesDataArr
    }
  }

  public async getRevenueDataset(id: number, time: number) {
    const res = await https.getRevenueDataset({ id, time });
    if (res.code === 0) {
      this.revenueDataset = res.data;
      const xDataArr: string[] = []
      const seriesDataArr: number[] = []
      this.revenueDataset.data.forEach((item) => {
        xDataArr.push(item.date)
        seriesDataArr.push(item.rate)
      })
      this.xData = xDataArr
      this.seriesData = seriesDataArr
    }
  }

  public async getUserAccount(userId: number) {
    const res = await https.getUserAccount(userId);
    if (res.code === 0) {
      this.userAccount = res.data;
    }
  }

  public async addProductToCart(id: number) {
    await https.addProductToCart({ userId: 1, productId: id });
  }

  public async deleteProductFromCart(id: number) {
    await https.deleteProductFromCart({ userId: 1, productId: id });
  }

  public async getProductFromCart(id: number) {
    const res = await https.getProductFromCart({ userId: 1, productId: id });
    if (res.code === 0 && res.data) {
      this.isSelected = true
    }
  }

  public getProductReturnsFontColor(index: number): ResourceStr {
    if (this.currentIndex === 0) {
      if (this.annualizedSelectedIndex === index) {
        return '#E4480C'
      } else {
        return $r('sys.color.font_secondary')
      }
    } else {
      if (this.revenueSelectedIndex === index) {
        return '#E4480C'
      } else {
        return $r('sys.color.font_secondary')
      }
    }
  }

  public getProductReturnsBgColor(index: number): ResourceStr {
    if (this.currentIndex === 0) {
      if (this.annualizedSelectedIndex === index) {
        return '#FDF0E8'
      } else {
        return ''
      }
    } else {
      if (this.revenueSelectedIndex === index) {
        return '#FDF0E8'
      } else {
        return ''
      }
    }
  }
}
