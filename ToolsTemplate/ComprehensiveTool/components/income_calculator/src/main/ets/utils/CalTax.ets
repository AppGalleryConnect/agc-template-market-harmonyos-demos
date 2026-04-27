import { TaxRes } from '../model/TaxRes'
import find from './Find'

export function calTax(income: number = 0, month: number = 12, insurance: number = 0, deduction: number = 0,
  threshold: number = 5000) {
  const range = [0, 36000, 144000, 300000, 420000, 660000, 960000]
  const taxRate = [0, 3, 10, 20, 25, 30, 35, 45]
  const quickDeduction = [0, 0, 2520, 16920, 31920, 52920, 85920, 181920]
  let res = new TaxRes();
  res.totalIncome = income * month
  res.totalDeduction = (insurance + deduction + threshold) * month
  res.totalInsurance = insurance * month
  res.taxableIncome = res.totalIncome - res.totalDeduction;
  if (res.taxableIncome < 0) {
    res.taxableIncome = 0
  }
  let index: number = find(range, res.taxableIncome)
  res.quickDeduction = quickDeduction[index]
  res.taxRate = taxRate[index]
  res.tax = (res.taxableIncome * res.taxRate) / 100 - res.quickDeduction
  res.afterTaxIncome = (income - insurance) * month - res.tax
  return res
}

export function labourTax(income: number = 0) {
  const range = [0, 20000, 50000]
  const taxRate = [0, 20, 30, 40]
  const quickDeduction = [0, 0, 2000, 7000]
  let res = new TaxRes();
  res.totalIncome = income
  if (income <= 4000) {
    res.taxableIncome = Math.max(0, income - 800)
  } else {
    res.taxableIncome = income * 0.8
  }
  let index: number = find(range, res.taxableIncome)
  res.quickDeduction = quickDeduction[index]
  res.taxRate = taxRate[index]
  res.tax = (res.taxableIncome * res.taxRate) / 100 - res.quickDeduction
  res.afterTaxIncome = income - res.tax
  return res
}