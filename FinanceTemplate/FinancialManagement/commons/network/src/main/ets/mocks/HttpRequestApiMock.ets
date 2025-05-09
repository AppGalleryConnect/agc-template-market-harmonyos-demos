import { BaseResponse } from '../types/BaseResponse';
import {
  ICodeRequest,
  IDatasetRequest,
  IDollarCostAveragingRequest,
  IPrepayRequest,
  IProductRequest,
  IQueryById,
  IQueryData,
  IQueryDataByUser,
  IQueryProduct,
  IQueryTransaction,
  SubmitPositionRedemptionRequest,
  UpdateUserInfoRequest,
} from '../types/AxiosRequestParam';
import {
  GetHistoricalPerformanceListResp,
  GetProductListResp,
  GetProductTypeListResp,
  IBuyRule,
  IDataset,
  IProcess,
  IProductInfo,
  IProfile,
  IRedemptionRule,
} from '../types/responseTypes/GetProductResp';
import { getProductTypeList } from './mockData/getProductTypeList';
import { IUserAccount } from '../types/responseTypes/GetUserAccountResp';
import {
  GetMonthTransactionRecordListResp,
  GetTransactionRecordListResp } from '../types/responseTypes/GetTransactionRecordListResp';
import { GetTransactionRecordInfoResp } from '../types/responseTypes/GetTransactionRecordInfoResp';
import { GetPositionInfoResp, IPositionRecord } from '../types/responseTypes/GetPositionInfoResp';
import { GetPositionListResp } from '../types/responseTypes/GetPositionListResp';
import { GetBannerListResp, GetNoticeListResp } from '../types/responseTypes/NoticeResp';
import { GetRevenueInfoResp } from '../types/responseTypes/GetRevenueInfoResp';
import { getRevenueInfo } from './mockData/getRevenueInfo';
import {
  GetInvestmentRecordListResp,
  GetRegularInvestmentInfoResp,
  GetRegularInvestmentListResp
} from '../types/responseTypes/GetRegularInvestmentResp';
import { ProductDatasetMock } from './mockData/ProductDatasetMock';
import { StoreConfigDatasetMock } from './mockData/StoreConfigDatasetMock';
import { UserManagementMock } from './mockData/UserManagementMock';
import { PositionDatasetMock } from './mockData/PositionDatasetMock';
import { GetPositionRedemptionInfoResp } from '../types/responseTypes/GetPositionRedemptionResp';
import { TransactionDatasetMock } from './mockData/TransactionDatasetMock';
import { ISettingData } from './Constants';
import { IPrepayResp } from '../types/responseTypes/PrepayResp';
import { IUserInfo } from '../types/responseTypes';

class HttpsApiMock {
  /**
   * 用户
   */
  // 用户登录
  public userLogin(): Promise<BaseResponse<IUserInfo>> {
    return Promise.resolve(UserManagementMock.login());
  }

  public userLogout(): Promise<BaseResponse<undefined>> {
    return Promise.resolve(UserManagementMock.logout());
  }

  // 用户信息查询
  public getUserInfo(): Promise<BaseResponse<IUserInfo>> {
    return Promise.resolve(UserManagementMock.getUserInfo());
  }

  // 更新用户信息
  public updateUserInfo(data: UpdateUserInfoRequest): Promise<BaseResponse<undefined>> {
    return Promise.resolve(UserManagementMock.updateUserInfo(data));
  }

  /**
   * 配置
   */
  public getSaleTypeList(): Promise<BaseResponse<ISettingData[]>> {
    return Promise.resolve(StoreConfigDatasetMock.getSaleTypeList());
  }

  public getMinimumPurchaseAmountList(): Promise<BaseResponse<ISettingData[]>> {
    return Promise.resolve(StoreConfigDatasetMock.getMinimumPurchaseAmountList());
  }

  public getRiskLevelList(): Promise<BaseResponse<ISettingData[]>> {
    return Promise.resolve(StoreConfigDatasetMock.getRiskLevelList());
  }

