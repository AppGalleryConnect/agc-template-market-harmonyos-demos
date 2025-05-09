export interface IProductManual {
  description: string,
  label: string[],
  url: string
}

export interface IProductOverview {
  name: string,
}

export interface IRiskWarning {
  url: string
}

export interface IRelevantAgreementItem {
  name: string,
  url: string
}

export interface IProductProfile {
  productManual: IProductManual,
  productOverview: IProductOverview,
  riskWarning: IRiskWarning,
  relevantAgreement: IRelevantAgreementItem[]
}

export type GetProductProfileResp = IProductProfile