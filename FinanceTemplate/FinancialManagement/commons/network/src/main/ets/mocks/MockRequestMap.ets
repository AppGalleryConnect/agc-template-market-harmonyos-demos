import { httpsMock } from './HttpRequestApiMock';
import { promptAction } from '@kit.ArkUI';
import { Logger } from 'commonlib';
import { BaseResponse } from '../types/BaseResponse';
import { RequestUrlMap } from '../apis/RequestUrlMap';

type MockMap = Record<string, (...args: ESObject[]) => Promise<BaseResponse>>;

// 创建 URL 到 Mock 方法的映射对象
const mockMap: MockMap = {
  /**
   * 用户信息
   */
  [RequestUrlMap.USER_LOGIN]: httpsMock.userLogin,
  [RequestUrlMap.USER_LOGOUT]: httpsMock.userLogout,
  [RequestUrlMap.USER_SEARCH]: httpsMock.getUserInfo,
  [RequestUrlMap.USER_UPDATE]: httpsMock.updateUserInfo,
  [RequestUrlMap.USER_ACCOUNT]: httpsMock.getUserAccount,
  /**
   * 配置信息
   */
  [RequestUrlMap.BANNER_LIST]: httpsMock.getBannerList,
  [RequestUrlMap.Sale_Type_List]: httpsMock.getSaleTypeList,
  [RequestUrlMap.MINIMUM_PURCHASE_AMOUNT_LIST]: httpsMock.getMinimumPurchaseAmountList,
  [RequestUrlMap.RISK_LEVEL_LIST]: httpsMock.getRiskLevelList,
  [RequestUrlMap.CYCLE_LIST]: httpsMock.getCycleList,
  [RequestUrlMap.ARRANGEMENT_LIST]: httpsMock.getArrangementList,
  [RequestUrlMap.TRANSACTION_TYPE_LIST]: httpsMock.getTransactionTypeList,
  [RequestUrlMap.TRANSACTION_DATE_LIST]: httpsMock.getTransactionDateList,
  /**
   * 产品信息
   */
  [RequestUrlMap.PRODUCT_TYPE_LIST]: httpsMock.getProductTypeList,
  [RequestUrlMap.PRODUCT_LIST]: httpsMock.getProductList,
  [RequestUrlMap.PRODUCT_INFO]: httpsMock.getProductInfo,
  [RequestUrlMap.PRODUCT_BUY_RULE]: httpsMock.getProductBuyRule,
  [RequestUrlMap.PRODUCT_REDEMPTION_RULE]: httpsMock.getProductRedemptionRule,
  [RequestUrlMap.PRODUCT_PURCHASE_PROCESS]: httpsMock.getProductPurchaseProcess,
  [RequestUrlMap.PRODUCT_REDEMPTION_PROCESS]: httpsMock.getProductRedemptionProcess,
  [RequestUrlMap.PRODUCT_HISTORICAL_PERFORMANCE_LIST]: httpsMock.getProductHistoricalPerformanceList,
  [RequestUrlMap.PRODUCT_PROFILE]: httpsMock.getProductProfile,
  [RequestUrlMap.ADD_PRODUCT_TO_CART]: httpsMock.addProductToCart,
  [RequestUrlMap.DELETE_PRODUCT_FROM_CART]: httpsMock.deleteProductFromCart,
  [RequestUrlMap.GET_PRODUCT_FROM_CART]: httpsMock.getProductFromCart,
  [RequestUrlMap.NOTICE_LIST]: httpsMock.getNoticeList,
  [RequestUrlMap.PREPAY]: httpsMock.prepay,
  [RequestUrlMap.ANNUALIZED_DATASET]: httpsMock.getAnnualizedDataset,
  [RequestUrlMap.REVENUE_DATASET]: httpsMock.getRevenueDataset,
  /**
   * 持仓信息
   */
  [RequestUrlMap.POSITION_LIST]: httpsMock.getPositionList,
  [RequestUrlMap.POSITION_INFO]: httpsMock.getPositionInfo,
  [RequestUrlMap.POSITION_REDEMPTION]: httpsMock.getPositionRedemption,
  [RequestUrlMap.SUBMIT_POSITION_REDEMPTION]: httpsMock.submitPositionRedemption,
  [RequestUrlMap.TRANSACTION_RECORD_LIST]: httpsMock.getTransactionList,
  [RequestUrlMap.MONTH_TRANSACTION_RECORD_LIST]: httpsMock.getMonthTransactionList,
  [RequestUrlMap.TRANSACTION_RECORD_INFO]: httpsMock.getTransactionRecordInfo,
  [RequestUrlMap.MY_REGULAR_CHOICE_LIST]: httpsMock.getMyRegularChoiceList,
  [RequestUrlMap.REVENUE_INFO]: httpsMock.getRevenueInfo,
  [RequestUrlMap.REGULAR_INVESTMENT_LIST]: httpsMock.getRegularInvestmentList,
  [RequestUrlMap.INVESTMENT_RECORD_LIST]: httpsMock.getInvestmentRecordList,
  [RequestUrlMap.REGULAR_INVESTMENT_INFO]: httpsMock.getRegularInvestmentInfo,
  [RequestUrlMap.SEND_VERIFICATION_CODE]: httpsMock.sendVerificationCode,
  [RequestUrlMap.SUBMIT_VERIFICATION_CODE]: httpsMock.submitVerificationCode,
  [RequestUrlMap.SUBMIT_DOLLAR_COST_AVERAGING]: httpsMock.submitDollarCostAveraging,
  [RequestUrlMap.POSITION_RECORD]: httpsMock.getPositionRecord,
};

// 模拟一个延时的 mock 方法，延迟时间为 `delay` 毫秒
function simulateDelay<T>(data: T, delay: number): Promise<T> {
  return new Promise<T>((resolve) => {
    setTimeout(() => {
      resolve(data);
    }, delay);
  });
}

function mockErrorHandler(msg?: string): Promise<BaseResponse> {
  const errMsg: string = 'replace mock data failed!';

  promptAction.showToast({ message: errMsg });
  Logger.error('[MockRequest]', msg ?? '', errMsg);
  const res: BaseResponse = {
    code: -1,
    msg: errMsg,
    data: undefined,
  };
  return Promise.reject(errMsg);
}

export async function replaceMockData(url: string | undefined, ...args: ESObject[]): Promise<BaseResponse> {
  const arr = Object.entries(mockMap);
  if (url) {
    const func = arr.find((item) => url.startsWith(item[0]));
    if (func) {
      const response: BaseResponse = await func[1](...args);
      const delayResponse: BaseResponse = await simulateDelay(response, 200);
      return Promise.resolve(delayResponse);
    }
    return mockErrorHandler('cannot find mock function.');
  }
  return mockErrorHandler('cannot find url.');
}
