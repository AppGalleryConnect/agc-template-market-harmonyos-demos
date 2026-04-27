import {
  CombinationCalculationResult,
  CombinationOptions,
  LoanCalculationResult,
  LoanPayType,
  MonthlyCombinationRepayment,
  MonthlyRepayment
} from '../types/Index';

/**
 * 等额本息
 * @param {number} rate 贷款利率
 * @param {number} year 贷款年限
 * @param {number} cost 贷款金额
 */

export const equalInterestPay = (rate: number, year: number, cost: number): LoanCalculationResult => {
  const realCost = cost * 10000;
  const realYearRate = rate / 100;
  const monthRate = realYearRate / 12;
  const monthPay =
    ((realCost * monthRate * Math.pow(1 + monthRate, year * 12)) / (Math.pow(1 + monthRate, year * 12) - 1));
  const totalPay = (monthPay * year * 12);
  const totalInterest = (totalPay - realCost);

  const monthDetail: Array<MonthlyRepayment> = [];
  const periods = year * 12;
  // 剩余本金
  let remainingPrincipal = realCost;
  let month = 1;
  while (month <= periods) {
    // 月供本金
    const monthPrincipal =
      realCost * monthRate * Math.pow((1 + monthRate), month - 1) / (Math.pow((1 + monthRate), periods) - 1);
    remainingPrincipal = remainingPrincipal - monthPrincipal;
    if (remainingPrincipal < 0) {
      remainingPrincipal = 0
    }
    monthDetail.push({
      periodNum: month,
      monthPay: monthPay,
      monthPrincipal: monthPrincipal,
      monthInterest: monthPay - monthPrincipal,
      remainingPrincipal: remainingPrincipal,
    })
    month++;
  }
  return {
    cost,
    year,
    rate,
    totalPay,
    totalInterest,
    monthDetail
  };
  ;
}

/**
 * 等额本金
 * @param {*} rate 贷款基准利率 默认0.049
 * @param {*} year 贷款年限
 * @param {*} cost 贷款金额
 */
export const equalPrincipalPay = (rate: number, year: number, cost: number): LoanCalculationResult => {
  const realCost = cost * 10000;
  const realYearRate = rate / 100
  const monthRate = realYearRate / 12;
  const monthPrincipal = realCost / year / 12;
  let totalPay = 0;
  let totalPrincipalPay = 0;
  let month = 1;
  const monthDetail: Array<MonthlyRepayment> = [];
  while (month <= (year * 12)) {
    let monthPay = (realCost / (year * 12)) + (realCost - totalPrincipalPay) * monthRate;
    totalPrincipalPay += monthPrincipal;
    totalPay += monthPay;
    monthDetail.push({
      periodNum: month,
      monthPay,
      monthPrincipal,
      monthInterest: monthPay - monthPrincipal,
      remainingPrincipal: realCost - totalPrincipalPay,
    });
    month++;
  }
  let totalInterest = (totalPay - realCost);
  return {
    cost,
    year,
    rate,
    totalPay,
    totalInterest,
    monthDetail
  };
}

/**
 * 组合贷款
 */
export const combinationPay = (options: CombinationOptions): CombinationCalculationResult => {
  const payFun = options.type === LoanPayType.EqualInterestPay ? equalInterestPay : equalPrincipalPay;
  const commercialResult = payFun(options.rate, options.year, options.cost);
  const fundResult = payFun(options.fundRate, options.fundYear, options.fundCost);
  const years = Math.max(options.year, options.fundYear);
  const monthDetail: Array<MonthlyCombinationRepayment> = [];
  for (let i = 0; i < years * 12; i++) {
    const commercialMonthPay = commercialResult.monthDetail[i]?.monthPay || 0;
    const fundMonthPay = fundResult.monthDetail[i]?.monthPay || 0;
    monthDetail.push({
      periodNum: i + 1,
      monthPay: commercialMonthPay + fundMonthPay,
      commercialMonthPay,
      fundMonthPay,
    })
  }
  return {
    cost: Number((options.cost + options.fundCost).toFixed(2)),
    year: years,
    totalPay: commercialResult.totalPay + fundResult.totalPay,
    totalInterest: commercialResult.totalInterest + fundResult.totalInterest,
    monthDetail,
  }
}