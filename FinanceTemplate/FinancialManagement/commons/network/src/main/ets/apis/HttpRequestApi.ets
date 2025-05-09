import { BaseResponse } from '../types/BaseResponse';
import axiosClient from '../models/AxiosRequest';
import {
  IDatasetRequest,
  IDollarCostAveragingRequest,
  IPrepayRequest,
  IProductRequest,
  IQueryData,
  IQueryProduct,
  IQueryTransaction,
  SubmitPositionRedemptionRequest,
  UpdateUserInfoRequest,
} from '../types/AxiosRequestParam';
import { RequestUrlMap } from './RequestUrlMap';
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
import { IUserAccount } from '../types/responseTypes/GetUserAccountResp';
import {
  GetMonthTransactionRecordListResp,
  GetTransactionRecordListResp
} from '../types/responseTypes/GetTransactionRecordListResp';
import { GetTransactionRecordInfoResp } from '../types/responseTypes/GetTransactionRecordInfoResp';
import { GetPositionInfoResp, IPositionRecord } from '../types/responseTypes/GetPositionInfoResp';
import { GetPositionListResp } from '../types/responseTypes/GetPositionListResp';
import { GetBannerListResp, GetNoticeListResp } from '../types/responseTypes/NoticeResp';
import { GetRevenueInfoResp } from '../types/responseTypes/GetRevenueInfoResp';
import {
  GetInvestmentRecordListResp,
  GetRegularInvestmentInfoResp,
  GetRegularInvestmentListResp
} from '../types/responseTypes/GetRegularInvestmentResp';
import { GetPositionRedemptionInfoResp } from '../types/responseTypes/GetPositionRedemptionResp';
import { ISettingData } from '../mocks/Constants';
import { IPrepayResp } from '../types/responseTypes/PrepayResp';
import { AccountUtil, AppStorageMap, HUAWEIAccountModel, Logger } from 'commonlib';
import { IUserInfo } from '../types/responseTypes';

export function getTenantId() {
  const tenantId: number | undefined = AppStorage.get(AppStorageMap.TENANT_ID);
  if (!tenantId) {
    Logger.error('tenant id is not existed');
    return undefined;
  }
  return tenantId;
}

export function resetLoginToken() {
  const accountInfo: HUAWEIAccountModel = AccountUtil.getAccountInfo();
  accountInfo.loginToken = undefined;
  https.userLogin().then((res) => {
    if (res.code === 0) {
      accountInfo.loginToken = res.data.loginToken;
    }
  });
}

class HttpsApi {
  // 用户登录
  public userLogin(): Promise<BaseResponse<IUserInfo>> {
    return axiosClient.get({
      url: RequestUrlMap.USER_LOGIN,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 用户登出
  public userLogout(): Promise<BaseResponse<undefined>> {
    return axiosClient.get({
      url: RequestUrlMap.USER_LOGOUT,
    });
  }

  // 用户信息查询
  public getUserInfo(): Promise<BaseResponse<IUserInfo>> {
    return axiosClient.get({
      url: RequestUrlMap.USER_SEARCH,
    });
  }

  // 用户信息更新
  public updateUserInfo(data: UpdateUserInfoRequest): Promise<BaseResponse> {
    return axiosClient.put({
      showLoading: true,
      url: RequestUrlMap.USER_UPDATE,
      data,
    });
  }

  /**
   * 配置
   */
  public getSaleTypeList(): Promise<BaseResponse<ISettingData[]>> {
    return axiosClient.get({
      url: RequestUrlMap.Sale_Type_List,
    });
  }

  public getMinimumPurchaseAmountList(): Promise<BaseResponse<ISettingData[]>> {
    return axiosClient.get({
      url: RequestUrlMap.MINIMUM_PURCHASE_AMOUNT_LIST,
    });
  }

  public getRiskLevelList(): Promise<BaseResponse<ISettingData[]>> {
    return axiosClient.get({
      url: RequestUrlMap.RISK_LEVEL_LIST,
    });
  }

  public getCycleList(): Promise<BaseResponse<ISettingData[]>> {
    return axiosClient.get({
      url: RequestUrlMap.CYCLE_LIST,
    });
  }

  public getArrangementList(): Promise<BaseResponse<ISettingData[]>> {
    return axiosClient.get({
      url: RequestUrlMap.ARRANGEMENT_LIST,
    });
  }

  public getTransactionTypeList(): Promise<BaseResponse<ISettingData[]>> {
    return axiosClient.get({
      url: RequestUrlMap.TRANSACTION_TYPE_LIST,
    });
  }

  public getTransactionDateList(): Promise<BaseResponse<ISettingData[]>> {
    return axiosClient.get({
      url: RequestUrlMap.TRANSACTION_DATE_LIST,
    });
  }

  // 查询banner列表
  public getBannerList(): Promise<BaseResponse<GetBannerListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.BANNER_LIST,
    });
  }

