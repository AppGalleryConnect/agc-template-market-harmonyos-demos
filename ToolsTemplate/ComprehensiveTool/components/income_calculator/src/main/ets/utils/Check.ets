import { CalTaxInput, IncomeType } from '../model/CalTaxInput';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';

export function check(incomeType: IncomeType, texInput: CalTaxInput) {
  let isPassed: boolean = true
  switch (incomeType) {
    case IncomeType.SALARY:
      if (!texInput.income) {
        promptAction.showToast({ message: '请输入税前工资（月）' });
        isPassed = false
        break
      }
      if (!texInput.insurance) {
        promptAction.showToast({ message: '请输入专项扣除（社保公积金个人部分）' });
        isPassed = false
        break
      }
    case IncomeType.LABOUR:
      if (!texInput.income) {
        promptAction.showToast({ message: '请输入劳务报酬' });
        isPassed = false
      }
      break
    case IncomeType.ROYALTIES:
      if (!texInput.income) {
        promptAction.showToast({ message: '请输入特许权使用费' });
        isPassed = false
      }
      break
  }

  if (texInput.income! < texInput.insurance!) {
    promptAction.showToast({ message: '税前工资不能低于专项扣除' });
    isPassed = false;
  }

  if (texInput.income! < texInput.deduction!) {
    promptAction.showToast({ message: '税前工资不能低于专项扣除' });
    isPassed = false;
  }

  if (texInput.income! < texInput.insurance! + texInput.deduction!) {
    promptAction.showToast({ message: '税前工资不能低于专项扣除' });
    isPassed = false;
  }

  return isPassed
}