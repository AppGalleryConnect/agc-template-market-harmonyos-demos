import { IBannerItem, INoticeItem } from '../../types/responseTypes/NoticeResp'
import { getFormattedResp } from '../Utils';
import {
  ISettingData,
  banner1,
  banner2,
  banner3,
  notice1,
  notice2,
  notice3,
  saleType1,
  saleType2,
  minimumPurchaseAmount1,
  minimumPurchaseAmount2,
  minimumPurchaseAmount3,
  minimumPurchaseAmount4,
  minimumPurchaseAmount5,
  riskLevel1,
  riskLevel2,
  riskLevel3,
  cycle1,
  cycle2,
  cycle3,
  cycle4,
  cycle5,
  cycle6,
  arrangement1,
  arrangement2,
  transactionType1,
  transactionType2,
  transactionType3,
  transactionType4,
  transactionDate1,
  transactionDate2,
  transactionDate3,
  transactionDate4
} from '../Constants'


export class StoreConfigDatasetMock {
  public static getBannerList() {
    const bannerList: IBannerItem[] = [banner1, banner2, banner3]
    return getFormattedResp(bannerList);
  }

  public static getNoticeList() {
    const noticeList: INoticeItem[] = [notice1, notice2, notice3]
    return getFormattedResp(noticeList);
  }

  public static getSaleTypeList() {
    const saleTypeList: ISettingData[] = [saleType1, saleType2]
    return getFormattedResp(saleTypeList);
  }

  public static getMinimumPurchaseAmountList() {
    const minimumPurchaseAmountList: ISettingData[] = [
      minimumPurchaseAmount1,
      minimumPurchaseAmount2,
      minimumPurchaseAmount3,
      minimumPurchaseAmount4,
      minimumPurchaseAmount5
    ]
    return getFormattedResp(minimumPurchaseAmountList);
  }

  public static getRiskLevelList() {
    const riskLevelList: ISettingData[] = [riskLevel1, riskLevel2, riskLevel3]
    return getFormattedResp(riskLevelList);
  }

  public static getCycleList() {
    const cycleList: ISettingData[] = [
      cycle1,
      cycle2,
      cycle3,
      cycle4,
      cycle5,
      cycle6,
    ]
    return getFormattedResp(cycleList);
  }

  public static getArrangementList() {
    const arrangementList: ISettingData[] = [
      arrangement1,
      arrangement2
    ]
    return getFormattedResp(arrangementList);
  }

  public static getTransactionTypeList() {
    const transactionTypeList: ISettingData[] = [
      transactionType1,
      transactionType2,
      transactionType3,
      transactionType4,
    ]
    return getFormattedResp(transactionTypeList);
  }

  public static getTransactionDateList() {
    const transactionDateList: ISettingData[] = [
      transactionDate1,
      transactionDate2,
      transactionDate3,
      transactionDate4
    ]
    return getFormattedResp(transactionDateList);
  }
}