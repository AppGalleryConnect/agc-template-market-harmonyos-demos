import { inputMethod } from '@kit.IMEKit';
import { componentUtils } from '@kit.ArkUI';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { PensionCalcRes, PensionInfo } from '../model/Index';

@ObservedV2
export class PensionPageVM {
  private static _instance: PensionPageVM
  @Trace pensionInfo: PensionInfo = new PensionInfo()
  @Trace pensionCalcRes: PensionCalcRes = new PensionCalcRes(false, '0', '0', '0', '0', '0')

  public static get instance() {
    if (!PensionPageVM._instance) {
      PensionPageVM._instance = new PensionPageVM();
    }
    return PensionPageVM._instance;
  }

  check() {
    if (this.pensionInfo.currentAge !== '' && this.pensionInfo.plannedRetirementAge !== '' &&
      this.pensionInfo.costYear !== '' && this.pensionInfo.monthlyContributionWage !== '' &&
      this.pensionInfo.averageLocalWage !== '' && this.pensionInfo.employeePercentage !== '' &&
      this.pensionInfo.unitPercentage !== '' && this.pensionInfo.wageGrowthRate !== '') {
      this.pensionInfo.showButton = true
    } else {
      this.pensionInfo.showButton = false
    }
  }

  checkCompliance() {
    let res = true
    if (Number(this.pensionInfo.currentAge) <= 0 || Number(this.pensionInfo.currentAge) > 150) {
      res = false
    }
    if (Number(this.pensionInfo.plannedRetirementAge) <= 0 || Number(this.pensionInfo.plannedRetirementAge) > 150) {
      res = false
    }
    if (Number(this.pensionInfo.plannedRetirementAge) <= Number(this.pensionInfo.currentAge)) {
      res = false
    }
    if (Number(this.pensionInfo.costYear) <= 0 ||
      Number(this.pensionInfo.costYear) >= Number(this.pensionInfo.currentAge)) {
      res = false
    }
    if (Number(this.pensionInfo.monthlyContributionWage) <= 0 ||
      Number(this.pensionInfo.monthlyContributionWage) > 10000000) {
      res = false
    }
    if (Number(this.pensionInfo.averageLocalWage) <= 0 || Number(this.pensionInfo.monthlyContributionWage) > 10000000) {
      res = false
    }
    if (Number(this.pensionInfo.employeePercentage) <= 0 || Number(this.pensionInfo.employeePercentage) > 20) {
      res = false
    }
    if (Number(this.pensionInfo.unitPercentage) <= 0 || Number(this.pensionInfo.unitPercentage) > 20) {
      res = false
    }
    if (Number(this.pensionInfo.wageGrowthRate) <= 0 || Number(this.pensionInfo.unitPercentage) > 100) {
      res = false
    }
    if (!res) {
      promptAction.showToast({ message: '输入的值不正确！' });
    }
    return res
  }

  clear() {
    this.pensionInfo = new PensionInfo()
    this.pensionCalcRes = new PensionCalcRes(false, '0', '0', '0', '0', '0')
  }

  closeKeyboard() {
    try {
      inputMethod.getController().stopInputSession();
    } catch (err) {
      console.error('Failed to hide keyboard: ' + err);
    }
  }

  getBarInfo(uiContext: UIContext) {
    let obj: componentUtils.ComponentInfo = uiContext.getComponentUtils().getRectangleById(`pensionButton`);
    return uiContext.px2vp(obj.windowOffset.y)
  }
}
