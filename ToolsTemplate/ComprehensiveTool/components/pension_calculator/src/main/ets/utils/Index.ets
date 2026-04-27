import { UtilLog } from '@hw-agconnect/util-log';
import { pasteboard } from '@kit.BasicServicesKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { PensionCalcRes, PensionInfo } from '../model/Index';

interface PensionInput {
  currentAge: number; // 当前年龄
  retirementAge: number; // 计划退休年龄
  paidYears: number; // 已缴费年限（单位：年）
  monthlyContributionWage: number; // 月缴费工资基数
  localAvgSalaryLastYear: number; // 当地上年度在岗职工月平均工资
  individualRate: number; // 个人缴费比例（如8%）
  employerRate: number; // 单位缴费比例（如16%）
  expectedGrowthRate: number; // 预期平均工资增长率（百分比）
}

interface PensionResult {
  totalPaymentYears: number; // 预期总缴费年限
  personalAccountBalance: number; // 个人账户累计存储额
  basicPension: number; // 基础养老金
  personalAccountPension: number; // 个人账户养老金
  monthlyBenefit: number; // 每月预计领取养老金总额
}

/**
 * 计算养老金相关数据
 * @param input 输入参数对象
 * @returns 养老金计算结果
 */
export function calculatePension(input: PensionInfo): PensionResult {
  // 当前年龄
  const currentAge = Number(input.currentAge)
  // 退休年龄
  const retirementAge = Number(input.plannedRetirementAge)
  // 已缴费年龄
  const paidYears = Number(input.costYear)
  // 月工资
  const monthlyContributionWage = Number(input.monthlyContributionWage)
  // 当地月平均工资
  const localAvgSalaryLastYear = Number(input.averageLocalWage)
  // 个人缴费率
  const individualRate = Number(input.employeePercentage)
  // 工资增长率
  const expectedGrowthRate = Number(input.wageGrowthRate)
  // 总共缴费年限
  const totalYear = retirementAge - currentAge + paidYears
  // 参数校验
  if (currentAge >= retirementAge) {
    throw new Error('当前年龄不能大于或等于退休年龄');
  }
  if (paidYears < 0 || monthlyContributionWage <= 0 || localAvgSalaryLastYear <= 0) {
    throw new Error('输入参数必须为正数');
  }

  // 计算剩余缴费年限（精确到月）
  const remainingYears = retirementAge - currentAge;
  const totalPaymentYears = paidYears + remainingYears;

  // 计算个人账户累计存储额（含利息增值）
  // 公式：∑[每月个人缴费 × (1+增长率)^n]，n为缴费月份序号
  let personalAccountBalance = 0;
  for (let year = 0; year < totalYear; year++) {
    const growthFactor = Math.pow(1 + expectedGrowthRate / 100, year);
    const currentSalary = monthlyContributionWage * growthFactor
    personalAccountBalance += currentSalary * 12 * individualRate / 100
  }

  // 计算基础养老金（新办法）
  // 公式：（当地上年度社平工资 + 本人指数化月均缴费工资）÷ 2 × 缴费年限 × 1%
  const indexedAvgSalary = localAvgSalaryLastYear * Math.pow((1 + expectedGrowthRate / 100), totalYear)
  const indexedCurrentSalary = monthlyContributionWage * Math.pow((1 + expectedGrowthRate / 100), totalYear)
  const basicPension = (indexedAvgSalary + indexedCurrentSalary) / 2 * totalPaymentYears * 0.01;

  // 计算个人账户养老金（个人账户储存额 ÷ 计发月数）
  const issuanceMonths = 139; // 60岁退休对应的计发月数
  const personalAccountPension = personalAccountBalance / issuanceMonths;

  // 计算每月总养老金
  const monthlyBenefit = basicPension + personalAccountPension;

  return {
    totalPaymentYears: parseFloat(totalPaymentYears.toFixed(2)),
    personalAccountBalance: parseFloat(personalAccountBalance.toFixed(2)),
    basicPension: parseFloat(basicPension.toFixed(2)),
    personalAccountPension: parseFloat(personalAccountPension.toFixed(2)),
    monthlyBenefit: parseFloat(monthlyBenefit.toFixed(2)),
  };
}

export function getCopyText(pensionCalcRes: PensionCalcRes) {
  const res = `计算结果：\n
                预计总缴费年限：${pensionCalcRes.estimatedPaymentYears}年\n
                个人账户累计存储额：${pensionCalcRes.personalAccount}元\n
                基础养老金：${pensionCalcRes.personalAccountPension}元\n
                个人账户养老金：${Number(pensionCalcRes.personalAccountPension)}元\n
                每月预计领取养老金总额：${pensionCalcRes.estimatedPayment}元`
  return res
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