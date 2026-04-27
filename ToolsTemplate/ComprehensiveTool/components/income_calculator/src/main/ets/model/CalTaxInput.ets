export enum IncomeType {
  SALARY = 1,
  LABOUR = 2,
  ROYALTIES = 3,
}

export interface Menu {
  type: IncomeType,
  content: string,
  isChecked: boolean,
  range: number[],
  taxRate: number[],
  quickDeduction: number[],
}

export interface CalTaxInput {
  from?: string
  income?: number
  month?: number
  insurance?: number
  deduction?: number
  threshold?: number
}

export interface TaxParam {
  incomeType: IncomeType
  texInput: CalTaxInput
}