@ObservedV2
export class PensionInfo {
  @Trace currentAge: string = '35'
  @Trace plannedRetirementAge: string = '60'
  @Trace costYear: string = '10'
  @Trace monthlyContributionWage: string = '8000'
  @Trace averageLocalWage: string = '7000'
  @Trace employeePercentage: string = '8'
  @Trace unitPercentage: string = '16'
  @Trace wageGrowthRate: string = '5'
  @Trace showButton: boolean = false
}

@ObservedV2
export class PensionCalcRes {
  @Trace showRes: boolean
  @Trace estimatedPaymentYears: string
  @Trace personalAccount: string
  @Trace basicPension: string
  @Trace personalAccountPension: string
  @Trace estimatedPayment: string

  constructor(showRes: boolean, estimatedPaymentYears: string, personalAccount: string, basicPension: string,
    personalAccountPension: string, estimatedPayment: string) {
    this.showRes = showRes
    this.estimatedPaymentYears = estimatedPaymentYears
    this.personalAccount = personalAccount
    this.basicPension = basicPension
    this.personalAccountPension = personalAccountPension
    this.estimatedPayment = estimatedPayment
  }
}