  // 查询理财资讯列表
  public getNoticeList(): Promise<BaseResponse<GetNoticeListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.NOTICE_LIST,
    });
  }

  // 查询产品类型列表
  public getProductTypeList(): Promise<BaseResponse<GetProductTypeListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_TYPE_LIST,
    });
  }

  // 查询产品列表
  public getProductList(data: IQueryProduct): Promise<BaseResponse<GetProductListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_LIST,
      params: data,
    });
  }

  // 查询产品详情
  public getProductInfo(id: number): Promise<BaseResponse<IProductInfo>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_INFO,
      params: {
        id,
      },
    });
  }

  // 查询产品购买规则
  public getProductBuyRule(id: number): Promise<BaseResponse<IBuyRule>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_BUY_RULE,
      params: {
        id,
      },
    });
  }

  // 查询产品赎回规则
  public getProductRedemptionRule(id: number): Promise<BaseResponse<IRedemptionRule>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_REDEMPTION_RULE,
      params: {
        id,
      },
    });
  }

  // 查询产品贸易时间
  public getProductPurchaseProcess(id: number): Promise<BaseResponse<IProcess>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_PURCHASE_PROCESS,
      params: {
        id,
      },
    });
  }

  public getAnnualizedDataset(data: IDatasetRequest): Promise<BaseResponse<IDataset>> {
    return axiosClient.get({
      url: RequestUrlMap.ANNUALIZED_DATASET,
      params: data
    });
  }

  public getRevenueDataset(data: IDatasetRequest): Promise<BaseResponse<IDataset>> {
    return axiosClient.get({
      url: RequestUrlMap.REVENUE_DATASET,
      params: data
    });
  }

  // 查询产品赎回时间
  public getProductRedemptionProcess(id: number): Promise<BaseResponse<IProcess>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_REDEMPTION_PROCESS,
      params: {
        id,
      },
    });
  }

  // 查询历史业绩列表
  public getProductHistoricalPerformanceList(id: number): Promise<BaseResponse<GetHistoricalPerformanceListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_HISTORICAL_PERFORMANCE_LIST,
      params: {
        id
      }
    });
  }

  // 查询产品档案
  public getProductProfile(id: number): Promise<BaseResponse<IProfile>> {
    return axiosClient.get({
      url: RequestUrlMap.PRODUCT_PROFILE,
      params: {
        id
      }
    });
  }

  // 提交产品到自选
  public addProductToCart(data: IProductRequest): Promise<BaseResponse<undefined>> {
    return axiosClient.post({
      url: RequestUrlMap.ADD_PRODUCT_TO_CART,
      data
    });
  }

  // 从自选中删除产品
  public deleteProductFromCart(data: IProductRequest): Promise<BaseResponse<undefined>> {
    return axiosClient.delete({
      url: RequestUrlMap.DELETE_PRODUCT_FROM_CART,
      data
    });
  }

  // 查询产品到自选
  public getProductFromCart(data: IProductRequest): Promise<BaseResponse<number>> {
    return axiosClient.get({
      url: RequestUrlMap.GET_PRODUCT_FROM_CART,
      params: data
    });
  }

  // 查询产品详情
  public getUserAccount(userId: number): Promise<BaseResponse<IUserAccount>> {
    return axiosClient.get({
      url: RequestUrlMap.USER_ACCOUNT,
      params: {
        userId,
      },
    });
  }

  // 提交自选
  public submitDollarCostAveraging(data: IDollarCostAveragingRequest): Promise<BaseResponse<IPrepayResp>> {
    return axiosClient.post({
      url: RequestUrlMap.SUBMIT_DOLLAR_COST_AVERAGING,
      data
    });
  }

  // 查询自选列表
  public getMyRegularChoiceList(userId: number): Promise<BaseResponse<GetProductListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.MY_REGULAR_CHOICE_LIST,
      params: {
        userId,
      }
    });
  }

  // 提交购买
  public prepay(data: IPrepayRequest): Promise<BaseResponse<IPrepayResp>> {
    return axiosClient.post({
      url: RequestUrlMap.PREPAY,
      data
    });
  }

  // 查询持仓列表
  public getPositionList(userId: number, page: number,
    pageSize: number): Promise<BaseResponse<GetPositionListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.POSITION_LIST,
      params: {
        userId,
        page,
        pageSize
      }
    });
  }

  // 查询持仓详情
  public getPositionInfo(userId: number, id: number): Promise<BaseResponse<GetPositionInfoResp>> {
    return axiosClient.get({
      url: RequestUrlMap.POSITION_INFO,
      params: {
        userId,
        id
      }
    });
  }

  // 查询交易列表
  public getMonthTransactionList(data: IQueryTransaction): Promise<BaseResponse<GetMonthTransactionRecordListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.MONTH_TRANSACTION_RECORD_LIST,
      params: data
    });
  }

  public getTransactionList(data: IQueryTransaction): Promise<BaseResponse<GetTransactionRecordListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.TRANSACTION_RECORD_LIST,
      params: data
    });
  }

  // 查询交易详情
  public getTransactionRecordInfo(id: number): Promise<BaseResponse<GetTransactionRecordInfoResp>> {
    return axiosClient.get({
      url: RequestUrlMap.TRANSACTION_RECORD_INFO,
      params: {
        id
      }
    });
  }

  // 查询持仓赎回
  public getPositionRedemption(userId: number,
    positionId: number): Promise<BaseResponse<GetPositionRedemptionInfoResp>> {
    return axiosClient.get({
      url: RequestUrlMap.POSITION_REDEMPTION,
      params: {
        userId,
        id: positionId
      }
    });
  }

  // 获取验证码
  public sendVerificationCode(userId: number): Promise<BaseResponse<undefined>> {
    return axiosClient.get({
      url: RequestUrlMap.SEND_VERIFICATION_CODE,
      params: {
        userId
      }
    });
  }

  // 提交验证码
  public submitVerificationCode(code: string): Promise<BaseResponse<number>> {
    return axiosClient.post({
      url: RequestUrlMap.SUBMIT_VERIFICATION_CODE,
      data: {
        code
      }
    });
  }

  // 提交赎回
  public submitPositionRedemption(data: SubmitPositionRedemptionRequest): Promise<BaseResponse<undefined>> {
    return axiosClient.post({
      showLoading: true,
      url: RequestUrlMap.SUBMIT_POSITION_REDEMPTION,
      data,
    });
  }

  // 收益明细
  public getRevenueInfo(userId: number, id: number): Promise<BaseResponse<GetRevenueInfoResp>> {
    return axiosClient.get({
      url: RequestUrlMap.REVENUE_INFO,
      params: {
        userId,
        id
      }
    });
  }

  public getPositionRecord(data: IQueryData): Promise<BaseResponse<IPositionRecord[]>> {
    return axiosClient.get({
      url: RequestUrlMap.POSITION_RECORD,
      params: data
    });
  }

  /*
   * 定投
   * */

  public getRegularInvestmentList(userId: number): Promise<BaseResponse<GetRegularInvestmentListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.REGULAR_INVESTMENT_LIST,
      params: { userId }
    });
  }

  public getInvestmentRecordList(userId: number,
    id: number): Promise<BaseResponse<GetInvestmentRecordListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.INVESTMENT_RECORD_LIST,
      params: {
        userId,
        id
      }
    });
  }

  public getRegularInvestmentInfo(userId: number,
    id: number): Promise<BaseResponse<GetRegularInvestmentInfoResp>> {
    return axiosClient.get({
      url: RequestUrlMap.REGULAR_INVESTMENT_INFO,
      params: {
        userId,
        id
      }
    });
  }
}

const https = new HttpsApi();

export { https };