  public getCycleList(): Promise<BaseResponse<ISettingData[]>> {
    return Promise.resolve(StoreConfigDatasetMock.getCycleList());
  }

  public getArrangementList(): Promise<BaseResponse<ISettingData[]>> {
    return Promise.resolve(StoreConfigDatasetMock.getArrangementList());
  }

  public getTransactionTypeList(): Promise<BaseResponse<ISettingData[]>> {
    return Promise.resolve(StoreConfigDatasetMock.getTransactionTypeList());
  }

  public getTransactionDateList(): Promise<BaseResponse<ISettingData[]>> {
    return Promise.resolve(StoreConfigDatasetMock.getTransactionDateList());
  }

  // 查询banner列表
  public getBannerList(): Promise<BaseResponse<GetBannerListResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getBannerList());
  }

  // 查询产品类型列表
  public getProductTypeList(): Promise<BaseResponse<GetProductTypeListResp>> {
    return Promise.resolve(getProductTypeList);
  }

  // 查询产品列表
  public getProductList(data: IQueryProduct): Promise<BaseResponse<GetProductListResp>> {
    return Promise.resolve(ProductDatasetMock.getProductList(data));
  }

  // 查询产品详情
  public getProductInfo(data: IQueryById): Promise<BaseResponse<IProductInfo>> {
    return Promise.resolve(ProductDatasetMock.getProductInfo(data));
  }

  // 查询产品购买规则
  public getProductBuyRule(id: number): Promise<BaseResponse<IBuyRule>> {
    return Promise.resolve(ProductDatasetMock.getProductBuyRule(id));
  }

  // 查询产品赎回规则
  public getProductRedemptionRule(id: number): Promise<BaseResponse<IRedemptionRule>> {
    return Promise.resolve(ProductDatasetMock.getProductRedemptionRule(id));
  }

  // 查询产品贸易时间
  public getProductPurchaseProcess(id: number): Promise<BaseResponse<IProcess>> {
    return Promise.resolve(ProductDatasetMock.getProductPurchaseProcess(id));
  }

  // 查询产品赎回时间
  public getProductRedemptionProcess(id: number): Promise<BaseResponse<IProcess>> {
    return Promise.resolve(ProductDatasetMock.getProductRedemptionProcess(id));
  }

  // 查询产品历史业绩列表
  public getProductHistoricalPerformanceList(id: number): Promise<BaseResponse<GetHistoricalPerformanceListResp>> {
    return Promise.resolve(ProductDatasetMock.getProductHistoricalPerformanceList(id));
  }

  // 查询产品档案
  public getProductProfile(data: IDatasetRequest): Promise<BaseResponse<IProfile>> {
    return Promise.resolve(ProductDatasetMock.getProductProfile(data));
  }

  public getAnnualizedDataset(data: IDatasetRequest): Promise<BaseResponse<IDataset>> {
    return Promise.resolve(ProductDatasetMock.getAnnualizedDataset(data));
  }

  public getRevenueDataset(id: number): Promise<BaseResponse<IDataset>> {
    return Promise.resolve(ProductDatasetMock.getRevenueDataset(id));
  }

  // 提交产品到自选
  public addProductToCart(data: IProductRequest): Promise<BaseResponse<undefined>> {
    return Promise.resolve(ProductDatasetMock.addProductToCart(data));
  }

  // 从自选中删除产品
  public deleteProductFromCart(data: IProductRequest): Promise<BaseResponse<undefined>> {
    return Promise.resolve(ProductDatasetMock.deleteProductFromCart(data));
  }

  // 从自选中查询产品
  public getProductFromCart(data: IProductRequest): Promise<BaseResponse<number>> {
    return Promise.resolve(ProductDatasetMock.getProductFromCart(data));
  }

  // 提交自选
  public submitDollarCostAveraging(data: IDollarCostAveragingRequest): Promise<BaseResponse<IPrepayResp>> {
    return Promise.resolve(ProductDatasetMock.submitDollarCostAveraging(data));
  }

  // 查询理财资讯列表
  public getNoticeList(): Promise<BaseResponse<GetNoticeListResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getNoticeList());
  }

  // 查询用户账户的详情
  public getUserAccount(): Promise<BaseResponse<IUserAccount>> {
    return Promise.resolve(UserManagementMock.getUserAccount());
  }

  // 查询自选列表
  public getMyRegularChoiceList(params: ESObject): Promise<BaseResponse<GetProductListResp>> {
    return Promise.resolve(ProductDatasetMock.getMyRegularChoiceList({ userId: params.userId }));
  }

  // 提交购买的产品信息
  public prepay(data: IPrepayRequest): Promise<BaseResponse<IPrepayResp>> {
    return Promise.resolve(ProductDatasetMock.prepay(data));
  }

  // 查询持仓产品
  public getPositionList(): Promise<BaseResponse<GetPositionListResp>> {
    return Promise.resolve(PositionDatasetMock.getPositionList());
  }

  // 查询持仓详情
  public getPositionInfo(data: IQueryData): Promise<BaseResponse<GetPositionInfoResp>> {
    return Promise.resolve(PositionDatasetMock.getPositionInfo(data));
  }

  // 查询交易列表
  public getMonthTransactionList(data: IQueryTransaction): Promise<BaseResponse<GetMonthTransactionRecordListResp>> {
    return Promise.resolve(TransactionDatasetMock.getMonthTransactionList(data));
  }

  public getTransactionList(data: IQueryTransaction): Promise<BaseResponse<GetTransactionRecordListResp>> {
    return Promise.resolve(TransactionDatasetMock.getTransactionList(data));
  }

  // 查询交易详情
  public getTransactionRecordInfo(data: IQueryById): Promise<BaseResponse<GetTransactionRecordInfoResp>> {
    return Promise.resolve(TransactionDatasetMock.getTransactionInfo(data));
  }

  // 查询赎回产品详情
  public getPositionRedemption(data: IQueryData): Promise<BaseResponse<GetPositionRedemptionInfoResp>> {
    return Promise.resolve(PositionDatasetMock.getPositionRedemption(data));
  }

  // 获取验证码
  public sendVerificationCode(userId: number): Promise<BaseResponse<undefined>> {
    return Promise.resolve(PositionDatasetMock.sendVerificationCode(userId));
  }

  // 提交验证码
  public submitVerificationCode(data: ICodeRequest): Promise<BaseResponse<number>> {
    return Promise.resolve(PositionDatasetMock.submitVerificationCode(data));
  }

  public submitPositionRedemption(data: SubmitPositionRedemptionRequest): Promise<BaseResponse<number>> {
    return Promise.resolve(PositionDatasetMock.submitPositionRedemption(data));
  }

  // 查询收益明细
  public getRevenueInfo(): Promise<BaseResponse<GetRevenueInfoResp>> {
    return Promise.resolve(getRevenueInfo);
  }

  public getPositionRecord(data: IQueryData): Promise<BaseResponse<IPositionRecord[]>> {
    return Promise.resolve(PositionDatasetMock.getPositionRecord(data));
  }

  // 定投

  public getRegularInvestmentList(userId: number): Promise<BaseResponse<GetRegularInvestmentListResp>> {
    return Promise.resolve(ProductDatasetMock.getRegularInvestmentList({ userId }));
  }

  public getInvestmentRecordList(data: IQueryData): Promise<BaseResponse<GetInvestmentRecordListResp>> {
    return Promise.resolve(ProductDatasetMock.getInvestmentRecordList(data));
  }

  public getRegularInvestmentInfo(data: IQueryData): Promise<BaseResponse<GetRegularInvestmentInfoResp>> {
    return Promise.resolve(ProductDatasetMock.getRegularInvestmentInfo(data));
  }
}

const httpsMock = new HttpsApiMock();

export { httpsMock };