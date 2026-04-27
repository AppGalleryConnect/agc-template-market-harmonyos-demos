import { InvestmentDetail, ProfitDetail } from '../model/Index';
import { pasteboard } from '@kit.BasicServicesKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { DepositType, FinancialType } from '../common/Constant';
import { UtilLog } from '@hw-agconnect/util-log';

// 计算银行理财
export function calculateCurrentDepositInterest(
  money: number,
  year: number,
  rate: number,
): ProfitDetail {
  // 参数合法性校验
  if (money <= 0 || year <= 0 || rate < 0) {
    console.error('参数错误：本金、年限需>0，年利率不能为负');
    return { totalRevenue: 0, rateRevenue: money, monthlyRevenue: 0 };
  }

  // 基础计算参数
  const totalDays = Math.floor(year * 365); // 总存款天数（简化按365天/年）
  const rateRevenue = money * rate / 365 * totalDays

  // 保留两位小数（四舍五入）
  return {
    rateRevenue: Math.round(rateRevenue * 100) / 100,
    totalRevenue: Math.round(rateRevenue * 100) / 100 + money,
    monthlyRevenue: Math.round((rateRevenue / (year * 12)) * 100) / 100,
  };
}

// 计算复利理财
export function calculateCompoundInterest(
  money: number,
  year: number,
  rate: number,
  compoundRateCount: number,
): ProfitDetail {
  // 参数合法性校验
  if (money <= 0 || year < 0 || rate <= 0 || compoundRateCount <= 0) {
    console.error('参数错误：本金、年限、每年复利次数需>0，年利率不能为负');
    return { totalRevenue: 0, rateRevenue: money, monthlyRevenue: 0 };
  }

  // 计算每期利率（年利率 ÷ 每年复利次数）
  const periodRate = rate / compoundRateCount;
  // 计算总期数（年限 × 每年复利次数）
  const totalPeriods = year * compoundRateCount;

  // 计算最终本息总额：本金 × (1 + 每期利率)^总期数
  const totalAmount = money * Math.pow(1 + periodRate, totalPeriods);
  // 总收益 = 本息总额 - 本金
  const totalProfit = totalAmount - money;
  // 月均收益 = 总收益 ÷ 存款年限
  const annualizedProfit = totalProfit / (year * 12);

  // 保留两位小数（四舍五入，符合金额规范）
  return {
    rateRevenue: Math.round(totalProfit * 100) / 100,
    totalRevenue: Math.round(totalAmount * 100) / 100,
    monthlyRevenue: Math.round(annualizedProfit * 100) / 100,
  };
}

// 计算定投理财
export function calculateFixedInvestmentProfit(
  money: number,
  time: number,
  rate: number,
): ProfitDetail {
  // 参数合法性校验
  if (money <= 0 || rate < 0 || time <= 0) {
    console.error('参数错误：每期投入、年数、每年定投次数需>0，年利率不能为负');
    return {
      totalRevenue: 0,
      rateRevenue: 0,
      monthlyRevenue: 0,
    }
  }

  const r = Number((rate / 12).toFixed(4))
  const n = 12 * time
  const totalAmount = money * ((Math.pow(1 + r, n) - 1) / r)

  // 计算总投入金额
  const totalInvestment = money * time * 12;
  const rateRevenue = totalAmount - totalInvestment
  // 保留两位小数（四舍五入)
  return {
    totalRevenue: Math.round(totalAmount * 100) / 100,
    rateRevenue: Math.round(rateRevenue * 100) / 100,
    monthlyRevenue: Math.round(rateRevenue / (time * 12) * 100) / 100,
  };
}

export function getCopyText(investmentIncome: InvestmentDetail) {
  const res = `计算结果：\n
                投资总额：${investmentIncome.time}元\n
                总收益：${investmentIncome.totalRevenue}元\n
                利息收益：${investmentIncome.rateRevenue}元\n
                年化收益率：${Number(investmentIncome.rate)}%\n
                月均收益：${investmentIncome.monthlyRevenue}`
  if (investmentIncome.financialType === FinancialType.BANK) {
    return `理财计算结果：\n
                理财类型：银行理财\n
                存款类型：${investmentIncome.type === DepositType.CURRENT ? '活期' : '定期'}\n
                存款金额：${investmentIncome.money}元\n
                存款年限：${investmentIncome.time}年\n
                年利率：${Number(investmentIncome.rate)}%\n
                ${res}
                `
  }
  if (investmentIncome.financialType === FinancialType.COMPOUND_RATE) {
    return `理财计算结果：\n
                理财类型：复利理财\n
                存款金额：${investmentIncome.money}元\n
                存款年限：${investmentIncome.time}年\n
                年利率：${Number(investmentIncome.rate)}%\n
                年复利次数：${investmentIncome.compoundRateCount}次/年\n
                ${res}
                `
  }
  if (investmentIncome.financialType === FinancialType.REGULAR_INVESTMENT) {
    return `理财计算结果：\n
                理财类型：银行理财\n
                定投金额：${investmentIncome.money}元\n
                每月定投：${investmentIncome.monthlyMoney}元\n
                定投年数：${investmentIncome.time}年\n
                年化收益率：${Number(investmentIncome.rate) * 0.01}%\n
                ${res}
                `
  }
  return ''
}

// 剪贴板内容
export function copyText(text: string) {
  try {
    // 创建剪贴板内容对象
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    // 获取系统剪贴板对象
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪贴板
    systemPasteboard.getData().then((data) => { // 读取剪贴板内容
      if (data) {
        promptAction.showToast({ message: '复制成功' });
      } else {
        promptAction.showToast({ message: '复制失败' });
      }
    })
  } catch (e) {
    UtilLog.error(`copyText failed with error ${JSON.stringify(e)}`)
  }
}