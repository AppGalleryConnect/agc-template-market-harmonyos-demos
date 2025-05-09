import { ProductType, SectionLabel } from './responseTypes/GetProductResp';

export interface IQueryDataByUser {
  userId: number,
}

export interface IQueryById {
  id: number
}

export interface IQueryData {
  userId: number,
  id: number
}

export interface ICodeRequest {
  code: string
}

// 更新用户信息
export interface UpdateUserInfoRequest {
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
}

export interface SubmitPositionRedemptionRequest {
  id: number
  userId: number
  share: number
  bankCardNo: string,
}

export interface IQueryProduct {
  productType?: ProductType,
  sectionLabel?: SectionLabel,
  searchText?: string,
  saleType?: number,
  arrangement?: number,
  risk?: string,
  eachCost?: number,
}

export interface IProductRequest {
  userId: number;
  productId: number;
}

export interface IDollarCostAveragingRequest {
  userId: number;
  productId: number;
  money: number,
  bankCardNo: string,
}

export interface IDatasetRequest {
  id: number,
  time: number
}

// 理财产品预下单
export interface IPrepayRequest {
  productId: number,
  amount: number,
  userId: number;
  cardNo: string;
  recommendationCode?: string,
  date?: string,
}


export interface IQueryTransaction {
  userId: number;
  searchText?: string,
  transactionType?: number,
  transactionDate?: number
}
