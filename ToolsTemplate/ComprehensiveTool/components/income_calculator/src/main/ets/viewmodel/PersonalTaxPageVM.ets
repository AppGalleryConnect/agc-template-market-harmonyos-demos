import { DividerTmp } from '../common/Constants'
import { CalTaxInput, IncomeType, TaxParam } from '../model/CalTaxInput'
import { TaxRes } from '../model/TaxRes';
import { calTax, labourTax } from '../utils/CalTax';
import { ctx, Context } from '../common/Context';
import { getInstance } from '../common/CommonRoute';

@ObservedV2
export class PersonalTaxPageVM {
  private static _instance: PersonalTaxPageVM;
  @Trace calTaxInput?: CalTaxInput;
  @Trace incomeType?: IncomeType;
  @Trace tax?: TaxRes;
  @Trace egDivider: DividerTmp = new DividerTmp(1, 0, 0, '#ffe9f0f0')
  @Trace ctx: Context = ctx
  @Trace calculationFormula: ResourceStr = ''

  public static get instance() {
    if (!PersonalTaxPageVM._instance) {
      PersonalTaxPageVM._instance = new PersonalTaxPageVM();
    }
    return PersonalTaxPageVM._instance;
  }

  // 初始化
  public async init() {
    const param: TaxParam | undefined =
      getInstance().getParamByName('PersonalTaxPage')[0] as TaxParam | undefined;
    if (param) {
      this.incomeType = param.incomeType
      this.calTaxInput = param.texInput

      switch (this.incomeType) {
        case IncomeType.SALARY:
          this.tax =
            calTax(this.calTaxInput.income, this.calTaxInput.month, this.calTaxInput.insurance,
              this.calTaxInput.deduction)
          this.calculationFormula = $r('app.string.comment')
          break
        case IncomeType.LABOUR:
          this.tax = labourTax(this.calTaxInput.income)
          this.calculationFormula = $r('app.string.labour_comment')
          break
        case IncomeType.ROYALTIES:
          this.tax = labourTax(this.calTaxInput.income)
          this.calculationFormula = $r('app.string.royalties_comment')
          break
      }
    }
  }
}
