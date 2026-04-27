import { IncomeType, Menu } from '../model/CalTaxInput'

export const optionList: string[][] = [
  [
    '税前工资（月）',
    '专项扣除（社保公积金个人部分）',
    '专项附加扣除（子女教育等）',
  ],
  ['收入金额'],
]


export const menuList: Menu[] = [
  {
    type: IncomeType.SALARY,
    content: '工资、薪金所得（综合所得）',
    isChecked: true,
    range: [0, 36000, 144000, 300000, 420000, 660000, 960000],
    taxRate: [0, 3, 10, 20, 25, 30, 35, 45],
    quickDeduction: [0, 0, 2520, 16920, 31920, 52920, 85920, 181920],
  },
  {
    type: IncomeType.LABOUR,
    content: '劳动报酬所得',
    isChecked: false,
    range: [0, 20000, 50000],
    taxRate: [0, 20, 30, 40],
    quickDeduction: [0, 0, 2000, 7000],
  },
  {
    type: IncomeType.ROYALTIES,
    content: '特许权使用费所得',
    isChecked: false,
    range: [0, 20000, 50000],
    taxRate: [0, 20, 30, 40],
    quickDeduction: [0, 0, 2000, 7000],
  },
]

export class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 10
  color: ResourceColor = '#ffe9f0f0'

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}